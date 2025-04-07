import 'package:Lucerna/API_KEY_Config.dart';
import 'package:flutter/material.dart';
import 'package:Lucerna/class_models/user_model.dart';
import 'package:Lucerna/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  // AuthProvider() {
  //   // Listen to auth state changes and load user data
  //   FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
  //     if (firebaseUser != null) {
  //       _user = await _authService.getCurrentUser();
  //       notifyListeners();
  //     } else {
  //       _user = null;
  //       notifyListeners();
  //     }
  //   });
  // }

  UserModel? get user => _user;

  Future<void> login(String email, String password) async {
    print('AuthProvider: login method called'); // Debugging statement
    _user = await _authService.loginUser(email, password);
    print('AuthProvider: user set to $_user'); // Debugging statement
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    _user = await _authService.registerUser(username, email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logoutUser();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateEmail(String newEmail) async {
    bool result = await _authService.updateEmail(newEmail);
    if (result) {
      // Update the local user model
      if (_user != null) {
        _user = UserModel(
          uid: _user!.uid,
          username: _user!.username,
          email: newEmail,
        );
        notifyListeners();
      }
    }
    return result;
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      bool result = await _authService.updatePassword(newPassword);
      if (result) {
        notifyListeners(); // Notify UI if needed
        return true;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    return false;
  }

  Future<void> updateApiKeys(String? geminiApiKey, String? carbonSutraApiKey) async {
    if (_user != null) {
      await _authService.updateApiKeys(_user!.uid, geminiApiKey, carbonSutraApiKey);

      // Update local user model
      _user = UserModel(
        uid: _user!.uid,
        username: _user!.username,
        email: _user!.email,
        geminiApiKey: geminiApiKey,
        carbonSutraApiKey: carbonSutraApiKey,
      );
      notifyListeners();
    }
  }

  String get geminiApiKey {
    if (_user?.geminiApiKey != null && _user!.geminiApiKey!.isNotEmpty) {
      return _user!.geminiApiKey!;
    }
    return ApiKeyConfig.geminiApiKey; // Default key
  }

  String get carbonSutraApiKey {
    if (_user?.carbonSutraApiKey != null && _user!.carbonSutraApiKey!.isNotEmpty) {
      return _user!.carbonSutraApiKey!;
    }
    return ApiKeyConfig.carbonSutraApiKey; // Default key
  }
}