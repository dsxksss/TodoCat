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

  /// 标记任务为已删除（移到回收站）
  Future<void> delete(String uuid) async {
    await isar.writeTxn(() async {
      final task = await isar.tasks.filter().uuidEqualTo(uuid).findFirst();
      if (task != null) {
        task.deletedAt = DateTime.now().millisecondsSinceEpoch;
        // 同时标记所有todos为已删除
        if (task.todos != null) {
          for (var todo in task.todos!) {
            todo.deletedAt = task.deletedAt;
          }
        }
        await isar.tasks.put(task);
      }
    });
  }

  /// 永久删除任务（从回收站删除）
  Future<void> permanentDelete(String uuid) async {
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

  /// 读取所有未删除的任务
  Future<List<Task>> readAll() async {
    return await isar.tasks
        .filter()
        .deletedAtEqualTo(0)
        .sortByOrder()
        .findAll();
  }

  /// 读取所有已删除的任务（用于回收站）
  /// 包括：1. task 被删除的情况  2. task 未被删除但包含已删除 todo 的情况
  Future<List<Task>> readDeleted() async {
    // 获取所有任务（包括已删除和未删除的）
    final allTasks = await isar.tasks.where().findAll();
    
    // 过滤出需要显示在回收站的任务：
    // 1. task 本身被删除了 (deletedAt > 0)
    // 2. task 未被删除但包含已删除的 todos
    final deletedTasks = allTasks.where((task) {
      // 如果任务本身被删除，直接返回
      if (task.deletedAt > 0) return true;
      
      // 检查是否有已删除的 todos
      if (task.todos != null && task.todos!.isNotEmpty) {
        return task.todos!.any((todo) => todo.deletedAt > 0);
      }
      
      return false;
    }).toList();
    
    // 按删除时间排序（如果 task 未删除，使用其最新删除的 todo 的时间）
    deletedTasks.sort((a, b) {
      final aTime = a.deletedAt > 0 
          ? a.deletedAt 
          : (a.todos?.where((t) => t.deletedAt > 0).map((t) => t.deletedAt).reduce((max, time) => time > max ? time : max) ?? 0);
      final bTime = b.deletedAt > 0 
          ? b.deletedAt 
          : (b.todos?.where((t) => t.deletedAt > 0).map((t) => t.deletedAt).reduce((max, time) => time > max ? time : max) ?? 0);
      return bTime.compareTo(aTime); // 降序排列
    });
    
    return deletedTasks;
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

  /// 检查任务是否存在（包括已删除的）
  bool has(String uuid) {
    return isar.tasks.filter().uuidEqualTo(uuid).findFirstSync() != null;
  }

  /// 读取单个任务（包括已删除的）
  Future<Task?> readOne(String uuid) async {
    return await isar.tasks.filter().uuidEqualTo(uuid).findFirst();
  }

  /// 恢复已删除的任务
  Future<void> restore(String uuid) async {
    await isar.writeTxn(() async {
      final task = await isar.tasks.filter().uuidEqualTo(uuid).findFirst();
      if (task != null) {
        task.deletedAt = 0;
        // 同时恢复所有todos
        if (task.todos != null) {
          for (var todo in task.todos!) {
            todo.deletedAt = 0;
          }
        }
        await isar.tasks.put(task);
      }
    });
  }
}
