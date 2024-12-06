import 'package:flutter/material.dart';

const double fontSize = 14;

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  cardColor: const Color.fromRGBO(29, 35, 42, 1),
  primaryColor: Colors.black,
  hoverColor: Colors.grey.withOpacity(0.1),
  hintColor: Colors.blue,
  dividerColor: Colors.grey.shade800,
  dialogBackgroundColor: const Color.fromRGBO(29, 35, 42, 1),
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Color.fromRGBO(29, 35, 42, 1),
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(29, 35, 42, 1),
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
