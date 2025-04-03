import 'dart:typed_data';
import 'package:Lucerna/calculator/common_widget.dart';
import 'package:Lucerna/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cf_summary.dart';
import '../main.dart';
import 'package:image_picker/image_picker.dart'; // For picking images/documents
import 'package:google_generative_ai/google_generative_ai.dart';
import '../API_KEY_Config.dart';

class foodRecord extends StatefulWidget {
  @override
  _FoodRecordState createState() => _FoodRecordState();
}

class _FoodRecordState extends State<foodRecord> {
  final _formKey = GlobalKey<FormState>(); // Key to manage form state
  final TextEditingController _titleController = TextEditingController();
  XFile? _selectedFile; // Track attached file
  Uint8List? _selectedImageBytes; // Store image bytes for preview

  Future<String> calculateCarbonFootprintFromFile(XFile? file) async {
    if (file == null) {
      print("No file selected.");
      throw Exception("No file selected");
    }

    print("Initializing GenerativeModel...");

    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: ApiKeyConfig.geminiApiKey,
    );

    final prompt = '''
      Estimate the carbon footprint for the food shown in the provided image.
      dont say anything else, Only provide the estimate result in kg CO₂.
    ''';

    print("Prompt prepared: $prompt");

    final imageBytes = await file.readAsBytes();
    print("Image read successfully, size: ${imageBytes.lengthInBytes} bytes");

    final mimeType = 'image/jpeg';

    try {
      final response = await model.generateContent([
        Content.multi([TextPart(prompt), DataPart(mimeType, imageBytes)])
      ]);

      print("Response received: ${response.text}");

      final carbonFootprintText = response.text!;
      final RegExp regex = RegExp(r'(\d+(\.\d+)?)');
      final match = regex.firstMatch(carbonFootprintText);

      if (match != null) {
        print("Carbon footprint extracted: ${match.group(0)}");
        return match.group(0)!;
      } else {
        print("Failed to extract carbon footprint from response.");
        throw Exception(
            "Could not parse carbon footprint from Gemini response");
      }
    } catch (error) {
      print("Error in generating content: $error");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(200, 200, 200, 1),
        appBar: CommonAppBar(title: "Track Carbon Footprint"),
        bottomNavigationBar:
            CommonBottomNavigationBar(selectedTab: BottomTab.tracker),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Add Food Record',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      color: Color.fromRGBO(0, 0, 0, 0.5)),
                            ),
                            const SizedBox(height: 50),
                            buildTextField(context, _titleController, 'Title'),
                            const SizedBox(height: 25),
                            _buildAttachmentSection(),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                    _buildSubmitButton(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return GestureDetector(
      onTap: _pickFile, // Trigger file selection
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.5)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: _selectedFile != null
            ? _selectedImageBytes != null
                ? Image.memory(_selectedImageBytes!) // Display selected image
                : const Center(
                    child:
                        CircularProgressIndicator()) // Loading indicator while reading file
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_drive_file,
                      size: 100, color: Color.fromRGBO(0, 0, 0, 0.5)),
                  const SizedBox(height: 10),
                  Text('Attach Document',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: Color.fromRGBO(0, 0, 0, 0.5))),
                ],
              ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print("File picked: ${pickedFile.path}");
      setState(() {
        _selectedFile = pickedFile; // Store selected file as XFile
      });

      // Read the file's bytes to display the preview
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes; // Set bytes for preview
      });
    }
  }

  Widget _buildSubmitButton() {
    return Builder(
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            child: SizedBox(
              width: 175,
              child: ElevatedButton(
                  onPressed: () {
                    // Use context of the nearest Scaffold with Builder widget
                    _submitForm(context); // Pass context explicitly
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.ptSansCaption(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
            ),
          ),
        );
      },
    );
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      // If the form is valid, navigate to the next page
      // Get input values
      String title = _titleController.text;

      /*
                Gemini API call here!!
                Pass the carbon footprint and suggestion to CFSummaryPage constructor
                */
      String carbonFootprint =
          await calculateCarbonFootprintFromFile(_selectedFile);

      // Navigate to the new page with the inputs
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CFSummaryPage(
                    title: title,
                    category: 'Food',
                    carbon_footprint: carbonFootprint,
                    suggestion: '',
                    vehicleType: null,
                    distance: null,
                    energyUsed: null,
                  )));
    } else if (_selectedFile == null) {
      // Show error if no file is attached
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          content: Text(
            'Please attach a document before submitting',
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.white),
          ),
        ),
      );
    }
  }
}
