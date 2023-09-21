import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/strorage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/env.dart';

class TaskRepository extends Strorage<Task> {
  late Box<Task> _box;
  final taskKey = 'tasksxxxawxl';

  TaskRepository._();

  static TaskRepository? _instance;

  static Future<TaskRepository> getInstance() async {
    _instance ??= TaskRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    // 开启数据盒
    await Hive.openBox<Task>(taskKey);
    _box = Hive.box(taskKey);

    if (isDebugMode) {
      await _box.clear();
      writeMany(defaultTasks);
    }
  }

  @override
  void onClose() {
    _box.close();
    super.onClose();
  }

  @override
  Task? read(String key) {
    return _box.get(key);
  }

  @override
  void write(String key, Task value) async {
    if (!has(key)) {
      await _box.put(key, value);
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
  void update(String key, Task value) async {
    await _box.put(key, value);
  }

  @override
  void updateMany(List<Task> values) {
    for (var element in values) {
      update(element.id, element);
    }
  }
}
