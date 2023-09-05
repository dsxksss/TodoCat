import 'package:flutter/material.dart';

const double fontSize = 14;

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.grey[100],
  hintColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.black,
      fontSize: fontSize + 4,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
      fontSize: fontSize + 2,
    ),
    bodySmall: TextStyle(
      color: Colors.black,
      fontSize: fontSize,
    ),
  ),
);
