import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? geminiApiKey;
  final String? carbonSutraApiKey;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.geminiApiKey,
    this.carbonSutraApiKey
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'geminiApiKey': geminiApiKey,
      'carbonSutraApiKey': carbonSutraApiKey
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      geminiApiKey: json['geminiApiKey'] ?? '',
      carbonSutraApiKey: json['carbonSutraApiKey'] ?? ''
    );
  }
}
