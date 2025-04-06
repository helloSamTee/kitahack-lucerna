from llama_index.core import SimpleDirectoryReader, VectorStoreIndex, StorageContext, Settings, load_index_from_storage, Document
from llama_index.core.indices.keyword_table import SimpleKeywordTableIndex
from llama_index.core.retrievers import BaseRetriever
from llama_index.core.schema import QueryBundle, TextNode
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.llms.google_genai import GoogleGenAI
from llama_index.core.query_engine import RetrieverQueryEngine
from llama_index.core.storage.docstore import SimpleDocumentStore
import hashlib
import chromadb
import os
from dotenv import load_dotenv
from llama_index.embeddings.google_genai import GoogleGenAIEmbedding
# Load environment variables
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# NodeParser - Chunking + Add MetaData
class CarbonEmissionsNodeParser():
    def __init__(self, max_chunk_size: int = 2000):
        self.max_chunk_size = max_chunk_size

    def parse_nodes(self, text: str) -> list[TextNode]:
        """Parses the document into structured chunks with metadata."""
        chunks = []

        section_title, subsection_title = "", ""
        section_content, subsection_content = [], []

        if len(text) == 0:
            return chunks

        lines = text.split("\n")

        for line in lines:
            line = line.strip()

            # Identify section titles (## Main Sections)
            if line.startswith("## "):
                # Stores Previous Subsection if Exist
                if subsection_title and subsection_content:
                    chunks.extend(self.create_chunk(section_title, subsection_title, subsection_content))
                subsection_title = ""

                # Store previous section if present
                if section_title and section_content:
                    chunks.extend(self.create_chunk(section_title, subsection_title, section_content))
                section_title = line.strip("##").strip()
                section_content = []

            # Identify subsection titles (### Subsections)
            elif line.startswith("### "):
                # Store previous subsection
                if section_title and section_content:
                    chunks.extend(self.create_chunk(section_title, subsection_title, section_content))

                if subsection_title and subsection_content:
                    chunks.extend(self.create_chunk(section_title, subsection_title, subsection_content))

                subsection_title = line.strip("###").strip()
                subsection_content = []

            # Add content to the current section/subsection
            else:
                if subsection_title:
                    subsection_content.append(line)
                else:
                    section_content.append(line)

        # Add remaining chunks
        if subsection_title and subsection_content:
            chunks.extend(self.create_chunk(section_title, subsection_title, subsection_content))
        elif section_title and section_content:
            chunks.extend(self.create_chunk(section_title, "", section_content))

        return chunks

    def create_chunk(self, section_title: str, subsection_title: str, content: list[str]) -> list[TextNode]:
        """Creates a chunk while handling max chunk size."""
        full_text = "\n".join(content)
        split_chunks = self.split_into_parts(full_text)

        nodes = []
        for i, chunk in enumerate(split_chunks):            
            metadata = {
                "type": ("section"if not subsection_title else 
                         "subsection" if len(split_chunks) <= 1 else 
                         "subection_part"),
                "section_title": section_title,
                "subsection_title": subsection_title if subsection_title else None,
                "part": i + 1 if len(split_chunks) > 1 else None,
                "contentLength": len(chunk)
            }

            node = TextNode(text=chunk, metadata=metadata)

            nodes.append(node)

        return nodes

    def split_into_parts(self, text: str) -> list[str]:
        """Splits large chunks into smaller parts if needed."""
        if len(text) <= self.max_chunk_size:
            return [text]
        
        # Split by paragraphs while maintaining semantic coherence
        paragraphs = text.split("\n\n")
        chunks, current_chunk = [], []

        for para in paragraphs:
            if sum(len(p) for p in current_chunk) + len(para) > self.max_chunk_size:
                chunks.append("\n\n".join(current_chunk))
                current_chunk = []
            current_chunk.append(para)

        if current_chunk:
            chunks.append("\n\n".join(current_chunk))

        return chunks

# Hybrid Retriever - Vector + Keyword
class HybridRetriever(BaseRetriever):
    def __init__(self, vector_retriever: BaseRetriever, keyword_retriever: BaseRetriever, alpha: int=0.5):
        self.vector_retriever = vector_retriever
        self.keyword_retriever = keyword_retriever
        self.alpha = alpha

    def _retrieve(self, query_bundle: QueryBundle):
        vector_results = self.vector_retriever.retrieve(query_bundle)

        keyword_results = self.keyword_retriever.retrieve(query_bundle)

        hybrid_results = vector_results[:int(self.alpha * len(vector_results))] + keyword_results[:int((1 - self.alpha) * len(keyword_results))]
        return hybrid_results

