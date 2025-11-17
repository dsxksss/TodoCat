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

  /// 清除所有数据
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
}

