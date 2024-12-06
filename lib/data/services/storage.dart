import 'package:hive/hive.dart';
import 'package:todo_cat/data/services/base_repository.dart';

abstract class Storage<T> implements BaseRepository<T> {
  Box<T>? box;

  @override
  Future<void> initialize(String boxName) async {
    box = await Hive.openBox<T>(boxName);
  }

  @override
  Future<T?> get(String key) async {
    return box?.get(key);
  }

  @override
  Future<List<T>> getAll() async {
    return box?.values.toList() ?? [];
  }

  // ... 其他方法实现
}
