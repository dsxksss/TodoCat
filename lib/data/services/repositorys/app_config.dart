import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/data/schemas/app_config.dart';

import '../strorage.dart';

class AppConfigRepository extends Strorage<AppConfig> {
  late Box<AppConfig> _box;
  final configKey = 'appConfigx';

  // 私有构造函数
  AppConfigRepository._();

  // 单例实例
  static AppConfigRepository? _instance;

  static Future<AppConfigRepository> getInstance() async {
    _instance ??= AppConfigRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    // 开启数据盒
    await Hive.openBox<AppConfig>(configKey);
    _box = Hive.box(configKey);
  }

  @override
  void onClose() {
    _box.close();
    super.onClose();
  }

  @override
  AppConfig? read(String key) {
    return _box.get(key);
  }

  @override
  void write(String key, AppConfig value) async {
    if (!has(key)) {
      await _box.put(key, value);
    }
  }

  @override
  void delete(String key) {
    _box.delete(key);
  }

  @override
  Future<List<AppConfig>> readAll() async {
    return _box.values.toList();
  }

  @override
  void writeMany(List<AppConfig> values) {
    for (var element in values) {
      write(element.configName, element);
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
  void update(String key, AppConfig value) async {
    await _box.put(key, value);
  }

  @override
  void updateMany(List<AppConfig> values) {
    for (var element in values) {
      update(element.configName, element);
    }
  }
}
