import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  Future storeUserInfo(String userID, Map<String, dynamic> userInfo) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .set(userInfo);
  }
}
