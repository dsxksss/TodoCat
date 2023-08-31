import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final double fontSize = 24.sp;

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.grey[100],
  hintColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Colors.black,
      fontSize: fontSize + 8,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
      fontSize: fontSize + 4.sp,
    ),
    bodySmall: TextStyle(
      color: Colors.black,
      fontSize: fontSize,
    ),
  ),
);