# RAG Pipeline
class RAG():

    def __init__(self, hostname: str="34.44.31.105", # Vector Store Google Compute Engine Engine External IP
                 port: int=8000,
                 llm = GoogleGenAI(model="models/gemini-1.5-flash-002", api_key=GEMINI_API_KEY), 
                 embed_model=GoogleGenAIEmbedding(model_name="text-embedding-004", api_key=GEMINI_API_KEY),
                 docstore=SimpleDocumentStore.from_persist_path(persist_path="./storageContext/docstore.json")):
        
        self.llm_model = llm.model
        self.llm_api_key = None
        self.vector_index = None
        self.keyword_index = None
        self.storage_context = None
        self.docstore = docstore

        # Set LLM + Embed Model Used
        Settings.llm = llm
        Settings.embed_model = embed_model

        self.documents = self.load_data()

        self.vector_store = self.create_vector_store(hostname=hostname, port=port)

        # Parse Data Into Nodes
        nodes = self.process_data()

        # Create Indexes
        self.vector_index, self.keyword_index = self.create_indexes(nodes=nodes)

        self.query_engine = self.create_query_engine()

    def create_query_engine(self) -> RetrieverQueryEngine:
        # Create Indexes and use Them As Hybrid Retriever
        retriever = self.create_hybrid_retriever()

        # Create Query Engine
        query_engine = RetrieverQueryEngine(retriever=retriever)

        return query_engine

    def create_hybrid_retriever(self) -> HybridRetriever:

        # Create retrievers
        vector_retriever = self.vector_index.as_retriever(similarity_top_k=5) 
        keyword_retriever = self.keyword_index.as_retriever(similarity_top_k=5)

        # Hybrid Retriever Instance
        hybrid_retriever = HybridRetriever(vector_retriever, keyword_retriever)

        return hybrid_retriever

    def load_data(self) -> list[Document]:
        return SimpleDirectoryReader("./ingestion").load_data()

    # Save and Reload System
    def save_and_reload(self, nodes: list[TextNode], docs: list[Document]):
        # Add Documents to Docstore
        self.docstore.add_documents(docs)

        # Indexing New Nodes
        if self.vector_index:
            self.vector_index.insert_nodes(nodes=nodes)

        if self.keyword_index:
            self.keyword_index.insert_nodes(nodes=nodes)

        # Save Docstore and Vector Index
        if self.storage_context:
            self.storage_context.persist("./storageContext")

        if self.vector_index and self.keyword_index:
            self.create_query_engine()

    # Create ChromaVectorStore
    def create_vector_store(self, hostname: str, port: int) -> ChromaVectorStore:
        # Create Vector Store - Stores Embeddings
        try:
            chroma_client = chromadb.HttpClient(host=hostname, port=port)
        except Exception:
            # Local Backup
            chroma_client = chromadb.PersistentClient("./vectorstore")
            print("Chroma DB Server is Down, Running Local Backup")


        chroma_collection = chroma_client.get_or_create_collection(name="data")

        # If Chroma Collection Empty but Document has been Processed then Clear Docstore
        if chroma_collection.count() == 0 and len(self.docstore.docs) != 0:
            self.docstore = SimpleDocumentStore()
        
        vector_store = ChromaVectorStore(chroma_collection=chroma_collection)

        return vector_store

    # Create Vector and Keyword Index
    def create_indexes(self, nodes : list[TextNode]) -> tuple[VectorStoreIndex, SimpleKeywordTableIndex]:
        # Indexing
        try:
            # Load Existing Vector Index and Insert New Nodes
            self.storage_context = StorageContext.from_defaults(vector_store=self.vector_store, docstore=self.docstore, persist_dir="./storageContext")
            vector_index = load_index_from_storage(storage_context=self.storage_context)
            vector_index.insert_nodes(nodes=nodes)
        except Exception:
            # Create New Vector Index
            self.storage_context = StorageContext.from_defaults(vector_store=self.vector_store, docstore=self.docstore)
            vector_index = VectorStoreIndex(nodes=nodes, storage_context=self.storage_context)

        vector_nodes = list(self.docstore.docs.values())

        # Store Docstore and Index Store Info
        self.storage_context.persist("./storageContext")

        all_nodes = vector_nodes + nodes

        # BM25 Keyword Index
        keyword_index = SimpleKeywordTableIndex(nodes=all_nodes)

        return vector_index, keyword_index

    # Chunking + Metadata + Duplicate Prevention
    def process_data(self) -> list[TextNode]:
        parser = CarbonEmissionsNodeParser()
        nodes = []
        new_docs = []

        for doc in self.documents:
            doc.doc_id = hashlib.sha256(doc.text.encode("utf8")).hexdigest()


            if self.docstore.document_exists(doc.doc_id):
                continue
                
            new_docs.append(doc)
            nodes.extend(parser.parse_nodes(doc.text))

        self.save_and_reload(nodes, new_docs)

        return nodes

    def query(self, query: str) -> str:
        try:
            return self.query_engine.query(query).response
        except Exception:
            Settings.llm = GoogleGenAI(model=self.llm_model)
            return "Query Unsuccessful"

    def set_llm_api_key(self, api_key: str) -> int:
        try:
            Settings.llm = GoogleGenAI(model=self.llm_model, api_key=api_key)
            self.llm_api_key = api_key
            return 0 # Success
        except Exception:
            Settings.llm = GoogleGenAI(model=self.llm_model, api_key=GEMINI_API_KEY)
            return 1 # Error 

    def set_llm_model(self, model: str) -> int:
        try:
            Settings.llm = GoogleGenAI(model=model, api_key=self.llm_api_key if self.llm_api_key else GEMINI_API_KEY)
            self.llm_model = model
            return 0
        except Exception:
            Settings.llm = GoogleGenAI(model=self.llm_model, api_key=self.llm_api_key if self.llm_api_key else GEMINI_API_KEY)
            return 1
