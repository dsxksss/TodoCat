import 'package:TodoCat/data/schemas/local_notice.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:TodoCat/data/database/database.dart' as drift_db;
import 'package:TodoCat/data/database/converters.dart';

class LocalNoticeRepository {
  static LocalNoticeRepository? _instance;
  drift_db.AppDatabase? _db;

  LocalNoticeRepository._();

  static Future<LocalNoticeRepository> getInstance() async {
    _instance ??= LocalNoticeRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    if (_db != null) {
      // 检查数据库是否仍然有效
      try {
        // 尝试执行一个简单的查询来检查数据库连接
        await _db!.customSelect('SELECT 1').get();
        return; // 数据库连接有效，不需要重新初始化
      } catch (e) {
        // 数据库连接已关闭，需要重新初始化
        _db = null;
      }
    }
    
    final dbService = await Database.getInstance();
    _db = dbService.appDatabase;
  }

  /// 强制重置 Repository（用于数据库重置后）
  static void reset() {
    if (_instance != null) {
      _instance!._db = null;
    }
  }

  drift_db.AppDatabase get db {
    if (_db == null) {
      throw StateError('LocalNoticeRepository not initialized');
    }
    return _db!;
  }

  Future<void> write(String id, LocalNotice notice) async {
    await db.transaction(() async {
      final existing = await (db.select(db.localNotices)
            ..where((t) => t.noticeId.equals(id)))
          .getSingleOrNull();
      
      final companion = DbConverters.localNoticeToCompanion(notice);
      
      if (existing != null) {
        notice.id = existing.id;
        await (db.update(db.localNotices)..where((t) => t.id.equals(existing.id)))
            .write(companion);
      } else {
        final insertedId = await db.into(db.localNotices).insert(companion);
        notice.id = insertedId;
      }
    });
  }

  Future<void> delete(String id) async {
    await db.transaction(() async {
      final notice = await (db.select(db.localNotices)
            ..where((t) => t.noticeId.equals(id)))
          .getSingleOrNull();
      
      if (notice != null) {
        await (db.delete(db.localNotices)..where((t) => t.id.equals(notice.id))).go();
      }
    });
  }

  Future<LocalNotice?> read(String id) async {
    final row = await (db.select(db.localNotices)
          ..where((t) => t.noticeId.equals(id)))
        .getSingleOrNull();
    return row != null ? DbConverters.localNoticeFromRow(row) : null;
  }

  Future<List<LocalNotice>> readAll() async {
    final rows = await db.select(db.localNotices).get();
    return rows.map((row) => DbConverters.localNoticeFromRow(row)).toList();
  }
}
