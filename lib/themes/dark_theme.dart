import 'package:flutter/material.dart';

const double fontSize = 14;

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  cardColor: const Color.fromRGBO(14, 17, 23, 1),
  primaryColor: Colors.black,
  hintColor: Colors.blue,
  dividerColor: Colors.grey.shade800,
  dialogBackgroundColor: const Color.fromRGBO(14, 17, 23, 1),
  inputDecorationTheme:
      const InputDecorationTheme(fillColor: Color.fromRGBO(26, 30, 37, 1)),
  scaffoldBackgroundColor: Colors.black,
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
