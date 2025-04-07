import 'dart:typed_data';
import 'package:Lucerna/calculator/common_widget.dart';
import 'package:Lucerna/calculator/gemini_footprint.dart';
import 'package:Lucerna/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cf_summary.dart';
import '../main.dart';
import 'package:image_picker/image_picker.dart'; // For picking images/documents
import 'package:google_generative_ai/google_generative_ai.dart';
import '../API_KEY_Config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class foodRecord extends StatefulWidget {
  const foodRecord({super.key});

  @override
  _FoodRecordState createState() => _FoodRecordState();
}

class _FoodRecordState extends State<foodRecord> {
  final _formKey = GlobalKey<FormState>(); // Key to manage form state
  final TextEditingController _titleController = TextEditingController();
  XFile? _selectedFile; // Track attached file
  Uint8List? _selectedImageBytes; // Store image bytes for preview
  Uint8List? _decodedImageBytes; // Store decoded image bytes for display

  Future<String> calculateCarbonFootprintFromFile(XFile? file) async {
    if (file == null) {
      print("No file selected.");
      throw Exception("No file selected");
    }

    final imageBytes = await file.readAsBytes();
    print("Image read successfully, size: ${imageBytes.lengthInBytes} bytes");

    final cloudRunEndpointUrl = 'https://food-detection-modelv2-193945562879.us-central1.run.app/predict';
    final uri = Uri.parse(cloudRunEndpointUrl);

    String fileExtension = file.path.split('.').last.toLowerCase();
    String mimeType = fileExtension == 'png'
        ? 'image/png'
        : (fileExtension == 'jpg' || fileExtension == 'jpeg')
            ? 'image/jpeg'
            : 'image/jpeg'; // fallback

    final mimeParts = mimeType.split('/');
    if (mimeParts.length != 2) {
      throw Exception("Invalid MIME type: $mimeType");
    }

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: file.name,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      ),
    );

    print("Sending request to Cloud Run...");
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.transform(utf8.decoder).join();

    if (streamedResponse.statusCode != 200) {
      print("Cloud Run request failed: ${streamedResponse.statusCode}");
      throw Exception("Cloud Run request failed");
    }

    final Map<String, dynamic> cloudRunResult = jsonDecode(responseBody);
    print("Cloud Run JSON response: $cloudRunResult");

    final detectionDetails = cloudRunResult['detection_details'];
    if (detectionDetails == null || detectionDetails is! List) {
      throw Exception("Invalid detection details from Cloud Run");
    }

    // Parse and decode the base64 image from the response
    final String? base64ImageString = cloudRunResult['image_base64'];
    if (base64ImageString != null) {
      final decodedImage = base64Decode(base64ImageString);
      // Optionally update the state so the image can be displayed in your UI
      setState(() {
        _decodedImageBytes = decodedImage;
      });
      print("Base64 image decoded successfully.");
    } else {
      print("No base64 image found in the response.");
    }

    StringBuffer boundingBoxesBuffer = StringBuffer();
    for (var detail in detectionDetails) {
      final boundingBox = detail['bounding_box_normalized'];
      final className = detail['class_name'];
      if (boundingBox != null && className != null) {
        boundingBoxesBuffer.writeln(
          "$className: (xmin: ${boundingBox['xmin']}, ymin: ${boundingBox['ymin']}, xmax: ${boundingBox['xmax']}, ymax: ${boundingBox['ymax']})",
        );
      }
    }
    final boundingBoxesInfo = boundingBoxesBuffer.toString();
    print("Extracted bounding boxes info: \n$boundingBoxesInfo");

    // Use the Gemini API function from gemini_footprint.dart
    final geminiAPI = GeminiAPIFootprint(context);
    return await geminiAPI.calculateFoodCarbonFootprint(
      boundingBoxesInfo: boundingBoxesInfo,
      imageBytes: imageBytes,
      mimeType: mimeType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing by tapping outside
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Calculating...'),
              ],
            ),
          );
        },
      );

      try {
        String carbonFootprint =
            await calculateCarbonFootprintFromFile(_selectedFile);
        
        // Dismiss the loading dialog using the root navigator to ensure it pops the dialog
        Navigator.of(context, rootNavigator: true).pop();
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
                      image: _decodedImageBytes,
                    )));
      } catch (error) {
        // Dismiss the loading dialog using the root navigator if there's an error
        Navigator.of(context, rootNavigator: true).pop();

        // Optionally, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            content: Text(
              'Error calculating carbon footprint: $error',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
            ),
          ),
        );
      }
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
