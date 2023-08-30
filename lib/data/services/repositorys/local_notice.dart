import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/services/strorage.dart';
import 'package:todo_cat/env.dart';

class LocalNoticeRepository extends Strorage<LocalNotice> {
  late Box<LocalNotice> _box;
  final noticeKey = 'localNoticesx';

  // 私有构造函数
  LocalNoticeRepository._();

  // 单例实例
  static LocalNoticeRepository? _instance;

  static Future<LocalNoticeRepository> getInstance() async {
    if (_instance == null) {
      _instance = LocalNoticeRepository._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    // 开启数据盒
    await Hive.openBox<LocalNotice>(noticeKey);
    _box = Hive.box(noticeKey);

    if (isDebugMode) {
      await _box.clear();
    }
  }

  @override
  void onClose() {
    _box.close();
    super.onClose();
  }

  @override
  LocalNotice? read(String key) {
    return _box.get(key);
  }

  @override
  void write(String key, LocalNotice value) async {
    if (!has(key)) {
      await _box.put(key, value);
    }
  }

  @override
  void delete(String key) {
    _box.delete(key);
  }

  @override
  Future<List<LocalNotice>> readAll() async {
    return _box.values.toList();
  }

  @override
  void writeMany(List<LocalNotice> values) {
    for (var element in values) {
      write(element.id, element);
    }
  }

  @override
  bool has(String key) {
    return _box.containsKey(key);
  }

  bool hasNot(String key) {
    return !_box.containsKey(key);
  }

  @override
  void update(String key, LocalNotice value) async {
    await _box.put(key, value);
  }

  @override
  void updateMany(List<LocalNotice> values) {
    for (var element in values) {
      update(element.id, element);
    }
  }
}
