import 'package:todo_cat/app/core/utils/keys.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/services/strorage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskRepository extends Strorage<Task> {
  late Box<Task> _box;

  Future<TaskRepository> init() async {
    // 注册Hive数据模板
    Hive.registerAdapter(TaskAdapter());
    // 开启数据盒
    await Hive.openBox<Task>(taskKey);
    _box = Hive.box(taskKey);
    return this;
  }

  @override
  Task? read(String key) {
    return _box.get(key);
  }

  @override
  void write(String key, Task value) {
    if (!_box.containsKey(key)) {
      _box.put(key, value);
    }
  }

  @override
  void delete(String key) {
    _box.delete(key);
  }

  @override
  Future<List<Task>> readAll() async {
    return _box.values.toList();
  }

  @override
  void writeMany(List<Task> values) {
    for (var element in values) {
      write(element.title, element);
    }
  }

  @override
  bool has(String key) {
    return _box.containsKey(key);
  }
}
