import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Workspaces, Tasks, Todos, AppConfigs, LocalNotices, NotificationHistorys, CustomTemplates])
class AppDatabase extends _$AppDatabase {
  static final _logger = Logger();
  static AppDatabase? _instance;

  AppDatabase() : super(_openConnection());

  static Future<AppDatabase> getInstance() async {
    _instance ??= AppDatabase();
    return _instance!;
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        _logger.d('Database created');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 处理数据库迁移
        _logger.d('Database upgraded from $from to $to');
        if (from < 2) {
          // 迁移到版本2：添加工作空间支持
          await m.createTable(workspaces);
          // 为现有Tasks添加workspaceId字段（默认为'default'）
          await m.addColumn(tasks, tasks.workspaceId);
        }
        if (from < 3) {
          // 迁移到版本3：添加 showTodoImage 字段
          await m.addColumn(appConfigs, appConfigs.showTodoImage);
        }
      },
      beforeOpen: (details) async {
        // 在数据库打开后，确保默认工作空间存在
        if (details.wasCreated || details.versionNow >= 2) {
          await _ensureDefaultWorkspace();
        }
      },
    );
  }

  /// 确保默认工作空间存在
  Future<void> _ensureDefaultWorkspace() async {
    try {
      final existing = await (select(workspaces)
            ..where((w) => w.uuid.equals('default')))
          .getSingleOrNull();
      
      if (existing == null) {
        final createdAt = DateTime.now().millisecondsSinceEpoch;
        await into(workspaces).insert(WorkspacesCompanion.insert(
          uuid: 'default',
          name: 'Default',
          createdAt: createdAt,
          order: const Value(0),
          deletedAt: const Value(0),
        ));
        _logger.d('Default workspace created');
      }
    } catch (e) {
      _logger.e('Error ensuring default workspace: $e');
    }
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'todocat.db'));
      _logger.d('Database path: ${file.path}');
      return NativeDatabase(file);
    });
  }

  /// 获取数据库文件路径
  static Future<String> _getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'todocat.db');
  }

  /// 清除所有数据（仅删除表数据）
  Future<void> clearAllData() async {
    _logger.w('Clearing all data from database...');
    await transaction(() async {
      await delete(workspaces).go();
      await delete(tasks).go();
      await delete(todos).go();
      await delete(appConfigs).go();
      await delete(localNotices).go();
      await delete(notificationHistorys).go();
      await delete(customTemplates).go();
    });
    _logger.d('All data cleared successfully');
  }

  /// 重置数据库（删除数据库文件并重新创建）
  static Future<void> resetDatabase() async {
    _logger.w('Resetting database by deleting file and recreating...');
    
    // 关闭当前实例
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
    }
    
    // 删除数据库文件（带重试机制，处理文件被占用的情况）
    final dbPath = await _getDatabasePath();
    await _deleteFileWithRetry(dbPath, 'Database file', maxRetries: 5);
    await _deleteFileWithRetry('$dbPath-shm', 'Database shm file', maxRetries: 3);
    await _deleteFileWithRetry('$dbPath-wal', 'Database wal file', maxRetries: 3);
    
    // 重新创建数据库实例（会在首次访问时创建新文件）
    _instance = AppDatabase();
    
    // 强制打开数据库连接（LazyDatabase 需要首次访问才会打开）
    try {
      await _instance!.customSelect('SELECT 1').get();
      _logger.d('Database reset completed, new instance created and verified');
    } catch (e) {
      _logger.e('Failed to verify new database instance: $e');
      // 即使验证失败，也继续（可能数据库文件还没有完全创建）
      _logger.d('Database reset completed, new instance created (verification deferred)');
    }
  }

  /// 关闭数据库连接
  Future<void> close() async {
    await executor.close();
    _logger.d('Database connection closed');
  }

  /// 带重试机制的文件删除方法
  /// 用于处理文件被占用的情况（特别是在 Windows 系统上）
  static Future<void> _deleteFileWithRetry(
    String filePath,
    String fileDescription, {
    int maxRetries = 5,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return; // 文件不存在，无需删除
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await file.delete();
        _logger.d('$fileDescription deleted: $filePath');
        return; // 删除成功
      } catch (e) {
        if (attempt < maxRetries) {
          // 等待一段时间后重试，每次等待时间递增
          final delayMs = 100 * attempt;
          _logger.w(
            'Failed to delete $fileDescription (attempt $attempt/$maxRetries): $e. Retrying in ${delayMs}ms...',
          );
          await Future.delayed(Duration(milliseconds: delayMs));
        } else {
          // 最后一次尝试失败，记录错误但不抛出异常
          // 因为即使删除失败，我们也可以继续创建新数据库
          _logger.e(
            'Failed to delete $fileDescription after $maxRetries attempts: $e. Continuing...',
          );
        }
      }
    }
  }
}

