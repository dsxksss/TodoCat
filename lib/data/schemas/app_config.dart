import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' as material;

/// AppConfig 数据模型
/// 注意：已迁移到 Drift，不再使用 Isar 注解
class AppConfig {
  int? id;
  late String configName;

  late bool isDarkMode;
  late String languageCode;
  late String countryCode;
  late bool emailReminderEnabled;
  late bool isDebugMode;
  String? backgroundImagePath; // 背景图片路径
  int? primaryColorValue; // 主题色值
  double backgroundImageOpacity = 0.15; // 背景图片透明度 (0.0-1.0)
  double backgroundImageBlur = 0.0; // 背景图片模糊度
  bool backgroundAffectsNavBar = false; // 背景是否影响导航栏

  // 默认构造函数
  AppConfig();

  // 命名构造函数用于创建实例
  factory AppConfig.create({
    required String configName,
    required bool isDarkMode,
    required Locale locale,
    required bool emailReminderEnabled,
    required bool isDebugMode,
    String? backgroundImagePath,
    int? primaryColorValue,
    double backgroundImageOpacity = 0.15,
    double backgroundImageBlur = 0.0,
    bool backgroundAffectsNavBar = false,
  }) {
    return AppConfig()
      ..configName = configName
      ..isDarkMode = isDarkMode
      ..languageCode = locale.languageCode
      ..countryCode = locale.countryCode ?? ''
      ..emailReminderEnabled = emailReminderEnabled
      ..isDebugMode = isDebugMode
      ..backgroundImagePath = backgroundImagePath
      ..primaryColorValue = primaryColorValue
      ..backgroundImageOpacity = backgroundImageOpacity
      ..backgroundImageBlur = backgroundImageBlur
      ..backgroundAffectsNavBar = backgroundAffectsNavBar;
  }

  // locale 计算属性
  Locale get locale => Locale(languageCode, countryCode);
  
  // 获取主题色
  material.Color? get primaryColor => primaryColorValue != null 
      ? material.Color(primaryColorValue!)
      : null;

  // 更新 Locale 的方法
  void updateLocale(Locale newLocale) {
    languageCode = newLocale.languageCode;
    countryCode = newLocale.countryCode ?? '';
  }

  // 复制方法
  AppConfig copyWith({
    String? configName,
    bool? isDarkMode,
    Locale? locale,
    bool? emailReminderEnabled,
    bool? isDebugMode,
    String? backgroundImagePath,
    int? primaryColorValue,
    double? backgroundImageOpacity,
    double? backgroundImageBlur,
    bool? backgroundAffectsNavBar,
  }) {
    return AppConfig()
      ..configName = configName ?? this.configName
      ..isDarkMode = isDarkMode ?? this.isDarkMode
      ..languageCode = locale?.languageCode ?? languageCode
      ..countryCode = locale?.countryCode ?? countryCode
      ..emailReminderEnabled = emailReminderEnabled ?? this.emailReminderEnabled
      ..isDebugMode = isDebugMode ?? this.isDebugMode
      ..backgroundImagePath = backgroundImagePath ?? this.backgroundImagePath
      ..primaryColorValue = primaryColorValue ?? this.primaryColorValue
      ..backgroundImageOpacity = backgroundImageOpacity ?? this.backgroundImageOpacity
      ..backgroundImageBlur = backgroundImageBlur ?? this.backgroundImageBlur
      ..backgroundAffectsNavBar = backgroundAffectsNavBar ?? this.backgroundAffectsNavBar;
  }

  // JSON序列化
  Map<String, dynamic> toJson() {
    return {
      'configName': configName,
      'isDarkMode': isDarkMode,
      'languageCode': languageCode,
      'countryCode': countryCode,
      'emailReminderEnabled': emailReminderEnabled,
      'isDebugMode': isDebugMode,
      'backgroundImagePath': backgroundImagePath,
      'primaryColorValue': primaryColorValue,
      'backgroundImageOpacity': backgroundImageOpacity,
      'backgroundImageBlur': backgroundImageBlur,
      'backgroundAffectsNavBar': backgroundAffectsNavBar,
    };
  }

  // JSON反序列化
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig()
      ..configName = json['configName'] as String
      ..isDarkMode = json['isDarkMode'] as bool
      ..languageCode = json['languageCode'] as String
      ..countryCode = json['countryCode'] as String
      ..emailReminderEnabled = json['emailReminderEnabled'] as bool
      ..isDebugMode = json['isDebugMode'] as bool
      ..backgroundImagePath = json['backgroundImagePath'] as String?
      ..primaryColorValue = json['primaryColorValue'] as int?
      ..backgroundImageOpacity = json['backgroundImageOpacity'] as double? ?? 0.15
      ..backgroundImageBlur = json['backgroundImageBlur'] as double? ?? 0.0
      ..backgroundAffectsNavBar = json['backgroundAffectsNavBar'] as bool? ?? false;
  }
}
