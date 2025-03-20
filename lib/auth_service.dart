import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Lucerna/class_models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create user object based on FirebaseUser
  Future<UserModel?> _userFromFirebaseUser(User? user) async {
    if (user != null) {
      print('AuthService: _userFromFirebaseUser called with user: $user'); // Debugging statement
      UserModel? userModel = await _firestoreService.getUser(user.uid);
      if (userModel == null) {
        // Create user document if it doesn't exist
        userModel = UserModel(uid: user.uid, username: user.email!.split('@')[0], email: user.email!);
        await _firestoreService.saveUser(userModel);
      }
      print('AuthService: UserModel from Firestore: $userModel'); // Debugging statement
      return userModel;
    }
    return null;
  }

  // Auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap(_userFromFirebaseUser);
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    return await _userFromFirebaseUser(user);
  }

  User? get currentUser => _auth.currentUser;

  // Register user
  Future<UserModel?> registerUser(String username, String email, String password) async {
    try {
      // Create user in Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create a new user model
        UserModel newUser = UserModel(
          uid: user.uid,
          username: username,
          email: email,
        );

        // Save the user to Firestore
        await _firestoreService.saveUser(newUser);

        return newUser; // Return the created user
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
    } catch (e) {
      print("Error: $e");
    }
    return null; // Return null if registration fails
  }

  // Login user
  Future<UserModel?> loginUser(String email, String password) async {
    print('AuthService: loginUser method called'); // Debugging statement
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      print(user?.uid); // Debugging statement
      print('AuthService: Firebase user: $user'); // Debugging statement

      if (user != null) {
        UserModel? userModel = await _userFromFirebaseUser(user);
        print('AuthService: UserModel from Firestore: $userModel'); // Debugging statement
        return userModel;
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  // Logout user
  Future logoutUser() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> updateEmail(String newEmail) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Update email in Firebase Authentication
        await currentUser.updateEmail(newEmail);

        // Update email in Firestore
        await _db
            .collection("users")
            .doc(currentUser.uid)
            .update({'email': newEmail});

        return true; // Email update successful
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print("Error: Reauthentication required to update email.");
      } else {
        print("Error updating email: ${e.message}");
      }
    } catch (e) {
      print("Error updating email: $e");
    }
    return false; // Email update failed
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await currentUser.updatePassword(newPassword);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception("Reauthentication required. Please log in again.");
      } else {
        throw Exception(e.message ?? "An error occurred while updating the password.");
      }
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
    return false; 
  }

  Future<void> updateApiKeys(String uid, String? geminiApiKey, String? carbonSutraApiKey) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'geminiApiKey': geminiApiKey,
        'carbonSutraApiKey': carbonSutraApiKey,
      });
    } catch (e) {
      throw Exception("Failed to update API keys: $e");
    }
  }
}