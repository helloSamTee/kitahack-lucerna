import 'dart:typed_data';

import 'package:Lucerna/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';

class GeminiAPIFootprint {
  late String apiKey;

  GeminiAPIFootprint(BuildContext context) {
    // Get the API key from the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiKey = authProvider.geminiApiKey;
  }

  Future<String> callAPI({
    required String prompt,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final carbonFootprintText = response.text ?? "0";

      print("Gemini API Response: $carbonFootprintText");

      // Extract numeric value
      final RegExp regex = RegExp(r'(\d+(\.\d+)?)');
      final match = regex.firstMatch(carbonFootprintText);
      return match?.group(0) ?? "0"; // Return numeric value or default to "0"
    } catch (e) {
      return "Error calculating footprint";
    }
  }

  Future<String> calcElectricity({
    required String electricityValue,
    required String countryName,
  }) async {
    final String prompt = '''
        You are a carbon footprint calculator.

        Estimate the carbon footprint for a electricity consumption based on the following information:
        - Electricity consumption: $electricityValue kWh  
        - Country: $countryName  
        
        Estimate the carbon footprint in kilograms of CO₂.  
        Respond with **only** the numerical value of the estimate in **kg CO₂**, with no units, no explanation, and no extra text.  
        Example output: 123.45
        ''';

    return callAPI(prompt: prompt);
  }

  Future<String> calcFlight(
      {required String flightFrom,
      required String flightTo,
      required String flightClass,
      required String roundTrip,
      required String numPassenger}) async {
    final String prompt = '''
        You are a carbon footprint calculator.

        Estimate the carbon footprint for a flight based on the following information:
        - From airport (IATA code): $flightFrom
        - To airport (IATA code): $flightTo
        - Flight class: $flightClass
        - Round trip: $roundTrip
        - Number of passengers: $numPassenger
        
        Estimate the carbon footprint in kilograms of CO₂.  
        Respond with **only** the numerical value of the estimate in **kg CO₂**, with no units, no explanation, and no extra text. 
        Example output: 123.45
        ''';

    return callAPI(prompt: prompt);
  }

  Future<String> calcVehicleByType({
    required String vehicleType,
    required String distanceKM,
    required String fuelType,
  }) async {
    final String prompt = '''
        You are a carbon footprint calculator.

        Estimate the carbon footprint for a ride based on the following information:
        - Vehicle type: $vehicleType
        - Distance: $distanceKM km
        - Fuel type: $fuelType
        
        Estimate the carbon footprint in kilograms of CO₂.  
        Respond with **only** the numerical value of the estimate in **kg CO₂**, with no units, no explanation, and no extra text.  
        Example output: 123.45
        ''';

    return callAPI(prompt: prompt);
  }

  Future<String> calculateFoodCarbonFootprint({
    required String boundingBoxesInfo,
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
    );

    final prompt = '''
    Estimate the carbon footprint for the food shown in the image using the following bounding box details:
    $boundingBoxesInfo
    Only provide the estimate result in kg CO₂.
    ''';

    print("Gemini prompt prepared: $prompt");

    try {
      final geminiResponse = await model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ])
      ]);

      print("Gemini response received: ${geminiResponse.text}");
      final carbonFootprintText = geminiResponse.text!;
      final RegExp regex = RegExp(r'(\d+(\.\d+)?)');
      final match = regex.firstMatch(carbonFootprintText);

      if (match != null) {
        print("Carbon footprint extracted: ${match.group(0)}");
        return match.group(0)!;
      } else {
        print("Failed to extract carbon footprint from Gemini response.");
        throw Exception("Could not parse carbon footprint from Gemini response");
      }
    } catch (error) {
      print("Error in generating content: $error");
      rethrow;
    }
  }
  // without image bytes
  // Future<String> calculateFoodCarbonFootprint({
  //   required String boundingBoxesInfo,
  //   required Uint8List imageBytes,
  //   required String mimeType,
  // }) async {
  //   final prompt = '''
  //   Estimate the carbon footprint for the food shown in the image using the following bounding box details:
  //   $boundingBoxesInfo
  //   Only provide the estimate result in kg CO₂.
  //   ''';

  //   print("Gemini prompt prepared: $prompt");

  //   try {
  //     // Use the existing callAPI function
  //     return await callAPI(prompt: prompt);
  //   } catch (error) {
  //     print("Error in generating content: $error");
  //     rethrow;
  //   }
  // }
}
