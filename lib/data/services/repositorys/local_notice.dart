import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/services/database.dart';

class LocalNoticeRepository {
  static LocalNoticeRepository? _instance;
  late final Box<LocalNotice> _box;

  LocalNoticeRepository._();

  static Future<LocalNoticeRepository> getInstance() async {
    _instance ??= LocalNoticeRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final db = await Database.getInstance();
    _box = await db.getBox<LocalNotice>('localNotices');
  }

  Future<void> write(String id, LocalNotice notice) async {
    await _box.put(id, notice);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<LocalNotice?> read(String id) async {
    return _box.get(id);
  }

  Future<List<LocalNotice>> readAll() async {
    return _box.values.toList();
  }
}
