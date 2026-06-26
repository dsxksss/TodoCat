import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'package:todo_cat/widgets/template_selector_dialog.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/services/sync_manager.dart';

/// 管理任务数据的类，处理任务的 CRUD 操作和持久化。
///
/// 原先持有 `RxList<Task>`；现改为普通 `List<Task>` + [onChanged] 回调，
/// 由宿主 [HomeController]（Riverpod Notifier）在回调中重新发射 state。
class TaskManager {
  TaskManager({required this.ref, this.onChanged});

  final Ref ref;

  /// 数据变化回调（替代原 `tasks.refresh()`）。
  VoidCallback? onChanged;

  static final _logger = Logger();
  TaskRepository? _repository;
  bool _isInitialized = false;

  final List<Task> tasks = [];

  void _notify() => onChanged?.call();

  TaskRepository get repository {
    if (_repository == null || !_isInitialized) {
      throw Exception('TaskManager not initialized. Call initialize() first.');
    }
    return _repository!;
  }

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

  Future<void> refresh({String? workspaceId}) async {
    try {
      _logger.d(
          'Refreshing tasks${workspaceId != null ? " for workspace: $workspaceId" : ""}');

      if (_repository == null || !_isInitialized) {
        _repository = await TaskRepository.getInstance();
        _isInitialized = true;
      }

      final localTasks = await repository.readAll(workspaceId: workspaceId);
      final uniqueTasks = _removeDuplicateTasks(localTasks);

      tasks
        ..clear()
        ..addAll(uniqueTasks);
      _notify();
      _logger.d('Tasks refreshed successfully, count: ${tasks.length}');
    } catch (e) {
      _logger.e('Error refreshing tasks: $e');
    }
  }

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

  String _currentWorkspaceId() =>
      ref.read(workspaceControllerProvider).currentWorkspaceId;

  Future<void> _applyCustomTemplate(customTemplate) async {
    try {
      _logger.i('应用自定义模板: ${customTemplate.name}');
      final workspaceId = _currentWorkspaceId();
      _logger.d('应用模板到工作空间: $workspaceId');

      tasks.clear();
      _notify();

      await _clearAllTasks(workspaceId: workspaceId);

      final List<Task> templateTasks = customTemplate.getTasks();
      _logger.d(
          'Created ${templateTasks.length} template tasks from custom template');

      for (var task in templateTasks) {
        task.workspaceId = workspaceId;
      }

      await assignAll(templateTasks);
      _notify();
      _logger.i('自定义模板应用成功, final count: ${tasks.length}');
    } catch (e) {
      _logger.e('应用自定义模板失败: $e');
      rethrow;
    }
  }

  Future<void> _resetTasksTemplateWithType(TaskTemplateType type) async {
    try {
      _logger.d('Starting tasks template reset with type: $type');
      final workspaceId = _currentWorkspaceId();
      _logger.d('应用模板到工作空间: $workspaceId');

      tasks.clear();
      _notify();

      await _clearAllTasks(workspaceId: workspaceId);

      final freshDefaultTasks = createTaskTemplate(type);
      _logger.d('Created ${freshDefaultTasks.length} template tasks');

      for (var task in freshDefaultTasks) {
        task.workspaceId = workspaceId;
      }

      await assignAll(freshDefaultTasks);
      _notify();
      _logger.d(
          'Tasks template reset completed successfully with type: $type, final count: ${tasks.length}');
    } catch (e) {
      _logger.e('Error resetting tasks template: $e');
      throw Exception('Failed to reset tasks template: $e');
    }
  }

  Future<void> _clearAllTasks({String? workspaceId}) async {
    try {
      if (workspaceId != null) {
        _logger
            .d('Clearing all tasks from workspace: $workspaceId (permanently)');
      } else {
        _logger.d('Clearing all tasks from database (permanently)');
      }

      final tasksToDelete = await repository.readAll(workspaceId: workspaceId);
      for (var task in tasksToDelete) {
        await repository.permanentDelete(task.uuid);
      }

      _logger.d(
          'All tasks${workspaceId != null ? " from workspace $workspaceId" : ""} permanently deleted from database');
    } catch (e) {
      _logger.e('Error clearing all tasks: $e');
      throw Exception('Failed to clear all tasks: $e');
    }
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= tasks.length) return;
    if (newIndex < 0 || newIndex > tasks.length) {
      newIndex = tasks.length;
    }
    try {
      _logger.d('Reordering task from $oldIndex to $newIndex');
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
      for (var i = 0; i < tasks.length; i++) {
        tasks[i].order = i;
      }
      await _saveToStorage();
      _notify();
      if (tasks.isNotEmpty) {
        await SyncManager().notifyLocalChange(tasks.first.workspaceId);
      }
      _logger.d('Task reorder completed and saved');
    } catch (e) {
      _logger.e('Error reordering tasks: $e');
      await refresh();
    }
  }

  Future<void> addTask(Task task) async {
    if (!(await has(task.uuid))) {
      tasks.add(task);
      _notify();
      await repository.write(task.uuid, task);
      await SyncManager().notifyLocalChange(task.workspaceId);
    }
  }

  Future<void> removeTask(String uuid) async {
    tasks.removeWhere((task) => task.uuid == uuid);
    _notify();
    await repository.delete(uuid);
  }

  Future<void> updateTask(String uuid, Task task) async {
    try {
      final index = tasks.indexWhere((t) => t.uuid == uuid);
      if (index != -1) {
        _logger.d('Updating task $uuid at index $index');
        tasks[index] = task;
        _notify();
      } else {
        _logger.d('Task $uuid not in memory, will update database only');
      }
      await repository.update(uuid, task);
      await SyncManager().notifyLocalChange(task.workspaceId);
      _logger.d('Task $uuid updated successfully');
    } catch (e) {
      _logger.e('Error updating task $uuid: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> assignAll(List<Task> newTasks) async {
    try {
      _logger.d('Assigning ${newTasks.length} tasks');
      tasks
        ..clear()
        ..addAll(newTasks);
      _notify();

      await Future.wait(
        newTasks.map((task) {
          _logger.d('Writing task: ${task.uuid} - ${task.title}');
          return repository.write(task.uuid, task);
        }),
      );

      _logger.d('All ${newTasks.length} tasks assigned successfully');
      if (newTasks.isNotEmpty) {
        await SyncManager().notifyLocalChange(newTasks.first.workspaceId);
      }
    } catch (e) {
      _logger.e('Error assigning tasks: $e');
      throw Exception('Failed to assign tasks: $e');
    }
  }

  Future<void> sort({bool reverse = false}) async {
    tasks.sort((a, b) => reverse
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    _notify();
    await repository.updateMany(tasks.toList(), (task) => task.uuid);
  }

  Future<bool> has(String uuid) async {
    return await repository.has(uuid);
  }
}
