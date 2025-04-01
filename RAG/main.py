from fastapi import FastAPI, UploadFile, File, Header
from rag_header import RAG
import json

class RAG_API():
    def __init__(self):
        self.rag_engine = self.initialize_RAG()
        self.app = FastAPI()

        self.app.post("/upload")(self.upload_multiple)
        self.app.post("/secure-endpoint/api_key")(self.set_api_key)
        self.app.post("/secure-endpoint/db_url")(self.set_db_url)
        self.app.get("/query")(self.query)

    def initialize_RAG(self):
        try:
            with open("./config.json", "rb") as file:
                config = json.load(file)

            hostname, port = config["DATABASE_URL"].split(":")
            port = int(port)
        except Exception:
            hostname, port = "34.44.31.105", 8000

        return RAG(hostname=hostname, port=port)

    async def upload_multiple(self, files: list[UploadFile] = File(...)):
        for file in files:
            file_location = f"./ingestion/{file.filename}"
            with open(file_location, "wb") as f:
                f.write(await file.read())

        self.rag_engine.process_data()

        return [{"filename": file.filename, "content_type": file.content_type} for file in files]

    async def set_api_key(self, api_key: str = Header(..., alias="api-key")):
        error = self.rag_engine.set_llm_api_key(api_key=api_key)

        return {"Info": "API KEY INVALID" if error else "API KEY RECEIVED"}

    async def set_db_url(self, hostname: str = Header(..., alias="hostname"), port: int = Header(..., alias="port")):
        try:
            self.rag_engine = RAG(hostname=hostname, port=port)
        except Exception:
            self.rag_engine = self.initialize_RAG()
        
        db_url = f"{hostname}:{port}"  # Format hostname:port


        try:
            with open("./config.json", "rb") as file:
                config = json.load(file)

            config["DATABASE_URL"] = db_url
        except Exception:
            config = {"DATABASE_URL": db_url}

        # Write to a JSON file
        with open("config.json", "w") as file:
            json.dump(config, file, indent=4)


        return {"message": "DATABASE_URL updated successfully!", "DATABASE_URL": db_url}

    async def query(self, query: str):
        ans = self.rag_engine.query(query)
        return {"response": ans}

# RAG Instance
api = RAG_API()

# Endpoint
app = api.app
