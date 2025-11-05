import 'package:TodoCat/data/database/database.dart' as db;
import 'package:logger/logger.dart';

/// 数据库服务封装
/// 提供对 Drift 数据库的访问
class Database {
  static final _logger = Logger();
  static Database? _instance;
  static db.AppDatabase? _appDatabase;

  Database._();

  static Future<Database> getInstance() async {
    _instance ??= Database._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    if (_appDatabase != null) {
      _logger.d('Reusing existing database instance');
      return;
    }

    _logger.d('Initializing new database instance');
    _appDatabase = await db.AppDatabase.getInstance();
    _logger.d('Database initialized successfully');
  }

  db.AppDatabase get appDatabase {
    if (_appDatabase == null) {
      throw StateError('Database not initialized');
    }
    return _appDatabase!;
  }

  Future<void> close() async {
    if (_appDatabase != null) {
      await _appDatabase!.close();
      _appDatabase = null;
      _logger.d('Database closed');
    }
  }

  /// 清除所有数据（保留数据库结构）
  Future<void> clearAllData() async {
    if (_appDatabase == null) {
      throw StateError('Database not initialized');
    }
    
    await _appDatabase!.clearAllData();
  }
}
