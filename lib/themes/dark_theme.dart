import 'package:flutter/material.dart';

const double fontSize = 14;

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  cardColor: const Color.fromRGBO(29, 35, 42, 1),
  primaryColor: Colors.black,
  hoverColor: Colors.grey.withValues(alpha:0.1),
  hintColor: Colors.blue,
  dividerColor: Colors.grey.shade800,
  fontFamily: 'SourceHanSans', // 使用思源黑体
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Color.fromRGBO(29, 35, 42, 1),
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(29, 35, 42, 1),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: fontSize + 4,
      fontFamily: 'SourceHanSans', // 使用思源黑体
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontSize: fontSize + 2,
      fontFamily: 'SourceHanSans', // 使用思源黑体
    ),
    bodySmall: TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontFamily: 'SourceHanSans', // 使用思源黑体
    ),
  ), 
  dialogTheme: const DialogThemeData(backgroundColor: Color.fromRGBO(29, 35, 42, 1)),
);
