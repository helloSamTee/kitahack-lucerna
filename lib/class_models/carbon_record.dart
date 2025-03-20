import 'package:cloud_firestore/cloud_firestore.dart';

class CarbonRecord {
  final String title;
  final String type;
  final String value;
  final DateTime dateTime;
  final String? suggestion;
  final String? vehicleType;
  final String? distance;
  final String? energyUsed;

  CarbonRecord({
    required this.title,
    required this.type,
    required this.value,
    required this.dateTime,
    this.suggestion,
    this.vehicleType,
    this.distance,
    this.energyUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'value': value,
      'dateTime': Timestamp.fromDate(dateTime),
      'suggestion': suggestion,
      'vehicleType': vehicleType,
      'distance': distance,
      'energyUsed': energyUsed,
    };
  }

  factory CarbonRecord.fromJson(Map<String, dynamic> json) {
    return CarbonRecord(
      title: json['title'] as String,
      type: json['type'] as String,
      value: json['value'] as String,
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      suggestion: json['suggestion'] as String?,
      vehicleType: json['vehicleType'] as String?,
      distance: json['distance'] as String?,
      energyUsed: json['energyUsed'] as String?,
    );
  }
}
