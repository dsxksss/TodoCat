import 'package:isar/isar.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/services/database.dart';

class AppConfigRepository {
  static AppConfigRepository? _instance;
  late final Isar _isar;

  AppConfigRepository._();

  static Future<AppConfigRepository> getInstance() async {
    _instance ??= AppConfigRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final db = await Database.getInstance();
    _isar = db.isar;
  }

  Future<AppConfig?> read(String configName) async {
    return await _isar.appConfigs
        .filter()
        .configNameEqualTo(configName)
        .findFirst();
  }

  Future<void> write(String configName, AppConfig config) async {
    await _isar.writeTxn(() async {
      final existingConfig = await _isar.appConfigs
          .filter()
          .configNameEqualTo(configName)
          .findFirst();
      if (existingConfig != null) {
        config.id = existingConfig.id;
      }
      await _isar.appConfigs.put(config);
    });
  }

  Future<void> update(String configName, AppConfig config) async {
    await write(configName, config);
  }
}
