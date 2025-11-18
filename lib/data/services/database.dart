import 'package:TodoCat/data/database/database.dart' as db;
import 'package:logger/logger.dart';
import 'package:TodoCat/data/services/repositorys/task.dart';
import 'package:TodoCat/data/services/repositorys/app_config.dart';
import 'package:TodoCat/data/services/repositorys/workspace.dart';
import 'package:TodoCat/data/services/repositorys/custom_template.dart';
import 'package:TodoCat/data/services/repositorys/notification_history.dart';
import 'package:TodoCat/data/services/repositorys/local_notice.dart';

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
      // 检查数据库连接是否仍然有效
      try {
        // 尝试执行一个简单的查询来验证连接
        await _appDatabase!.customSelect('SELECT 1').get();
        _logger.d('Reusing existing database instance');
        return;
      } catch (e) {
        // 如果连接无效，重置并重新初始化
        _logger.w('Existing database instance is invalid, reinitializing...');
        _appDatabase = null;
      }
    }

    _logger.d('Initializing new database instance');
    // 确保获取新的数据库实例（重置后需要重新创建）
    _appDatabase = await db.AppDatabase.getInstance();
    
    // 验证新实例是否可用（最多重试3次）
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        await _appDatabase!.customSelect('SELECT 1').get();
        _logger.d('Database initialized successfully');
        return;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          _logger.e('Failed to verify database connection after $maxRetries attempts: $e');
          throw StateError('Failed to initialize database: $e');
        }
        _logger.w('Database connection verification failed (attempt $retryCount/$maxRetries), retrying...');
        // 等待一小段时间后重试
        await Future.delayed(Duration(milliseconds: 100 * retryCount));
      }
    }
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

  /// 重置数据库（删除数据库文件并重新创建，清除所有残留数据）
  Future<void> resetDatabase() async {
    _logger.w('Resetting database...');
    
    // 1. 先重置所有 Repository 的缓存（这会清空它们的数据库引用）
    // 这很重要，必须在关闭数据库连接之前完成，确保没有 Repository 持有数据库引用
    _resetAllRepositories();
    
    // 2. 关闭当前数据库连接
    await close();
    
    // 3. 等待一段时间，确保所有文件句柄都被释放
    // Windows 系统需要更长时间来释放文件句柄
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 4. 重置 AppDatabase（删除文件并重新创建）
    await db.AppDatabase.resetDatabase();
    
    // 5. 强制重新初始化数据库服务（确保获取新的实例）
    _appDatabase = null;
    
    // 6. 等待一小段时间，确保文件系统操作完成
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 7. 重新初始化
    await _init();
    
    // 8. 再次验证连接
    try {
      await _appDatabase!.customSelect('SELECT 1').get();
      _logger.d('Database reset completed and verified');
    } catch (e) {
      _logger.e('Database reset verification failed: $e');
      // 如果验证失败，抛出错误
      throw StateError('Failed to reset database: $e');
    }
  }

  /// 重置所有 Repository 的缓存
  void _resetAllRepositories() {
    try {
      _logger.d('Resetting all repository caches...');
      
      // 重置所有 Repository 的缓存，强制它们重新获取新的数据库实例
      TaskRepository.reset();
      AppConfigRepository.reset();
      WorkspaceRepository.reset();
      CustomTemplateRepository.reset();
      NotificationHistoryRepository.reset();
      LocalNoticeRepository.reset();
      
      _logger.d('All repository caches reset');
    } catch (e) {
      _logger.w('Error resetting repositories: $e');
    }
  }
}
