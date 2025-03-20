import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Lucerna/class_models/user_model.dart';
import 'package:Lucerna/class_models/carbon_record.dart';
import 'package:Lucerna/class_models/carbon_offset.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User CRUD ---------------------------------------------------
  Future<void> saveUser(UserModel user) async {
    await _db.collection("users").doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    print("Fetching user with UID: $uid");

    DocumentSnapshot doc = await _db.collection("users").doc(uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // If the 'uid' field is missing or empty, use the document's ID
      if (data['uid'] == null || (data['uid'] as String).isEmpty) {
        data['uid'] = doc.id;
      }
      return UserModel.fromJson(data);
    }
    return null;
  }

  // Carbon Footprint CRUD ---------------------------------------
  Future<void> addCarbonFootprint(String uid, CarbonRecord record) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("carbonFootprint")
        .add(record.toJson());
  }

  // Get carbon footprint records
  Future<List<CarbonRecord>> getCarbonFootprint(String uid) async {
    QuerySnapshot snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("carbonFootprint")
        .orderBy("dateTime", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CarbonRecord.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Carbon Offset CRUD ------------------------------------------
  Future<void> addCarbonOffset(String uid, CarbonOffset offset) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("carbonOffset")
        .add(offset.toJson());
  }

  Future<List<CarbonRecord>> getCarbonOffset(String uid) async {
    QuerySnapshot snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("carbonOffset")
        .orderBy("dateTime", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CarbonRecord.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}