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
  String myIL = "";

  void gotoNext() async {
    myid = await SharedPrefManager().getUserID();
    Timer(Duration(seconds: 3), () async {
      if (myid != "") {
        Get.to(() => HomeScreen());
      } else {
        Get.to(() => SignUpScreen());
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: AppSizes.font30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: screenWidth / 4,
                      width: screenWidth / 4,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: AssetImage('assets/images/test.png'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
