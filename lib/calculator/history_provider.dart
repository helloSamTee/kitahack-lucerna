import 'package:flutter/foundation.dart';
import 'dart:convert'; // To convert data to/from JSON
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:Lucerna/firestore_service.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:Lucerna/class_models/carbon_record.dart';

class HistoryProvider with ChangeNotifier {
  // List to store history records.
  List<Map<String, String?>> _history = [];

  // Getter to access the history records.
  List<Map<String, String?>> get history => _history;

  final FirestoreService _firestoreService = FirestoreService();

  // Method to add a new record and notify listeners.
  Future<void> addRecord(
    String title,
    String category,
    String carbonFootprint,
    String suggestion,
    String? vehicleType,
    String? distance,
    String? energyUsed,
  ) async {
    String formattedDate =
        _formatDateTime(DateTime.now()); // Generate timestamp

    _history.add({
      'title': title,
      'category': category,
      'carbonFootprint': carbonFootprint,
      'suggestion': suggestion,
      'vehicleType': vehicleType,
      'distance': distance,
      'energyUsed': energyUsed,
      'dateTime': formattedDate,
    });

    notifyListeners();
    await _saveHistoryToPrefs();
  }

  // New method to add record to Firestore
  Future<void> addRecordToFirestore(String userId, CarbonRecord record) async {
    await _firestoreService.addCarbonFootprint(userId, record);
  }

  // Load history records from shared preferences.
  Future<void> loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyString = prefs.getString('history');
    List<dynamic> historyList = jsonDecode(historyString);
    _history =
        historyList.map((item) => Map<String, String>.from(item)).toList();
    notifyListeners();
    }

  // Save the current history to shared preferences.
  Future<void> _saveHistoryToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String historyString = jsonEncode(_history);
    await prefs.setString('history', historyString);
  }

  // Clear all history records.
  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
  }

  // Load history records from Firestore.
  Future<void> loadHistoryFromFirestore(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('carbonFootprint')
          .orderBy('dateTime', descending: true)
          .get();

      _history = snapshot.docs
          .map((doc) {
            return {
              'title': doc['title'] as String?,
              'category': doc['type'] as String?,
              'carbonFootprint': doc['value'].toString(),
              'suggestion': doc['suggestion'] as String?,
              'vehicleType': doc['vehicleType'] as String?,
              'distance': doc['distance'].toString(),
              'energyUsed': doc['energyUsed'].toString(),
              'dateTime': _formatDateTime(doc['dateTime'].toDate()),
            };
          })
          .toList()
          .cast<Map<String, String?>>();

      notifyListeners();
    } catch (e) {
      print('Error loading history from Firestore: $e');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat("MMMM d, yyyy 'at' hh:mm:ss a 'UTC'XXX").format(dateTime);
  }
}
