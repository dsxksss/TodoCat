import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:TodoCat/data/database/converters.dart';
import 'package:TodoCat/data/database/database.dart' as drift_db;
import 'package:drift/drift.dart';

class TaskRepository {
  static TaskRepository? _instance;
  drift_db.AppDatabase? _db;
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
    final dbService = await Database.getInstance();
    _db = dbService.appDatabase;
    _isInitialized = true;
  }

  drift_db.AppDatabase get db {
    if (_db == null) {
      throw StateError('TaskRepository not initialized');
    }
    return _db!;
  }

  /// 获取任务的所有 todos
  Future<List<Todo>> _getTodosForTask(String taskUuid) async {
    final rows = await (db.select(db.todos)
          ..where((t) => t.taskUuid.equals(taskUuid)))
        .get();
    return rows.map((row) => DbConverters.todoFromRow(row)).toList();
  }

  Future<void> write(String uuid, Task task) async {
    await db.transaction(() async {
      // 检查是否存在
      final existing = await (db.select(db.tasks)
            ..where((t) => t.uuid.equals(uuid)))
          .getSingleOrNull();

      if (existing != null) {
        task.id = existing.id;
        task.order = existing.order;
      } else {
        // 获取当前任务数量作为新任务的 order
        final countQuery = db.selectOnly(db.tasks)..addColumns([db.tasks.id.count()]);
        final count = await countQuery.getSingle();
        task.order = count.read(db.tasks.id.count()) ?? 0;
      }

      // 保存任务
      final companion = DbConverters.taskToCompanion(task, isUpdate: existing != null);
      if (existing != null) {
        await (db.update(db.tasks)..where((t) => t.id.equals(existing.id))).write(companion);
      } else {
        final insertedId = await db.into(db.tasks).insert(companion);
        task.id = insertedId;
      }

      // 保存 todos
      if (task.todos != null && task.todos!.isNotEmpty) {
        // 先删除旧的 todos
        await (db.delete(db.todos)..where((t) => t.taskUuid.equals(uuid))).go();
        
        // 插入新的 todos
        for (var todo in task.todos!) {
          await db.into(db.todos).insert(DbConverters.todoToCompanion(todo, uuid));
        }
      }
    });
  }

  /// 标记任务为已删除（移到回收站）
  Future<void> delete(String uuid) async {
    await db.transaction(() async {
      final taskRow = await (db.select(db.tasks)
            ..where((t) => t.uuid.equals(uuid)))
          .getSingleOrNull();

      if (taskRow != null) {
        final deletedAt = DateTime.now().millisecondsSinceEpoch;
        
        // 更新任务
        await (db.update(db.tasks)..where((t) => t.id.equals(taskRow.id)))
          .write(drift_db.TasksCompanion(deletedAt: Value(deletedAt)));

        // 更新所有相关的 todos
        await (db.update(db.todos)..where((t) => t.taskUuid.equals(uuid)))
          .write(drift_db.TodosCompanion(deletedAt: Value(deletedAt)));
      }
    });
  }

  /// 永久删除任务（从回收站删除）
  Future<void> permanentDelete(String uuid) async {
    await db.transaction(() async {
      // 先删除 todos
      await (db.delete(db.todos)..where((t) => t.taskUuid.equals(uuid))).go();
      
      // 再删除任务
      final taskRow = await (db.select(db.tasks)
            ..where((t) => t.uuid.equals(uuid)))
          .getSingleOrNull();
      if (taskRow != null) {
        await (db.delete(db.tasks)..where((t) => t.id.equals(taskRow.id))).go();
      }
    });
  }

  Future<void> update(String uuid, Task task) async {
    await write(uuid, task);
  }

  /// 读取所有未删除的任务
  Future<List<Task>> readAll() async {
    final rows = await (db.select(db.tasks)
          ..where((t) => t.deletedAt.equals(0))
          ..orderBy([(t) => OrderingTerm(expression: t.order)]))
        .get();

    final tasks = <Task>[];
    for (var row in rows) {
      final todos = await _getTodosForTask(row.uuid);
      tasks.add(DbConverters.taskFromRow(row, todos));
    }
    return tasks;
  }

  /// 读取所有已删除的任务（用于回收站）
  Future<List<Task>> readDeleted() async {
    // 获取所有任务
    final allRows = await db.select(db.tasks).get();
    
    final deletedTasks = <Task>[];
    for (var row in allRows) {
      final todos = await _getTodosForTask(row.uuid);
      final task = DbConverters.taskFromRow(row, todos);
      
      // 如果任务本身被删除，直接添加
      if (row.deletedAt > 0) {
        deletedTasks.add(task);
      } else if (task.todos != null && task.todos!.isNotEmpty) {
        // 检查是否有已删除的 todos
        if (task.todos!.any((todo) => todo.deletedAt > 0)) {
          deletedTasks.add(task);
        }
      }
    }
    
    // 按删除时间排序
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

  Future<void> updateMany(List<Task> tasks, String Function(Task) getKey) async {
    await db.transaction(() async {
      // 清空所有任务和 todos
      await db.delete(db.tasks).go();
      await db.delete(db.todos).go();
      
      // 重新插入
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        task.order = i;
        final companion = DbConverters.taskToCompanion(task);
        final insertedId = await db.into(db.tasks).insert(companion);
        task.id = insertedId;
        
        // 插入 todos
        if (task.todos != null && task.todos!.isNotEmpty) {
          for (var todo in task.todos!) {
            await db.into(db.todos).insert(DbConverters.todoToCompanion(todo, task.uuid));
          }
        }
      }
    });
  }

  /// 检查任务是否存在（包括已删除的）
  Future<bool> has(String uuid) async {
    final row = await (db.select(db.tasks)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    return row != null;
  }

  /// 读取单个任务（包括已删除的）
  Future<Task?> readOne(String uuid) async {
    final row = await (db.select(db.tasks)
          ..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
    
    if (row == null) return null;
    
    final todos = await _getTodosForTask(uuid);
    return DbConverters.taskFromRow(row, todos);
  }

  /// 恢复已删除的任务
  Future<void> restore(String uuid) async {
    await db.transaction(() async {
      // 恢复任务
      await (db.update(db.tasks)..where((t) => t.uuid.equals(uuid)))
        .write(const drift_db.TasksCompanion(deletedAt: Value(0)));

      // 恢复所有相关的 todos
      await (db.update(db.todos)..where((t) => t.taskUuid.equals(uuid)))
        .write(const drift_db.TodosCompanion(deletedAt: Value(0)));
    });
  }
}
