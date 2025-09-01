import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

part 'app_config.g.dart';

@HiveType(typeId: 5)
class AppConfig extends HiveObject {
  @HiveField(0)
  late String configName;

  @HiveField(1)
  late bool isDarkMode;
  
  @HiveField(2)
  late String languageCode;
  
  @HiveField(3)
  late String countryCode;
  
  @HiveField(4)
  late bool emailReminderEnabled;
  
  @HiveField(5)
  late bool isDebugMode;

  // 默认构造函数
  AppConfig();

  // 命名构造函数用于创建实例
  factory AppConfig.create({
    required String configName,
    required bool isDarkMode,
    required Locale locale,
    required bool emailReminderEnabled,
    required bool isDebugMode,
  }) {
    return AppConfig()
      ..configName = configName
      ..isDarkMode = isDarkMode
      ..languageCode = locale.languageCode
      ..countryCode = locale.countryCode ?? ''
      ..emailReminderEnabled = emailReminderEnabled
      ..isDebugMode = isDebugMode;
  }

  // 将 locale 作为计算属性
  Locale get locale => Locale(languageCode, countryCode);

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
  }) {
    return AppConfig()
      ..configName = configName ?? this.configName
      ..isDarkMode = isDarkMode ?? this.isDarkMode
      ..languageCode = locale?.languageCode ?? languageCode
      ..countryCode = locale?.countryCode ?? countryCode
      ..emailReminderEnabled = emailReminderEnabled ?? this.emailReminderEnabled
      ..isDebugMode = isDebugMode ?? this.isDebugMode;
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
      ..isDebugMode = json['isDebugMode'] as bool;
  }
}
