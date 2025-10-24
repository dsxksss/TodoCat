import 'package:flutter/material.dart';

/// 字体工具类，提供统一的中文字体配置
class FontUtils {
  static const String fontFamily = 'SourceHanSans'; // 使用思源黑体
  
  /// 获取标准字体样式
  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      height: height,
    );
  }
  
  /// 获取粗体样式
  static TextStyle getBoldStyle({
    double? fontSize,
    Color? color,
    double? height,
  }) {
    return getTextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      height: height,
    );
  }
  
  /// 获取中等粗细样式
  static TextStyle getMediumStyle({
    double? fontSize,
    Color? color,
    double? height,
  }) {
    return getTextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      height: height,
    );
  }
  
  /// 获取细体样式
  static TextStyle getLightStyle({
    double? fontSize,
    Color? color,
    double? height,
  }) {
    return getTextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      color: color,
      height: height,
    );
  }
}
