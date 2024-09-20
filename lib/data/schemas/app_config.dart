import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part "app_config.g.dart";
part 'app_config.freezed.dart';

@HiveType(typeId: 6)
@unfreezed
class AppConfig with _$AppConfig {
  factory AppConfig({
    @HiveField(0) required String configName,
    @HiveField(1) required bool isDarkMode,
    @HiveField(2) required Locale locale,
    @HiveField(3) required bool emailReminderEnabled,
    @HiveField(4) required bool isDebugMode,
  }) = _AppConfig;
}
