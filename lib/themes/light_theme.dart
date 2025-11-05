import 'package:flutter/material.dart';

const double fontSize = 14;

final lightTheme = ThemeData(
  brightness: Brightness.light,
  cardColor: Colors.white,
  primaryColor: Colors.grey[100],
  hoverColor: Colors.grey.withValues(alpha:0.1),
  hintColor: Colors.blue,
  dividerColor: Colors.grey.shade300,
  fontFamily: 'SourceHanSans', // 使用思源黑体
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.black,
      fontSize: fontSize + 4,
      fontFamily: 'SourceHanSans', // 使用思源黑体
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
      fontSize: fontSize + 2,
      fontFamily: 'SourceHanSans', // 使用思源黑体
    ),
    bodySmall: TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      fontFamily: 'SourceHanSans', // 使用思源黑体
    ),
  ), 
  dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
);
