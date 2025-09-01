import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/services/database.dart';

class AppConfigRepository {
  static AppConfigRepository? _instance;
  Box<AppConfig>? _box;
  bool _isInitialized = false;

  AppConfigRepository._();

  static Future<AppConfigRepository> getInstance() async {
    _instance ??= AppConfigRepository._();
    if (!_instance!._isInitialized) {
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    final db = await Database.getInstance();
    _box = await db.getBox<AppConfig>('appConfigs');
    _isInitialized = true;
  }

  Box<AppConfig> get box {
    if (_box == null) {
      throw StateError('AppConfigRepository not initialized');
    }
    return _box!;
  }

  Future<AppConfig?> read(String configName) async {
    return box.get(configName);
  }

  Future<void> write(String configName, AppConfig config) async {
    await box.put(configName, config);
  }

  Future<void> update(String configName, AppConfig config) async {
    await write(configName, config);
  }
}
