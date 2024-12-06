import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';

/// 管理任务数据的类，处理任务的CRUD操作和持久化
class TaskManager {
  late final TaskRepository _repository;
  final tasks = RxList<Task>();

  /// 初始化任务管理器，从本地存储加载任务数据
  Future<void> initialize() async {
    _repository = await TaskRepository.getInstance();
    final localTasks = await _repository.readAll();
    tasks.assignAll(localTasks);
  }

  /// 添加新任务
  ///
  /// 如果任务ID不存在，则添加任务并持久化
  void addTask(Task task) {
    if (!has(task.id)) {
      tasks.add(task);
      tasks.refresh();
      _repository.write(task.id, task);
    }
  }

  /// 删除指定ID的任务
  void removeTask(String taskId) {
    tasks.removeWhere((task) => task.id == taskId);
    tasks.refresh();
    _repository.delete(taskId);
  }

  /// 更新指定ID的任务
  void updateTask(String taskId, Task newTask) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      tasks[index] = newTask;
      tasks.refresh();
      _repository.update(taskId, newTask);
    }
  }

  /// 批量设置任务列表
  void assignAll(List<Task> newTasks) {
    tasks.assignAll(newTasks);
    tasks.refresh();
    for (var task in newTasks) {
      _repository.write(task.id, task);
    }
  }

  /// 对任务列表进行排序
  void sort({bool reverse = false}) {
    tasks.sort((a, b) => reverse
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    tasks.refresh();
  }

  /// 刷新任务列表的UI
  void refresh() {
    tasks.refresh();
  }

  /// 检查指定ID的任务是否存在
  bool has(String taskId) {
    return _repository.has(taskId);
  }

  /// 批量更新任务
  void updateMany(List<Task> tasks, String Function(Task) getKey) {
    _repository.updateMany(tasks, getKey);
  }
}
