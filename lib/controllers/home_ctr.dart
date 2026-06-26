import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/data_export_import_ctr.dart';
import 'package:todo_cat/controllers/trash_ctr.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/save_template_dialog.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/controllers/task_manager.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'package:todo_cat/widgets/duplicate_name_dialog.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_cat/services/sync_manager.dart';
import 'package:todo_cat/core/utils/l10n.dart';

part 'home_ctr.g.dart';

/// 主页状态：任务列表 + UI 标记 + 搜索/分组状态（原 HomeController + TaskStateMixin）。
@immutable
class HomeState {
  final List<Task> tasks;
  final bool shouldAnimate;
  final bool isSwitchingWorkspace;
  final String searchQuery;
  final bool groupByStatus;
  final String selectedTaskId;

  const HomeState({
    this.tasks = const [],
    this.shouldAnimate = true,
    this.isSwitchingWorkspace = false,
    this.searchQuery = '',
    this.groupByStatus = false,
    this.selectedTaskId = '',
  });

  HomeState copyWith({
    List<Task>? tasks,
    bool? shouldAnimate,
    bool? isSwitchingWorkspace,
    String? searchQuery,
    bool? groupByStatus,
    String? selectedTaskId,
  }) {
    return HomeState(
      tasks: tasks ?? this.tasks,
      shouldAnimate: shouldAnimate ?? this.shouldAnimate,
      isSwitchingWorkspace: isSwitchingWorkspace ?? this.isSwitchingWorkspace,
      searchQuery: searchQuery ?? this.searchQuery,
      groupByStatus: groupByStatus ?? this.groupByStatus,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
    );
  }

  /// 过滤后的任务列表（按标题/标签/描述搜索）。
  List<Task> get filteredTasks {
    if (searchQuery.isEmpty) return tasks;
    final q = searchQuery.toLowerCase();
    return tasks.where((task) {
      final titleMatch = task.title.toLowerCase().contains(q);
      final tagMatch = task.tags.any((tag) => tag.toLowerCase().contains(q));
      final descMatch = task.description.toLowerCase().contains(q);
      return titleMatch || tagMatch || descMatch;
    }).toList();
  }

  TaskStats get taskStats => TaskStats(
        total: tasks.length,
        todo: tasks.where((t) => t.status == TaskStatus.todo).length,
        inProgress:
            tasks.where((t) => t.status == TaskStatus.inProgress).length,
        done: tasks.where((t) => t.status == TaskStatus.done).length,
      );
}

@Riverpod(keepAlive: true)
class HomeController extends _$HomeController {
  static final _logger = Logger();
  late final TaskManager _taskManager;

  @override
  HomeState build() {
    _taskManager = TaskManager(ref: ref, onChanged: _emit);
    _init();
    return const HomeState();
  }

  /// 重新发射任务列表（替代 GetX 的 tasks.refresh()）。
  void _emit() {
    state = state.copyWith(tasks: List<Task>.from(_taskManager.tasks));
  }

  List<Task> get tasks => _taskManager.tasks;
  List<Task> get allTasks => _taskManager.tasks;

