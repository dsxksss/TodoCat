import 'package:flutter/material.dart';

const double fontSize = 14;

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  hintColor: Colors.blue,
  scaffoldBackgroundColor: Colors.grey[900],
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
