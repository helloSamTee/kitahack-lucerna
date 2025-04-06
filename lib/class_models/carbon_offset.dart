import 'package:cloud_firestore/cloud_firestore.dart';

class CarbonOffset {
  final double value;
  final DateTime dateTime;

  CarbonOffset({
    required this.value,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  factory CarbonOffset.fromJson(Map<String, dynamic> json) {
    return CarbonOffset(
      value: json['value'],
      dateTime: (json['dateTime'] as Timestamp).toDate(),
    );
  }
}