import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  Future storeUserInfo(String userID, Map<String, dynamic> userInfo) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .set(userInfo);
  }

  Future<Stream<QuerySnapshot>> getRecommendedUsers(String? myUserName) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('user_name', isNotEqualTo: myUserName)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getCurrentMessages(String? myUserName) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .orderBy('lastMessageTime', descending: true)
        .where('users', arrayContains: myUserName)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getMessages(String? chatRoomID) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('chats')
        .orderBy('message_time', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String userName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('user_name', isEqualTo: userName)
        .get();
  }

  Future addMessage(String? chatRoomID, String messageID,
      Map<String, dynamic> messageInfo) async {
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomID)
        .collection('chats')
        .doc(messageID)
        .set(messageInfo);
  }

  Future updateLastMessage(String? chatRoomID, lastMessageInfo) async {
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomID)
        .update(lastMessageInfo);
  }

  updateOnlineStatus(String uid, Map<String, dynamic> status) {
    FirebaseFirestore.instance.collection('users').doc(uid).update(status);
  }

  Future<Stream<QuerySnapshot>> getUserStatus(String uid) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: uid)
        .snapshots();
  }

  Future createChatRoom(
      String? chatRoomID, Map<String, dynamic> chatRoomInfo) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomID)
        .get();

    if (!snapshot.exists) {
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomID)
          .set(chatRoomInfo);
    }
  }
}
