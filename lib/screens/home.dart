import 'package:chatx/screens/sign_up.dart';
import 'package:chatx/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          Authentication().signOut().then((value) {
            Get.to(() => SignUpScreen());
          });
        },
        child: Center(
          child: Container(
            color: Colors.green,
            height: 100.0,
            width: 100.0,
          ),
        ),
      ),
    );
  }
}
