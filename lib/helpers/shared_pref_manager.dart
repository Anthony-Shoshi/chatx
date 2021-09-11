import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager {
  static String userIDKey = "USER_ID";
  static String userNameKey = "USER_NAME";
  static String userDisplayNameKey = "USER_DISPLAY_NAME";
  static String userEmailKey = "USER_EMAIL";
  static String userProfileKey = "USER_PROFILE";

  //Save user name
  Future<bool> saveUserID(String userID) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setString(userIDKey, userID);
  }

  //Save user name
  Future<bool> saveUserName(String userName) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setString(userNameKey, userName);
  }

  //Save user display name
  Future<bool> saveUserDisplayName(String userDisplayName) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setString(userDisplayNameKey, userDisplayName);
  }

  //Save user email
  Future<bool> saveUserEmail(String userEmail) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setString(userEmailKey, userEmail);
  }

  //Save user profile
  Future<bool> saveUserProfile(String userProfile) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.setString(userProfileKey, userProfile);
  }

  getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIDKey) ?? "";
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userDisplayNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfileKey);
  }
}
