import 'package:isar/isar.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/database.dart';

class TaskRepository {
  static TaskRepository? _instance;
  late final Isar _isar;

  TaskRepository._();

  static Future<TaskRepository> getInstance() async {
    _instance ??= TaskRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final db = await Database.getInstance();
    _isar = db.isar;
  }

  Future<void> write(String uuid, Task task) async {
    await _isar.writeTxn(() async {
      final existingTask =
          await _isar.tasks.filter().uuidEqualTo(uuid).findFirst();
      if (existingTask != null) {
        task.id = existingTask.id;
        task.order = existingTask.order;
      } else {
        task.order = await _isar.tasks.where().count();
      }
      await _isar.tasks.put(task);
    });
  }

  Future<void> delete(String uuid) async {
    await _isar.writeTxn(() async {
      final task = await _isar.tasks.filter().uuidEqualTo(uuid).findFirst();
      if (task != null) {
        await _isar.tasks.delete(task.id);
      }
    });
  }

  Future<void> update(String uuid, Task task) async {
    await write(uuid, task);
  }

  Future<List<Task>> readAll() async {
    return await _isar.tasks.where().sortByOrder().findAll();
  }

  Future<void> updateMany(
      List<Task> tasks, String Function(Task) getKey) async {
    await _isar.writeTxn(() async {
      await _isar.tasks.clear();
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        task.order = i;
        await _isar.tasks.put(task);
      }
    });
  }

  bool has(String uuid) {
    return _isar.tasks.filter().uuidEqualTo(uuid).findFirstSync() != null;
  }
}
