import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/services/database.dart';
import 'package:todo_cat/data/database/database.dart' as drift_db;
import 'package:todo_cat/data/database/converters.dart';

class AppConfigRepository {
  static AppConfigRepository? _instance;
  drift_db.AppDatabase? _db;
  bool _isInitialized = false;

  AppConfigRepository._();

  static Future<AppConfigRepository> getInstance() async {
    _instance ??= AppConfigRepository._();
    // 总是调用 _init() 来检查数据库连接是否有效
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    if (_isInitialized && _db != null) {
      // 检查数据库是否仍然有效
      try {
        // 尝试执行一个简单的查询来检查数据库连接
        await _db!.customSelect('SELECT 1').get();
        return; // 数据库连接有效，不需要重新初始化
      } catch (e) {
        // 数据库连接已关闭，需要重新初始化
        _isInitialized = false;
        _db = null;
      }
    }
    
    final dbService = await Database.getInstance();
    _db = dbService.appDatabase;
    _isInitialized = true;
  }

  /// 强制重置 Repository（用于数据库重置后）
  static void reset() {
    if (_instance != null) {
      _instance!._isInitialized = false;
      _instance!._db = null;
    }
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
