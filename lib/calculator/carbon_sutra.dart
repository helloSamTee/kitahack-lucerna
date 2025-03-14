import 'dart:convert';
import 'package:http/http.dart' as http;
import '../API_KEY_Config.dart';

class CarbonSutraAPI {
  Future<Map<String, dynamic>?> callAPI({
    required Object inputBody,
    required String url,
  }) async {
    try {
      final String baseUrl = url;
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "x-rapidapi-key": ApiKeyConfig.carbonSutraApiKey,
          "x-rapidapi-host": "carbonsutra1.p.rapidapi.com",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: inputBody,
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("API Error: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> calcElectricity({
    required String electricityValue,
    required String countryName,
  }) async {
    final String baseUrl =
        "https://carbonsutra1.p.rapidapi.com/electricity_estimate";

    Object body = {
      "electricity_value": electricityValue,
      "country_name": countryName,
      "electricity_unit": "kWh",
    };

    return callAPI(inputBody: body, url: baseUrl);
  }

  Future<Map<String, dynamic>?> calcFlight(
      {required String flightFrom,
      required String flightTo,
      required String flightClass,
      required String roundTrip,
      required String numPassenger}) async {
    final String baseUrl =
        "https://carbonsutra1.p.rapidapi.com/flight_estimate";

    Object body = {
      "iata_airport_from": flightFrom,
      "iata_airport_to": flightTo,
      "flight_class": flightClass,
      "round_trip": roundTrip,
      "number_of_passengers": numPassenger,
    };

    return callAPI(inputBody: body, url: baseUrl);
  }

  Future<Map<String, dynamic>?> calcVehicleByType({
    required String vehicleType,
    required String distanceKM,
    required String fuelType,
  }) async {
    final String baseUrl =
        "https://carbonsutra1.p.rapidapi.com/vehicle_estimate_by_type";

    Object body = {
      "vehicle_type": vehicleType,
      "distance_value": distanceKM,
      "distance_unit": "km",
      "fuel_type": fuelType
    };

    return callAPI(inputBody: body, url: baseUrl);
  }

  // Future<Map<String, dynamic>?> calFlight(
  //     {required String flightFrom,
  //     required String flightTo,
  //     required String flightClass,
  //     required String roundTrip,
  //     required String numPassengers}) async {
  //   try {
  //     final String baseUrl =
  //         "https://carbonsutra1.p.rapidapi.com/flight_estimate";
  //     final response = await http.post(
  //       Uri.parse(baseUrl),
  //       headers: {
  //         "x-rapidapi-key": ApiKeyConfig.carbonSutraApiKey,
  //         "x-rapidapi-host": "carbonsutra1.p.rapidapi.com",
  //         "Content-Type": "application/x-www-form-urlencoded",
  //       },
  //       body: {
  //         "iata_airport_from": flightFrom,
  //         "iata_airport_to": flightTo,
  //         "flight_class": flightClass,
  //         "round_trip": roundTrip,
  //         "number_of_passengers": numPassengers
  //       },
  //     );

  //     print("Response Code: ${response.statusCode}");
  //     print("Response Body: ${response.body}");

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       print("API Error: ${response.statusCode}, ${response.body}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Exception: $e");
  //     return null;
  //   }
  // }

  // Future<Map<String, dynamic>?> calVehicleByType({
  //   required String vehicleType,
  //   required String distanceKM,
  //   required String fuelType,
  // }) async {
  //   try {
  //     final String baseUrl =
  //         "https://carbonsutra1.p.rapidapi.com/vehicle_estimate_by_type";
  //     final response = await http.post(
  //       Uri.parse(baseUrl),
  //       headers: {
  //         "x-rapidapi-key": ApiKeyConfig.carbonSutraApiKey,
  //         "x-rapidapi-host": "carbonsutra1.p.rapidapi.com",
  //         "Content-Type": "application/x-www-form-urlencoded",
  //       },
  //       body: {
  //         "vehicle_type": vehicleType,
  //         "distance_value": distanceKM,
  //         "distance_unit": "km",
  //         "fuel_type": fuelType
  //       },
  //     );

  //     print("Response Code: ${response.statusCode}");
  //     print("Response Body: ${response.body}");

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       print("API Error: ${response.statusCode}, ${response.body}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Exception: $e");
  //     return null;
  //   }
  // }
}