  // ---- UI 状态 setter（供 WorkspaceController / 页面调用）----
  void setSwitchingWorkspace(bool value) =>
      state = state.copyWith(isSwitchingWorkspace: value);
  void startDragging() => state = state.copyWith(shouldAnimate: true);
  void endDragging() => state = state.copyWith(shouldAnimate: false);
  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query.trim());
  void clearSearch() => state = state.copyWith(searchQuery: '');
  void toggleGroupByStatus() =>
      state = state.copyWith(groupByStatus: !state.groupByStatus);
  void selectTask(Task? task) =>
      state = state.copyWith(selectedTaskId: task?.uuid ?? '');
  void deselectTask() => state = state.copyWith(selectedTaskId: '');

  Future<void> _init() async {
    _logger.i('Initializing HomeController');
    await _initializeTasks();
    Future.delayed(const Duration(seconds: 1),
        () => state = state.copyWith(shouldAnimate: false));
    _refreshTrash();
  }

  Future<void> _initializeTasks() async {
    await _taskManager.initialize();
    await refreshData();
  }

  Future<void> resetTasksTemplate() async {
    await _taskManager.resetTasksTemplate();
    _refreshExportPreview();
  }

  /// 刷新数据（用于数据导入后更新UI）
  Future<void> refreshData(
      {bool showEmptyPrompt = false, bool clearBeforeRefresh = false}) async {
    _logger.i('刷新主页数据...');
    try {
      if (clearBeforeRefresh) {
        _taskManager.tasks.clear();
        _emit();
      }

      final workspaceId =
          ref.read(workspaceControllerProvider).currentWorkspaceId;
      await _taskManager.refresh(workspaceId: workspaceId);
      _logger.i('主页数据刷新成功');

      if (showEmptyPrompt && _taskManager.tasks.isEmpty) {
        await _showEmptyTaskToast();
      }
      _refreshTrash();
    } catch (e) {
      _logger.e('刷新主页数据失败: $e');
    }
  }

  /// 保存当前所有任务为模板
  void saveAsTemplate() {
    if (tasks.isEmpty) {
      showErrorNotification(l10n.noTasksToSave);
      return;
    }
    final validTasks = tasks.where((task) => task.deletedAt == 0).toList();
    if (validTasks.isEmpty) {
      showErrorNotification(l10n.noTasksToSave);
      return;
    }
    showSaveTemplateDialog(validTasks);
  }

  void _refreshExportPreview() {
    try {
      ref.read(dataExportImportControllerProvider.notifier).refreshPreview();
    } catch (e) {
      _logger.d('刷新导出预览失败: $e');
    }
  }

  void _refreshTrash() {
    try {
      ref.read(trashControllerProvider.notifier).refresh();
    } catch (e) {
      _logger.d('刷新回收站失败: $e');
    }
  }

  Future<void> _showEmptyTaskToast() async {
    await Future.delayed(const Duration(milliseconds: 500));
    showToast(
      l10n.isResetTasksTemplate,
      alwaysShow: true,
      confirmMode: true,
      tag: 'empty_task_prompt',
      onYesCallback: () async {
        await resetTasksTemplate();
      },
    );
  }

  // 添加Todo到指定任务
  Future<bool> addTodo(Todo todo, String taskId) async {
    try {
      _logger.d('Adding todo to task: $taskId');
      final task = allTasks.firstWhere((task) => task.uuid == taskId);
      final newTodos = List<Todo>.from(task.todos ?? []);
      newTodos.add(todo);
      task.todos = newTodos;
      await _taskManager.updateTask(taskId, task);
      _refreshExportPreview();
      _logger.d('Todo added successfully and saved to database');
      return true;
    } catch (e) {
      _logger.e('Error adding todo: $e');
      return false;
    }
  }

  /// 复制Todo（创建副本）
  Future<bool> duplicateTodo(String taskUuid, String todoUuid) async {
    try {
      final task = allTasks.firstWhereOrNull((t) => t.uuid == taskUuid);
      if (task == null) {
        _logger.e('Duplicate failed: Task not found');
        return false;
      }
      final originalTodo =
          task.todos?.firstWhereOrNull((t) => t.uuid == todoUuid);
      if (originalTodo == null) {
        _logger.e('Duplicate failed: Todo not found');
        return false;
      }

      final newTodo = Todo()
        ..uuid = const Uuid().v4()
        ..title = originalTodo.title
        ..description = originalTodo.description
        ..status = TodoStatus.todo
        ..priority = originalTodo.priority
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..dueDate = originalTodo.dueDate
        ..tags = List.from(originalTodo.tags)
        ..tagsWithColorJsonString = originalTodo.tagsWithColorJsonString
        ..finishedAt = 0
        ..reminders = originalTodo.reminders
        ..progress = 0
        ..images = List.from(originalTodo.images)
        ..deletedAt = 0;

      final success = await addTodo(newTodo, taskUuid);
      if (success) {
        showToast(
          l10n.todoDuplicated,
          toastStyleType: TodoCatToastStyleType.success,
        );
      }
      return success;
    } catch (e) {
      _logger.e('Error duplicating todo: $e');
      return false;
    }
  }

  Future<void> addTask(Task task) async {
    task.workspaceId = ref.read(workspaceControllerProvider).currentWorkspaceId;
    await _taskManager.addTask(task);
    _refreshExportPreview();
  }

  Future<bool> deleteTask(String uuid) async {
    try {
      final taskIndex =
          _taskManager.tasks.indexWhere((task) => task.uuid == uuid);
      if (taskIndex == -1) {
        _logger.w('Task $uuid not found');
        return false;
      }

      final task = _taskManager.tasks[taskIndex];
      _cleanupTaskNotifications(task);

      await _taskManager.repository.delete(uuid);
      await SyncManager().notifyLocalChange(task.workspaceId);

      _taskManager.tasks.removeAt(taskIndex);
      _emit();

      _refreshExportPreview();
      _refreshTrash();
      return true;
    } catch (e) {
      _logger.e('Error deleting task: $e');
      return false;
    }
  }

  /// 恢复已删除的task（撤销删除）
  Future<bool> undoTask(String uuid) async {
    try {
      _logger.d('Undoing task deletion: $uuid');
      final task = await _taskManager.repository.readOne(uuid);
      if (task == null) {
        _logger.w('Task $uuid not found in database');
        return false;
      }

      task.deletedAt = 0;
      if (task.todos != null && task.todos!.isNotEmpty) {
        final newTodos = List<Todo>.from(task.todos!);
        for (var todo in newTodos) {
          todo.deletedAt = 0;
        }
        task.todos = newTodos;
      }

      await _taskManager.repository.update(uuid, task);
      await SyncManager().notifyLocalChange(task.workspaceId);
      await _taskManager.refresh();

      _refreshExportPreview();
      _refreshTrash();
      _logger.d('Task undo successfully and UI refreshed');
      return true;
    } catch (e) {
      _logger.e('Error undoing task: $e');
      return false;
    }
  }

  void _cleanupTaskNotifications(Task task) {
    if (task.todos != null) {
      final shouldSendDeleteReq =
          ref.read(appControllerProvider).emailReminderEnabled;
      final manager =
          ref.read(appControllerProvider.notifier).localNotificationManager;
      for (var todo in task.todos!) {
        manager?.destroy(
          timerKey: todo.uuid,
          sendDeleteReq: shouldSendDeleteReq,
        );
      }
    }
  }

  Future<bool> updateTask(String uuid, Task task) async {
    if (!(await _taskManager.has(uuid))) {
      _logger.w('Task $uuid not found for update');
      return false;
    }
    _logger.d('Updating task: $uuid');
    await _taskManager.updateTask(uuid, task);
    _refreshExportPreview();
    return true;
  }

  /// 移动任务到另一个工作空间
  Future<bool> moveTaskToWorkspace(
    String taskUuid,
    String targetWorkspaceId, {
    DuplicateNameAction? duplicateAction,
  }) async {
    try {
      _logger.d('Moving task $taskUuid to workspace $targetWorkspaceId');

      final task = await _taskManager.repository.readOne(taskUuid);
      if (task == null) {
        _logger.w('Task $taskUuid not found');
        return false;
      }

      final workspaceState = ref.read(workspaceControllerProvider);
      final targetWorkspace = workspaceState.workspaces
          .firstWhereOrNull((w) => w.uuid == targetWorkspaceId);
      if (targetWorkspace == null) {
        _logger.w('Target workspace $targetWorkspaceId not found');
        return false;
      }

      final currentWorkspaceId = workspaceState.currentWorkspaceId;
      final originalWorkspaceId = task.workspaceId;

      final targetTasks =
          await _taskManager.repository.readAll(workspaceId: targetWorkspaceId);
      final duplicateTask = targetTasks.firstWhereOrNull(
        (t) => t.title == task.title && t.uuid != task.uuid,
      );

      if (duplicateTask != null && duplicateAction == null) {
        _logger.d('Target workspace has task with same name: ${task.title}');
        return false;
      }

      if (duplicateTask != null && duplicateAction != null) {
        switch (duplicateAction) {
          case DuplicateNameAction.merge:
            await _mergeTasks(duplicateTask.uuid, taskUuid);
            return true;
          case DuplicateNameAction.rename:
            final sourceWorkspace = workspaceState.workspaces
                .firstWhereOrNull((w) => w.uuid == originalWorkspaceId);
            String? sourceWorkspaceName;
            if (sourceWorkspace != null) {
              sourceWorkspaceName = sourceWorkspace.uuid == 'default'
                  ? l10n.defaultWorkspace
                  : sourceWorkspace.name;
            }
            task.title = '${task.title} - $sourceWorkspaceName';
            break;
          case DuplicateNameAction.allow:
            break;
          case DuplicateNameAction.cancel:
            return false;
        }
      }

      task.workspaceId = targetWorkspaceId;
      await _taskManager.updateTask(taskUuid, task);

      if (originalWorkspaceId == currentWorkspaceId &&
          targetWorkspaceId != currentWorkspaceId) {
        final taskIndex =
            _taskManager.tasks.indexWhere((t) => t.uuid == taskUuid);
        if (taskIndex != -1) {
          _taskManager.tasks.removeAt(taskIndex);
          _emit();
        }
      }

      _refreshExportPreview();
      _logger.d('Task moved successfully to workspace $targetWorkspaceId');
      return true;
    } catch (e) {
      _logger.e('Error moving task to workspace: $e');
      return false;
    }
  }

  /// 合并两个任务
  Future<void> _mergeTasks(String targetTaskUuid, String sourceTaskUuid) async {
    try {
      _logger.d('Merging task $sourceTaskUuid into $targetTaskUuid');
      final targetTask = await _taskManager.repository.readOne(targetTaskUuid);
      final sourceTask = await _taskManager.repository.readOne(sourceTaskUuid);
      if (targetTask == null || sourceTask == null) {
        _logger.w('Target or source task not found');
        return;
      }

      final targetTodos = List<Todo>.from(targetTask.todos ?? []);
      final sourceTodos = List<Todo>.from(sourceTask.todos ?? []);
      for (var todo in sourceTodos) {
        if (!targetTodos.any((t) => t.uuid == todo.uuid)) {
          targetTodos.add(todo);
        }
      }
      targetTask.todos = targetTodos;

      await _taskManager.updateTask(targetTaskUuid, targetTask);
      await _taskManager.removeTask(sourceTaskUuid);
      _logger.d('Tasks merged successfully');
    } catch (e) {
      _logger.e('Error merging tasks: $e');
      rethrow;
    }
  }

  /// 撤销移动任务到工作空间
  Future<bool> undoMoveTaskToWorkspace(
      String taskUuid, String originalWorkspaceId) async {
    try {
      _logger.d(
          'Undoing move task $taskUuid back to workspace $originalWorkspaceId');
      final task = await _taskManager.repository.readOne(taskUuid);
      if (task == null) {
        _logger.w('Task $taskUuid not found');
        return false;
      }

      final currentWorkspaceId =
          ref.read(workspaceControllerProvider).currentWorkspaceId;
      task.workspaceId = originalWorkspaceId;
      await _taskManager.updateTask(taskUuid, task);

      if (originalWorkspaceId == currentWorkspaceId) {
        await refreshData();
        final taskExists = _taskManager.tasks.any((t) => t.uuid == taskUuid);
        if (!taskExists) {
          await _taskManager.refresh(workspaceId: originalWorkspaceId);
        }
      } else {
        await refreshData();
      }

      _refreshExportPreview();
      _logger.d('Task move undone successfully');
      return true;
    } catch (e) {
      _logger.e('Error undoing move task to workspace: $e');
      return false;
    }
  }

  Future<bool> deleteTodo(String taskUuid, String todoUuid) async {
    if (!(await _taskManager.has(taskUuid))) {
      _logger.w('Task $taskUuid not found for todo deletion');
      return false;
    }
    try {
      _logger.d('Deleting todo $todoUuid from task $taskUuid');
      final taskIndex =
          _taskManager.tasks.indexWhere((t) => t.uuid == taskUuid);
      if (taskIndex == -1) {
        _logger.w('Task $taskUuid not found');
        return false;
      }

      final task = _taskManager.tasks[taskIndex];
      if (task.todos == null || task.todos!.isEmpty) {
        _logger.w('Task todos is null or empty');
        return false;
      }

      final todoIndex = task.todos!.indexWhere((todo) => todo.uuid == todoUuid);
      if (todoIndex == -1) {
        _logger.w('Todo $todoUuid not found in task');
        return false;
      }

      final shouldSendDeleteReq =
          ref.read(appControllerProvider).emailReminderEnabled;
      await ref
          .read(appControllerProvider.notifier)
          .localNotificationManager
          ?.destroy(timerKey: todoUuid, sendDeleteReq: shouldSendDeleteReq);

      final newTodos = List<Todo>.from(task.todos!);
      newTodos[todoIndex].deletedAt = DateTime.now().millisecondsSinceEpoch;
      task.todos = newTodos;

      await _taskManager.repository.update(taskUuid, task);
      await SyncManager().notifyLocalChange(task.workspaceId);

      final updatedTask = _cloneTaskShallow(task);
      _taskManager.tasks[taskIndex] = updatedTask;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _emit();
        });
      });

      _refreshExportPreview();
      _refreshTrash();
      _logger.d('Todo deleted successfully and UI refreshed');
      return true;
    } catch (e) {
      _logger.e('Error deleting todo: $e');
      return false;
    }
  }

  /// 恢复已删除的todo（撤销删除）
  Future<bool> undoTodo(String taskUuid, String todoUuid) async {
    if (!(await _taskManager.has(taskUuid))) {
      _logger.w('Task $taskUuid not found for todo undo');
      return false;
    }
    try {
      _logger.d('Undoing todo deletion: $todoUuid from task $taskUuid');
      final taskIndex =
          _taskManager.tasks.indexWhere((t) => t.uuid == taskUuid);
      if (taskIndex == -1) {
        _logger.w('Task $taskUuid not found');
        return false;
      }

      final task = _taskManager.tasks[taskIndex];
      if (task.todos == null || task.todos!.isEmpty) {
        _logger.w('Task todos is null or empty');
        return false;
      }

      final todoIndex = task.todos!.indexWhere((todo) => todo.uuid == todoUuid);
      if (todoIndex == -1) {
        _logger.w('Todo $todoUuid not found in task');
        return false;
      }

      final newTodos = List<Todo>.from(task.todos!);
      newTodos[todoIndex].deletedAt = 0;
      task.todos = newTodos;

      await _taskManager.repository.update(taskUuid, task);
      await SyncManager().notifyLocalChange(task.workspaceId);

      final updatedTask = _cloneTaskShallow(task);
      _taskManager.tasks[taskIndex] = updatedTask;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _emit();
        });
      });

      _refreshExportPreview();
      _refreshTrash();
      _logger.d('Todo undo successfully and UI refreshed');
      return true;
    } catch (e) {
      _logger.e('Error undoing todo: $e');
      return false;
    }
  }

  /// 浅拷贝 Task（保持引用变化以触发重建）。
  Task _cloneTaskShallow(Task task) {
    return Task()
      ..uuid = task.uuid
      ..title = task.title
      ..description = task.description
      ..createdAt = task.createdAt
      ..order = task.order
      ..deletedAt = task.deletedAt
      ..tagsWithColor = task.tagsWithColor
      ..status = task.status
      ..progress = task.progress
      ..reminders = task.reminders
      ..workspaceId = task.workspaceId
      ..customColor = task.customColor
      ..customIcon = task.customIcon
      ..todos = task.todos;
  }

  Future<void> sort({bool reverse = false}) async {
    _logger.d('Sorting tasks by creation date (reverse: $reverse)');
    await _taskManager.sort(reverse: reverse);
  }

  /// 重新排序任务
  Future<void> reorderTask(int oldIndex, int newIndex) async {
    try {
      if (newIndex == allTasks.length + 1) {
        newIndex = allTasks.length;
      }
      await _taskManager.reorderTasks(oldIndex, newIndex);
      _logger.d('Task reordered from $oldIndex to $newIndex');
    } catch (e) {
      _logger.e('Error reordering task: $e');
    }
  }

  TaskStats get taskStats => state.taskStats;

  Future<void> reorderTodo(String taskId, int oldIndex, int newIndex) async {
    try {
      _logger.d('Reordering todo in task $taskId from $oldIndex to $newIndex');
      final taskIndex = allTasks.indexWhere((task) => task.uuid == taskId);
      if (taskIndex == -1) {
        _logger.w('Task $taskId not found for reorder');
        return;
      }

      final task = allTasks[taskIndex];
      if (task.todos == null || task.todos!.isEmpty) {
        _logger.w('Task todos is null or empty');
        return;
      }
      if (oldIndex < 0 || oldIndex >= task.todos!.length) {
        _logger.w('Invalid oldIndex $oldIndex for reorder');
        return;
      }
      if (oldIndex == newIndex) {
        _logger.d('Same index, no reorder needed');
        return;
      }

      final List<Todo> newTodos = List.from(task.todos!);
      final todo = newTodos.removeAt(oldIndex);
      if (newIndex > newTodos.length) newIndex = newTodos.length;
      if (newIndex < 0) newIndex = 0;
      newTodos.insert(newIndex, todo);
      task.todos = newTodos;

      await _taskManager.updateTask(taskId, task);
      _logger.d('Todo reordered successfully');
    } catch (e) {
      _logger.e('Error reordering todo: $e');
      await _taskManager.refresh();
    }
  }

  /// 将todo从一个task移动到另一个task
  Future<void> moveTodoToTask(
      String fromTaskId, String toTaskId, String todoId) async {
    try {
      _logger.d('Moving todo $todoId from task $fromTaskId to task $toTaskId');
      final fromTask = allTasks.firstWhere((task) => task.uuid == fromTaskId);
      final toTask = allTasks.firstWhere((task) => task.uuid == toTaskId);

      if (fromTask.todos == null) {
        _logger.w('Source task todos is null');
        return;
      }

      final todoToMove = fromTask.todos!.firstWhere(
        (todo) => todo.uuid == todoId,
        orElse: () {
          _logger.w('Todo $todoId not found in source task');
          throw Exception('Todo not found');
        },
      );

      final newStatus = _getStatusFromTaskTitle(toTask.title);
      if (newStatus != null && newStatus != todoToMove.status) {
        todoToMove.status = newStatus;
        todoToMove.finishedAt = newStatus == TodoStatus.done
            ? DateTime.now().millisecondsSinceEpoch
            : 0;
      }

      final fromTodos = List<Todo>.from(fromTask.todos!);
      fromTodos.removeWhere((todo) => todo.uuid == todoId);
      fromTask.todos = fromTodos;

      final toTodos = List<Todo>.from(toTask.todos ?? []);
      toTodos.add(todoToMove);
      toTask.todos = toTodos;

      await Future.wait([
        _taskManager.updateTask(fromTaskId, fromTask),
        _taskManager.updateTask(toTaskId, toTask),
      ]);

      _refreshExportPreview();
      _logger.d('Todo $todoId moved successfully');
    } catch (e) {
      _logger.e('Error moving todo between tasks: $e');
      await _taskManager.refresh();
    }
  }

  /// 将 todo 从一个 task 移动到另一个 task（按目标索引插入）
  Future<void> moveTodoToTaskAt(String fromTaskId, String toTaskId,
      String todoId, int targetIndex) async {
    try {
      _logger.d(
          'Moving todo $todoId from task $fromTaskId to task $toTaskId at index $targetIndex');
      final fromTask = allTasks.firstWhere((task) => task.uuid == fromTaskId);
      final toTask = allTasks.firstWhere((task) => task.uuid == toTaskId);

      if (fromTask.todos == null) {
        _logger.w('Source task todos is null');
        return;
      }

      final todoToMove = fromTask.todos!.firstWhere(
        (todo) => todo.uuid == todoId,
        orElse: () {
          _logger.w('Todo $todoId not found in source task');
          throw Exception('Todo not found');
        },
      );

      final newStatus = _getStatusFromTaskTitle(toTask.title);
      if (newStatus != null && newStatus != todoToMove.status) {
        todoToMove.status = newStatus;
        todoToMove.finishedAt = newStatus == TodoStatus.done
            ? DateTime.now().millisecondsSinceEpoch
            : 0;
      }

      final fromTodos = List<Todo>.from(fromTask.todos!);
      fromTodos.removeWhere((todo) => todo.uuid == todoId);
      fromTask.todos = fromTodos;

      // targetIndex 是目标列「可见列表」的索引；toTask.todos 仍含软删除项，
      // 故拆成可见 + 已删除，按可见索引插入后再把已删除项接到末尾（不可见，位置无关）。
      final toFull = List<Todo>.from(toTask.todos ?? []);
      final toDeleted = toFull.where((t) => t.deletedAt != 0).toList();
      final toActive = toFull.where((t) => t.deletedAt == 0).toList();
      targetIndex = targetIndex.clamp(0, toActive.length);
      toActive.insert(targetIndex, todoToMove);
      toTask.todos = [...toActive, ...toDeleted];

      await Future.wait([
        _taskManager.updateTask(fromTaskId, fromTask),
        _taskManager.updateTask(toTaskId, toTask),
      ]);

      _refreshExportPreview();
      _logger.d('Todo $todoId moved successfully to index $targetIndex');
    } catch (e) {
      _logger.e('Error moving todo between tasks at index: $e');
      await _taskManager.refresh();
    }
  }

  TodoStatus? _getStatusFromTaskTitle(String taskTitle) {
    final lowerTitle = taskTitle.toLowerCase();
    if (lowerTitle.contains('todo') ||
        lowerTitle.contains('待办') ||
        lowerTitle.contains('待做') ||
        lowerTitle.contains('未开始')) {
      return TodoStatus.todo;
    } else if (lowerTitle.contains('progress') ||
        lowerTitle.contains('doing') ||
        lowerTitle.contains('进行') ||
        lowerTitle.contains('正在') ||
        lowerTitle.contains('开始')) {
      return TodoStatus.inProgress;
    } else if (lowerTitle.contains('done') ||
        lowerTitle.contains('complete') ||
        lowerTitle.contains('finish') ||
        lowerTitle.contains('完成') ||
        lowerTitle.contains('结束')) {
      return TodoStatus.done;
    }
    _logger.d('Cannot determine status for task title: "$taskTitle"');
    return null;
  }

  bool canMoveTodoToTask(String fromTaskId, String toTaskId) {
    return fromTaskId != toTaskId;
  }

  /// 移动todo到另一个工作空间的task
  Future<bool> moveTodoToWorkspaceTask(
    String fromTaskId,
    String todoId,
    String targetWorkspaceId,
    String targetTaskId, {
    DuplicateNameAction? duplicateAction,
  }) async {
    try {
      _logger.d(
          'Moving todo $todoId from task $fromTaskId to workspace $targetWorkspaceId, task $targetTaskId');
      final fromTask = allTasks.firstWhere(
        (task) => task.uuid == fromTaskId,
        orElse: () {
          _logger.w('Source task $fromTaskId not found');
          throw Exception('Source task not found');
        },
      );

      if (fromTask.todos == null || fromTask.todos!.isEmpty) {
        _logger.w('Source task todos is null or empty');
        return false;
      }

      final todoToMove = fromTask.todos!.firstWhere(
        (todo) => todo.uuid == todoId,
        orElse: () {
          _logger.w('Todo $todoId not found in source task');
          throw Exception('Todo not found');
        },
      );

      // 防御：目标与源是同一个 task 时直接返回，避免 fromTask/toTask 指向同一对象、
      // 以及对同一 uuid 并发双写造成的竞态（UI 已禁止选中当前 task，这里兜底）。
      if (targetTaskId == fromTaskId) {
        _logger.w('Target task is the same as source; nothing to move');
        return false;
      }

      Task? toTask;
      if (targetWorkspaceId == fromTask.workspaceId) {
        toTask = allTasks.firstWhereOrNull((task) => task.uuid == targetTaskId);
      }
      if (toTask == null) {
        toTask = await _taskManager.repository.readOne(targetTaskId);
        if (toTask == null) {
          _logger.w('Target task $targetTaskId not found');
          return false;
        }
        if (toTask.workspaceId != targetWorkspaceId) {
          _logger.w(
              'Target task $targetTaskId is not in workspace $targetWorkspaceId');
          return false;
        }
      }

      final duplicateTodo = (toTask.todos ?? []).firstWhereOrNull(
        (t) =>
            t.title == todoToMove.title &&
            t.uuid != todoToMove.uuid &&
            t.deletedAt == 0,
      );

      if (duplicateTodo != null && duplicateAction == null) {
        _logger.d('Target task has todo with same name: ${todoToMove.title}');
        return false;
      }

      if (duplicateTodo != null && duplicateAction != null) {
        switch (duplicateAction) {
          case DuplicateNameAction.merge:
            await _mergeTodos(duplicateTodo.uuid, todoId, fromTaskId);
            return true;
          case DuplicateNameAction.rename:
            final sourceWorkspace = ref
                .read(workspaceControllerProvider)
                .workspaces
                .firstWhereOrNull((w) => w.uuid == fromTask.workspaceId);
            String? sourceWorkspaceName;
            if (sourceWorkspace != null) {
              sourceWorkspaceName = sourceWorkspace.uuid == 'default'
                  ? l10n.defaultWorkspace
                  : sourceWorkspace.name;
            }
            todoToMove.title = '${todoToMove.title} - $sourceWorkspaceName';
            break;
          case DuplicateNameAction.allow:
            break;
          case DuplicateNameAction.cancel:
            return false;
        }
      }

      final newStatus = _getStatusFromTaskTitle(toTask.title);
      if (newStatus != null && newStatus != todoToMove.status) {
        todoToMove.status = newStatus;
        todoToMove.finishedAt = newStatus == TodoStatus.done
            ? DateTime.now().millisecondsSinceEpoch
            : 0;
      }

      final fromTodos = List<Todo>.from(fromTask.todos!);
      fromTodos.removeWhere((todo) => todo.uuid == todoId);
      fromTask.todos = fromTodos;

      final toTodos = List<Todo>.from(toTask.todos ?? []);
      toTodos.add(todoToMove);
      toTask.todos = toTodos;

      await Future.wait([
        _taskManager.updateTask(fromTaskId, fromTask),
        _taskManager.updateTask(targetTaskId, toTask),
      ]);

      await refreshData();
      _refreshExportPreview();
      _logger
          .d('Todo $todoId moved successfully to workspace $targetWorkspaceId');
      return true;
    } catch (e) {
      _logger.e('Error moving todo to workspace task: $e');
      return false;
    }
  }

  /// 合并两个todo
  Future<void> _mergeTodos(
      String targetTodoUuid, String sourceTodoUuid, String sourceTaskId) async {
    try {
      _logger.d('Merging todo $sourceTodoUuid into $targetTodoUuid');
      final sourceTask = await _taskManager.repository.readOne(sourceTaskId);
      if (sourceTask == null) {
        _logger.w('Source task not found');
        return;
      }

      final sourceTodo = (sourceTask.todos ?? [])
          .firstWhereOrNull((t) => t.uuid == sourceTodoUuid);
      if (sourceTodo == null) {
        _logger.w('Source todo not found');
        return;
      }

      final taskRepository = await TaskRepository.getInstance();
      final targetTaskId =
          await taskRepository.getTaskUuidForTodo(targetTodoUuid);
      if (targetTaskId == null) {
        _logger.w('Target todo task not found');
        return;
      }

      final targetTask = await _taskManager.repository.readOne(targetTaskId);
      if (targetTask == null) {
        _logger.w('Target task not found');
        return;
      }

      final targetTodoIndex =
          (targetTask.todos ?? []).indexWhere((t) => t.uuid == targetTodoUuid);
      if (targetTodoIndex == -1) {
        _logger.w('Target todo not found');
        return;
      }

      final targetTodo = targetTask.todos![targetTodoIndex];
      if (sourceTodo.description.isNotEmpty) {
        if (targetTodo.description.isEmpty) {
          targetTodo.description = sourceTodo.description;
        } else {
          targetTodo.description =
              '${targetTodo.description}\n\n${sourceTodo.description}';
        }
      }

      if (sourceTodo.tagsWithColor.isNotEmpty) {
        final targetTags = List<TagWithColor>.from(targetTodo.tagsWithColor);
        for (var tag in sourceTodo.tagsWithColor) {
          if (!targetTags.any((t) => t.name == tag.name)) {
            targetTags.add(tag);
          }
        }
        targetTodo.tagsWithColor = targetTags;
      }

      final sourceTodos = List<Todo>.from(sourceTask.todos ?? []);
      sourceTodos.removeWhere((t) => t.uuid == sourceTodoUuid);
      sourceTask.todos = sourceTodos;

      targetTask.todos![targetTodoIndex] = targetTodo;

      await Future.wait([
        _taskManager.updateTask(sourceTaskId, sourceTask),
        _taskManager.updateTask(targetTaskId, targetTask),
      ]);
      _logger.d('Todos merged successfully');
    } catch (e) {
      _logger.e('Error merging todos: $e');
      rethrow;
    }
  }

  /// 撤销移动todo到工作空间
  Future<bool> undoMoveTodoToWorkspaceTask(
    String todoId,
    String originalTaskId,
    String originalWorkspaceId,
    String? currentTaskId,
  ) async {
    try {
      _logger.d(
          'Undoing move todo $todoId back to task $originalTaskId in workspace $originalWorkspaceId');
      final originalTask =
          await _taskManager.repository.readOne(originalTaskId);
      if (originalTask == null) {
        _logger.w('Original task $originalTaskId not found');
        return false;
      }

      Task? currentTask;
      String? actualCurrentTaskId = currentTaskId;

      if (actualCurrentTaskId == null) {
        try {
          final taskRepository = await TaskRepository.getInstance();
          actualCurrentTaskId = await taskRepository.getTaskUuidForTodo(todoId);
          if (actualCurrentTaskId == null) {
            final allDbTasks = await _taskManager.repository.readAll();
            for (final task in allDbTasks) {
              if (task.todos != null) {
                final hasTodo = task.todos!
                    .any((todo) => todo.uuid == todoId && todo.deletedAt == 0);
                if (hasTodo) {
                  actualCurrentTaskId = task.uuid;
                  currentTask = task;
                  break;
                }
              }
            }
          }
        } catch (e) {
          _logger.w('Failed to get current task for todo: $e');
          return false;
        }
      }

      if (actualCurrentTaskId == null) {
        _logger.w('Current task not found for todo $todoId');
        return false;
      }

      currentTask ??= await _taskManager.repository.readOne(actualCurrentTaskId);
      if (currentTask == null) {
        _logger.w('Current task $actualCurrentTaskId not found');
        return false;
      }

      Todo? todoToMove;
      if (currentTask.todos != null) {
        todoToMove = currentTask.todos!.firstWhereOrNull(
          (todo) => todo.uuid == todoId && todo.deletedAt == 0,
        );
      }

      if (todoToMove == null) {
        try {
          final taskRepository = await TaskRepository.getInstance();
          todoToMove = await taskRepository.getTodoByUuid(todoId);
          if (todoToMove != null && todoToMove.deletedAt != 0) {
            _logger.w('Todo $todoId is deleted, cannot undo move');
            return false;
          }
        } catch (e) {
          _logger.w('Failed to read todo from database: $e');
        }
      }

      if (todoToMove == null) {
        _logger.w('Todo $todoId not found in current task or database');
        return false;
      }

      final currentTodos = List<Todo>.from(currentTask.todos ?? []);
      currentTodos.removeWhere((todo) => todo.uuid == todoId);
      currentTask.todos = currentTodos;

      final originalTodos = List<Todo>.from(originalTask.todos ?? []);
      originalTodos.add(todoToMove);
      originalTask.todos = originalTodos;

      await Future.wait([
        _taskManager.updateTask(actualCurrentTaskId, currentTask),
        _taskManager.updateTask(originalTaskId, originalTask),
      ]);

      await refreshData();
      _refreshExportPreview();
      _logger.d('Todo move undone successfully');
      return true;
    } catch (e) {
      _logger.e('Error undoing move todo to workspace task: $e');
      return false;
    }
  }

  /// 在同一个task内重新排序todo
  Future<void> reorderTodoInSameTask(
      String taskId, Todo todo, int newIndex) async {
    try {
      _logger.d('Reordering todo in same task $taskId at index $newIndex');
      final task = allTasks.firstWhere((task) => task.uuid == taskId);
      if (task.todos == null || task.todos!.isEmpty) {
        _logger.w('Task todos is null or empty');
        return;
      }

      // newIndex 来自看板，是「可见（未删除）列表」的索引；而 task.todos 里仍保留着
      // 软删除项（deletedAt != 0）。直接对全量列表用可见索引插入会错位，因此这里拆成
      // 可见 + 已删除两部分，对可见列表按其索引重排，再把已删除项接到末尾（不可见，位置无关）。
      final full = List<Todo>.from(task.todos!);
      final deleted = full.where((t) => t.deletedAt != 0).toList();
      final active = full.where((t) => t.deletedAt == 0).toList();
      final oldActiveIndex = active.indexWhere((t) => t.uuid == todo.uuid);
      if (oldActiveIndex == -1) {
        _logger.w('Todo ${todo.uuid} not found in task');
        return;
      }
      active.removeAt(oldActiveIndex);
      newIndex = newIndex.clamp(0, active.length);
      active.insert(newIndex, todo);
      task.todos = [...active, ...deleted];

      await _taskManager.updateTask(taskId, task);
      _logger.d('Todo reordered in same task successfully');
    } catch (e) {
      _logger.e('Error reordering todo in same task: $e');
      await _taskManager.refresh();
    }
  }
}

class TaskStats {
  final int total;
  final int todo;
  final int inProgress;
  final int done;

  TaskStats({
    required this.total,
    required this.todo,
    required this.inProgress,
    required this.done,
  });

  double get completionRate => total > 0 ? done / total : 0;
}
