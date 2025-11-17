import 'package:flutter/material.dart';

const double fontSize = 14;

final lightTheme = ThemeData(
  brightness: Brightness.light,
  cardColor: Colors.white,
  primaryColor: Colors.grey[100],
  hoverColor: Colors.grey.withValues(alpha:0.1),
  hintColor: Colors.blue.shade700,
  dividerColor: Colors.grey.shade300,
  fontFamily: 'SourceHanSans', // 使用思源黑体
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  // 统一按钮颜色为蓝色
  colorScheme: ColorScheme.light(
    primary: Colors.blue.shade700,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
    ),
  ),
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
