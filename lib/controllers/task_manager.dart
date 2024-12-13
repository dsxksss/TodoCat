import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';

/// 管理任务数据的类，处理任务的CRUD操作和持久化
class TaskManager {
  static final _logger = Logger();
  late final TaskRepository _repository;
  final tasks = RxList<Task>();

  /// 初始化任务管理器，从本地存储加载任务数据
  Future<void> initialize() async {
    _repository = await TaskRepository.getInstance();
    await refresh();
  }

  /// 保存当前任务列表状态到存储
  Future<void> _saveToStorage() async {
    try {
      _logger.d('Saving tasks to storage, count: ${tasks.length}');
      await _repository.updateMany(tasks.toList(), (task) => task.uuid);
      _logger.d('Tasks saved successfully');
    } catch (e) {
      _logger.e('Error saving tasks: $e');
      throw Exception('Failed to save tasks: $e');
    }
  }

  /// 刷新任务列表的UI并保存到存储
  Future<void> refresh() async {
    try {
      _logger.d('Refreshing tasks');
      final localTasks = await _repository.readAll();
      tasks.assignAll(localTasks);
      tasks.refresh();
      _logger.d('Tasks refreshed successfully');
    } catch (e) {
      _logger.e('Error refreshing tasks: $e');
    }
  }

  /// 重新排序任务
  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= tasks.length) return;
    if (newIndex < 0 || newIndex > tasks.length) {
      newIndex = tasks.length;
    }

    try {
      _logger.d('Reordering task from $oldIndex to $newIndex');

      // 更新内存中的任务列表
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);

      // 更新所有任务的 order 字段
      for (var i = 0; i < tasks.length; i++) {
        tasks[i].order = i;
      }

      // 立即保存新的顺序到存储
      await _saveToStorage();

      // 刷新 UI
      tasks.refresh();

      _logger.d('Task reorder completed and saved');
    } catch (e) {
      _logger.e('Error reordering tasks: $e');
      // 如果发生错误，尝试恢复原始顺序
      await refresh();
    }
  }

  /// 添加新任务
  ///
  /// 如果任务ID不存在，则添加任务并持久化
  Future<void> addTask(Task task) async {
    if (!has(task.uuid)) {
      tasks.add(task);
      tasks.refresh();
      await _repository.write(task.uuid, task);
    }
  }

  /// 删除指定ID的任务
  Future<void> removeTask(String uuid) async {
    tasks.removeWhere((task) => task.uuid == uuid);
    tasks.refresh();
    await _repository.delete(uuid);
  }

  /// 更新指定ID的任务
  Future<void> updateTask(String uuid, Task task) async {
    final index = tasks.indexWhere((t) => t.uuid == uuid);
    if (index != -1) {
      tasks[index] = task;
      tasks.refresh();
      await _repository.update(uuid, task);
    }
  }

  /// 批量设置任务列表
  Future<void> assignAll(List<Task> newTasks) async {
    tasks.assignAll(newTasks);
    tasks.refresh();
    await Future.wait(
      newTasks.map((task) => _repository.write(task.uuid, task)),
    );
  }

  /// 对任务列表进行排序
  Future<void> sort({bool reverse = false}) async {
    tasks.sort((a, b) => reverse
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    tasks.refresh();
    await _repository.updateMany(tasks.toList(), (task) => task.uuid);
  }

  /// 检查指定ID的任务是否存在
  bool has(String uuid) {
    return _repository.has(uuid);
  }
}
