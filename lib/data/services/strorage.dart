import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class Storage<T> extends GetxService {
  Box<T>? box;

  Future<void> init(String boxName) async {
    await Hive.openBox<T>(boxName);
    box = Hive.box(boxName);
  }

  @override
  void onClose() {
    box?.close();
    super.onClose();
  }

  T? read(String key) => box?.get(key);

  Future<void> write(String key, T value) async {
    await box?.put(key, value);
  }

  Future<void> delete(String key) async {
    await box?.delete(key);
  }

  Future<List<T>> readAll() async {
    return box?.values.toList() ?? [];
  }

  Future<void> writeMany(
      List<T> values, String Function(T) keyExtractor) async {
    for (var element in values) {
      await write(keyExtractor(element), element);
    }
  }

  bool has(String key) => box?.containsKey(key) ?? false;

  bool hasNot(String key) => !has(key);

  Future<void> update(String key, T value) async {
    await box?.put(key, value);
  }

  Future<void> updateMany(
      List<T> values, String Function(T) keyExtractor) async {
    for (var element in values) {
      await update(keyExtractor(element), element);
    }
  }
}
