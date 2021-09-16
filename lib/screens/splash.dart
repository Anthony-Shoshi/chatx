import 'dart:async';
import 'package:chatx/constants/colors.dart';
import 'package:chatx/helpers/shared_pref_manager.dart';
import 'package:chatx/screens/home.dart';
import 'package:chatx/screens/sign_up.dart';
import 'package:chatx/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String myid = "";

  void gotoNext() async {
    myid = await SharedPrefManager().getUserID();
    Timer(Duration(seconds: 2), () async {
      if (myid != "") {
        Get.offAll(() => HomeScreen());
      } else {
        Get.offAll(() => SignUpScreen());
      }
    });
  }

  @override
  void initState() {
    gotoNext();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            PRIMARY_COLOR,
            SECONDARY_COLOR,
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              children: [
                Spacer(
                  flex: 1,
                ),
                Image.asset(
                  'assets/images/test.png',
                  height: screenWidth / 4,
                ),
                SizedBox(
                  height: AppSizes.font22,
                ),
                Text(
                  "ChatX",
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.font22,
                    ),
                  ),
                ),
                Spacer(
                  flex: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
