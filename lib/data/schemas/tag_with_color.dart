import 'package:flutter/material.dart';

/// 带颜色的标签数据结构
class TagWithColor {
  late String name;
  late int colorValue;

  TagWithColor({
    required String name,
    required Color color,
  }) : name = name,
       colorValue = color.value;

  /// 获取颜色
  Color get color => Color(colorValue);

  /// 设置颜色
  set color(Color color) => colorValue = color.value;

  /// 从JSON创建
  factory TagWithColor.fromJson(Map<String, dynamic> json) {
    return TagWithColor(
      name: json['name'] as String,
      color: Color(json['color'] as int),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': colorValue,
    };
  }

  /// 从字符串创建（兼容旧数据）
  factory TagWithColor.fromString(String tagName, {Color? defaultColor}) {
    // 如果没有指定颜色，为不同标签分配不同颜色
    if (defaultColor == null) {
      final colors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.pink,
        Colors.indigo,
        Colors.amber,
        Colors.cyan,
        Colors.lime,
        Colors.deepOrange,
      ];
      
      // 根据标签名称的hashCode选择颜色，确保相同名称总是得到相同颜色
      final colorIndex = tagName.hashCode.abs() % colors.length;
      defaultColor = colors[colorIndex];
    }
    
    return TagWithColor(
      name: tagName,
      color: defaultColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagWithColor && other.name == name && other.colorValue == colorValue;
  }

  @override
  int get hashCode => name.hashCode ^ colorValue.hashCode;

  @override
  String toString() => 'TagWithColor(name: $name, color: $color)';
}
