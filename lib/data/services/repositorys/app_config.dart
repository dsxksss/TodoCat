import 'package:isar/isar.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/services/database.dart';

class AppConfigRepository {
  static AppConfigRepository? _instance;
  Isar? _isar;
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
    _isar = db.isar;
    _isInitialized = true;
  }

  Isar get isar {
    if (_isar == null) {
      throw StateError('AppConfigRepository not initialized');
    }
    return _isar!;
  }

  Future<AppConfig?> read(String configName) async {
    return await isar.appConfigs
        .filter()
        .configNameEqualTo(configName)
        .findFirst();
  }

  Future<void> write(String configName, AppConfig config) async {
    await isar.writeTxn(() async {
      final existingConfig = await isar.appConfigs
          .filter()
          .configNameEqualTo(configName)
          .findFirst();
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      await isar.appConfigs.put(config);
    });
  }

  Future<void> update(String configName, AppConfig config) async {
    await write(configName, config);
  }
}
