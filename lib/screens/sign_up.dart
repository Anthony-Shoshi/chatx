import 'package:chatx/constants/colors.dart';
import 'package:chatx/services/authentication.dart';
import 'package:chatx/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
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
                Container(
                  child: Image.asset(
                    "assets/images/test.png",
                    width: screenWidth / 4,
                  ),
                ),
                SizedBox(
                  height: AppSizes.font18,
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
                  flex: 1,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSizes.font22),
                  width: screenWidth,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: Row(
                      children: [
                        Container(
                          child: Image.network(
                            'http://pngimg.com/uploads/google/google_PNG19635.png',
                            width: screenWidth / 9,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Sign Up with Google",
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  fontSize: AppSizes.font16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Authentication().signUpWithGoogle();
                    },
                  ),
                ),
                Spacer(
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
