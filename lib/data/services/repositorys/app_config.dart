import 'package:TodoCat/data/schemas/app_config.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:TodoCat/data/database/database.dart' as drift_db;
import 'package:TodoCat/data/database/converters.dart';

class AppConfigRepository {
  static AppConfigRepository? _instance;
  drift_db.AppDatabase? _db;
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
    final dbService = await Database.getInstance();
    _db = dbService.appDatabase;
    _isInitialized = true;
  }

  drift_db.AppDatabase get db {
    if (_db == null) {
      throw StateError('AppConfigRepository not initialized');
    }
    return _db!;
  }

  Future<AppConfig?> read(String configName) async {
    final row = await (db.select(db.appConfigs)
          ..where((t) => t.configName.equals(configName)))
        .getSingleOrNull();
    
    return row != null ? DbConverters.appConfigFromRow(row) : null;
  }

  Future<void> write(String configName, AppConfig config) async {
    await db.transaction(() async {
      final existing = await (db.select(db.appConfigs)
            ..where((t) => t.configName.equals(configName)))
          .getSingleOrNull();
      
      final companion = DbConverters.appConfigToCompanion(config, isUpdate: existing != null);
      
      if (existing != null) {
        config.id = existing.id;
        await (db.update(db.appConfigs)..where((t) => t.id.equals(existing.id)))
            .write(companion);
      } else {
        final id = await db.into(db.appConfigs).insert(companion);
        config.id = id;
      }
    });
  }

  Future<void> update(String configName, AppConfig config) async {
    await write(configName, config);
  }
}
