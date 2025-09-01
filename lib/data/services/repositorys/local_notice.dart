import 'package:isar/isar.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/services/database.dart';

class LocalNoticeRepository {
  static LocalNoticeRepository? _instance;
  late final Isar _isar;

  LocalNoticeRepository._();

  static Future<LocalNoticeRepository> getInstance() async {
    _instance ??= LocalNoticeRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final db = await Database.getInstance();
    _isar = db.isar;
  }

  Future<void> write(String id, LocalNotice notice) async {
    await _isar.writeTxn(() async {
      await _isar.localNotices.put(notice);
    });
  }

  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      final notice =
          await _isar.localNotices.filter().noticeIdEqualTo(id).findFirst();
      if (notice != null) {
        await _isar.localNotices.delete(notice.id);
      }
    });
  }

  Future<LocalNotice?> read(String id) async {
    return await _isar.localNotices.filter().noticeIdEqualTo(id).findFirst();
  }

  Future<List<LocalNotice>> readAll() async {
    return await _isar.localNotices.where().findAll();
  }
}
