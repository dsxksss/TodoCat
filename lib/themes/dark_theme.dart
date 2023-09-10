import 'package:flutter/material.dart';

const double fontSize = 14;

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  cardColor: Colors.grey.shade900,
  primaryColor: Colors.black,
  hintColor: Colors.blue,
  dividerColor: Colors.grey.shade800,
  inputDecorationTheme: const InputDecorationTheme(fillColor: Colors.black),
  scaffoldBackgroundColor: Colors.black87,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: fontSize + 4,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontSize: fontSize + 2,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
      fontSize: fontSize,
    ),
  ),
);
