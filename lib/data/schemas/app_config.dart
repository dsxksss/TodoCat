import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';

part 'app_config.g.dart';

@collection
class AppConfig {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String configName;

  late bool isDarkMode;
  late String languageCode;
  late String countryCode;
  late bool emailReminderEnabled;
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

  // 将 locale 标记为忽略，因为它是计算属性
  @ignore
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
}
