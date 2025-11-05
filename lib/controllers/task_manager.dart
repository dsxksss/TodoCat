import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/services/repositorys/task.dart';
import 'package:TodoCat/widgets/template_selector_dialog.dart';

/// 管理任务数据的类，处理任务的CRUD操作和持久化
class TaskManager {
  static final _logger = Logger();
  TaskRepository? _repository;
  bool _isInitialized = false;
  final tasks = RxList<Task>();

  /// 获取repository实例
  TaskRepository get repository {
    if (_repository == null || !_isInitialized) {
      throw Exception('TaskManager not initialized. Call initialize() first.');
    }
    return _repository!;
  }

  /// 初始化任务管理器，从本地存储加载任务数据
  Future<void> initialize() async {
    if (_isInitialized && _repository != null) {
      _logger.d('TaskManager already initialized, refreshing data');
      await refresh();
      return;
    }
    
    _logger.d('Initializing TaskManager');
    _repository = await TaskRepository.getInstance();
    _isInitialized = true;
    await refresh();
  }

  /// 保存当前任务列表状态到存储
  Future<void> _saveToStorage() async {
    try {
      _logger.d('Saving tasks to storage, count: ${tasks.length}');
      await repository.updateMany(tasks.toList(), (task) => task.uuid);
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
      final localTasks = await repository.readAll();

      // 去重复处理，确保任务唯一性
      final uniqueTasks = _removeDuplicateTasks(localTasks);

      tasks.assignAll(uniqueTasks);
      tasks.refresh();
      _logger.d('Tasks refreshed successfully, count: ${tasks.length}');
    } catch (e) {
      _logger.e('Error refreshing tasks: $e');
    }
  }

  /// 移除重复的任务，确保任务唯一性
  List<Task> _removeDuplicateTasks(List<Task> tasks) {
    final seen = <String>{};
    final uniqueTasks = <Task>[];

    for (final task in tasks) {
      if (!seen.contains(task.uuid)) {
        seen.add(task.uuid);
        uniqueTasks.add(task);
      } else {
        _logger.w('Duplicate task found: ${task.uuid}, removing duplicate');
      }
    }

    return uniqueTasks;
  }

  /// 重置任务模板，显示模板选择对话框
  Future<void> resetTasksTemplate() async {
    showTemplateSelectorDialog(
      onTemplateSelected: (TaskTemplateType type) async {
        await _resetTasksTemplateWithType(type);
      },
      onCustomTemplateSelected: (customTemplate) async {
        await _applyCustomTemplate(customTemplate);
      },
    );
  }
  
  /// 应用自定义模板
  Future<void> _applyCustomTemplate(customTemplate) async {
    try {
      _logger.i('应用自定义模板: ${customTemplate.name}');
      
      // 1. 清空内存中的任务列表
      tasks.clear();
      tasks.refresh(); // 立即刷新UI

      // 2. 清空数据库中的所有任务
      await _clearAllTasks();
      
      // 3. 从自定义模板获取任务列表
      final List<Task> templateTasks = customTemplate.getTasks();
      _logger.d('Created ${templateTasks.length} template tasks from custom template');
      
      // 4. 添加到内存和数据库
      await assignAll(templateTasks);
      
      // 5. 确保UI完全刷新
      tasks.refresh();
      
      _logger.i('自定义模板应用成功, final count: ${tasks.length}');
    } catch (e) {
      _logger.e('应用自定义模板失败: $e');
      rethrow;
    }
  }

  /// 使用指定类型重置任务模板
  Future<void> _resetTasksTemplateWithType(TaskTemplateType type) async {
    try {
      _logger.d('Starting tasks template reset with type: $type');

      // 1. 清空内存中的任务列表
      tasks.clear();
      tasks.refresh(); // 立即刷新UI

      // 2. 清空数据库中的所有任务
      await _clearAllTasks();

      // 3. 创建新的默认任务（确保每次都是全新的UUID）
      final freshDefaultTasks = createTaskTemplate(type);
      _logger.d('Created ${freshDefaultTasks.length} template tasks');

      // 4. 添加到内存和数据库
      await assignAll(freshDefaultTasks);

      // 5. 确保UI完全刷新
      tasks.refresh();
      
      _logger.d('Tasks template reset completed successfully with type: $type, final count: ${tasks.length}');
    } catch (e) {
      _logger.e('Error resetting tasks template: $e');
      throw Exception('Failed to reset tasks template: $e');
    }
  }

  /// 清空数据库中的所有任务（应用模板时永久删除，不移动到回收站）
  Future<void> _clearAllTasks() async {
    try {
      _logger.d('Clearing all tasks from database (permanently)');

      // 永久删除所有任务（包括回收站中的）- 直接清空表
      await repository.updateMany([], (task) => task.uuid);

      _logger.d('All tasks permanently deleted from database');
    } catch (e) {
      _logger.e('Error clearing all tasks: $e');
      throw Exception('Failed to clear all tasks: $e');
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
    if (!(await has(task.uuid))) {
      tasks.add(task);
      tasks.refresh();
      await repository.write(task.uuid, task);
    }
  }

  /// 删除指定ID的任务
  Future<void> removeTask(String uuid) async {
    tasks.removeWhere((task) => task.uuid == uuid);
    tasks.refresh();
    await repository.delete(uuid);
  }

  /// 更新指定ID的任务
  Future<void> updateTask(String uuid, Task task) async {
    try {
      final index = tasks.indexWhere((t) => t.uuid == uuid);
      if (index != -1) {
        _logger.d('Updating task $uuid at index $index');

        // 更新内存中的任务
        tasks[index] = task;

        // 刷新UI，确保变化立即显示
        tasks.refresh();

        // 更新数据库
        await repository.update(uuid, task);

        _logger.d('Task $uuid updated successfully');
      } else {
        _logger.w('Task $uuid not found for update');
      }
    } catch (e) {
      _logger.e('Error updating task $uuid: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  /// 批量设置任务列表
  Future<void> assignAll(List<Task> newTasks) async {
    try {
      _logger.d('Assigning ${newTasks.length} tasks');

      // 更新内存中的任务列表
      tasks.assignAll(newTasks);
      tasks.refresh();

      // 批量写入数据库
      await Future.wait(
        newTasks.map((task) {
          _logger.d('Writing task: ${task.uuid} - ${task.title}');
          return repository.write(task.uuid, task);
        }),
      );

      _logger.d('All ${newTasks.length} tasks assigned successfully');
    } catch (e) {
      _logger.e('Error assigning tasks: $e');
      throw Exception('Failed to assign tasks: $e');
    }
  }

  /// 对任务列表进行排序
  Future<void> sort({bool reverse = false}) async {
    tasks.sort((a, b) => reverse
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    tasks.refresh();
    await repository.updateMany(tasks.toList(), (task) => task.uuid);
  }

  /// 检查指定ID的任务是否存在
  Future<bool> has(String uuid) async {
    return await repository.has(uuid);
  }
}
