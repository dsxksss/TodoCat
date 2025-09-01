import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/database.dart';

class TaskRepository {
  static TaskRepository? _instance;
  Box<Task>? _box;
  bool _isInitialized = false;

  TaskRepository._();

  static Future<TaskRepository> getInstance() async {
    _instance ??= TaskRepository._();
    if (!_instance!._isInitialized) {
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    final db = await Database.getInstance();
    _box = await db.getBox<Task>('tasks');
    _isInitialized = true;
  }

  Box<Task> get box {
    if (_box == null) {
      throw StateError('TaskRepository not initialized');
    }
    return _box!;
  }

  Future<void> write(String uuid, Task task) async {
    final existingTask = box.get(uuid);
    if (existingTask != null) {
      task.order = existingTask.order;
    } else {
      task.order = box.length;
    }
    await box.put(uuid, task);
  }

  Future<void> delete(String uuid) async {
    await box.delete(uuid);
  }

  Future<void> update(String uuid, Task task) async {
    await write(uuid, task);
  }

  Future<List<Task>> readAll() async {
    final tasks = box.values.toList();
    tasks.sort((a, b) => a.order.compareTo(b.order));
    return tasks;
  }

  Future<void> updateMany(
      List<Task> tasks, String Function(Task) getKey) async {
    await box.clear();
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      task.order = i;
      await box.put(getKey(task), task);
    }
  }

  bool has(String uuid) {
    return box.containsKey(uuid);
  }
}
