import 'package:isar/isar.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/database.dart';

class TaskRepository {
  static TaskRepository? _instance;
  Isar? _isar;
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
    _isar = db.isar;
    _isInitialized = true;
  }

  Isar get isar {
    if (_isar == null) {
      throw StateError('TaskRepository not initialized');
    }
    return _isar!;
  }

  Future<void> write(String uuid, Task task) async {
    await isar.writeTxn(() async {
      final existingTask =
          await isar.tasks.filter().uuidEqualTo(uuid).findFirst();
      if (existingTask != null) {
        task.id = existingTask.id;
        task.order = existingTask.order;
      } else {
        task.order = await isar.tasks.where().count();
      }
      await isar.tasks.put(task);
    });
  }

  Future<void> delete(String uuid) async {
    await isar.writeTxn(() async {
      final task = await isar.tasks.filter().uuidEqualTo(uuid).findFirst();
      if (task != null) {
        await isar.tasks.delete(task.id);
      }
    });
  }

  Future<void> update(String uuid, Task task) async {
    await write(uuid, task);
  }

  Future<List<Task>> readAll() async {
    return await isar.tasks.where().sortByOrder().findAll();
  }

  Future<void> updateMany(
      List<Task> tasks, String Function(Task) getKey) async {
    await isar.writeTxn(() async {
      await isar.tasks.clear();
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        task.order = i;
        await isar.tasks.put(task);
      }
    });
  }

  bool has(String uuid) {
    return isar.tasks.filter().uuidEqualTo(uuid).findFirstSync() != null;
  }
}
