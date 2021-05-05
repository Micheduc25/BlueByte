import 'package:flutter/material.dart';

class AppColors {
  static Color purpleLight = Color(0xff0a0ab7);
  // static Color purpleNormal = Color(0xff7a37aa);
  static Color purpleNormal = Color(0xff000066);
  static Color purpleDark = Color(0xff000049);

  static Color colorFromHexString(String color) {
    String buffer;

    buffer = color.split("x")[1].split(")")[0];

    assert(buffer.length == 8);
    final intColor = int.parse(buffer, radix: 16);

    return Color(intColor);
  }
}

class AppFonts {
  static String crystalCathedral = "crystal_cathedral";
  static String sansSerrif = "sans serif";
}
