import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Tasks, Todos, AppConfigs, LocalNotices, NotificationHistorys, CustomTemplates])
class AppDatabase extends _$AppDatabase {
  static final _logger = Logger();
  static AppDatabase? _instance;

  AppDatabase() : super(_openConnection());

  static Future<AppDatabase> getInstance() async {
    _instance ??= AppDatabase();
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

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
      },
    );
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

