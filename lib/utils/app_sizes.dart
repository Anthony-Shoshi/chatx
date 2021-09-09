import 'package:flutter/material.dart';
import 'package:get/get.dart';

Orientation currentOrientation = MediaQuery.of(Get.context!).orientation;

var screenSize = currentOrientation == Orientation.portrait
    ? Get.size.height
    : Get.size.width;

class AppSizes {
  static final font10 = 1.3 * screenSize / 100;
  static final font12 = 1.5 * screenSize / 100;
  static final font13 = 1.6 * screenSize / 100;
  static final font14 = 1.8 * screenSize / 100;
  static final font15 = 1.9 * screenSize / 100;
  static final font16 = 2.0 * screenSize / 100;
  static final font18 = 2.3 * screenSize / 100;
  static final font22 = 2.8 * screenSize / 100;
  static final font25 = 3.5 * screenSize / 100;
  static final font30 = 4.2 * screenSize / 100;
}
