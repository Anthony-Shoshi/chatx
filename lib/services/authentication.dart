import 'package:chatx/helpers/shared_pref_manager.dart';
import 'package:chatx/screens/home.dart';
import 'package:chatx/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  signUpWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;
    if (result != null) {
      SharedPrefManager().saveUserID(userDetails!.uid.toString());
      SharedPrefManager().saveUserName(
        userDetails.email!
            .replaceAll("@gmail.com", "")
            .replaceAll("@", "_")
            .replaceAll(".", "_"),
      );
      SharedPrefManager().saveUserEmail(userDetails.email.toString());
      SharedPrefManager()
          .saveUserDisplayName(userDetails.displayName.toString());
      SharedPrefManager().saveUserProfile(userDetails.photoURL.toString());

      Map<String, dynamic> userInfo = {
        "name": userDetails.displayName,
        "email": userDetails.email,
        "user_id": userDetails.uid,
        "user_name": userDetails.email!
            .replaceAll("@gmail.com", "")
            .replaceAll("@", "_")
            .replaceAll(".", "_"),
        "profile_url": userDetails.photoURL,
        "status": "Online",
        "isTyping": false,
      };

      DatabaseManager().storeUserInfo(userDetails.uid, userInfo).then((value) {
        Get.offAll(() => HomeScreen());
      });
    }
  }

  Future signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    _firebaseAuth.signOut();
  }
}
