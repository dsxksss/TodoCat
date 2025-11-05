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
    final dbService = await Database.getInstance();
    _db = dbService.appDatabase;
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
