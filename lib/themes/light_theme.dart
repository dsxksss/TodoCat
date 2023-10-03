import 'package:flutter/material.dart';

const double fontSize = 14;

final lightTheme = ThemeData(
  brightness: Brightness.light,
  cardColor: Colors.white,
  primaryColor: Colors.grey[100],
  hintColor: Colors.blue,
  dividerColor: Colors.grey.shade300,
  dialogBackgroundColor: Colors.white,
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Colors.white,
  ),
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
