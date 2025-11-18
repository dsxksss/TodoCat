import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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
import 'package:todo_cat/controllers/mixins/scroll_controller_mixin.dart';
import 'package:todo_cat/controllers/mixins/task_state_mixin.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'package:todo_cat/widgets/duplicate_name_dialog.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';

class HomeController extends GetxController
    with ScrollControllerMixin, TaskStateMixin {
  static final _logger = Logger();
  final TaskManager _taskManager = TaskManager();
  final AppController appCtrl = Get.find();
  final shouldAnimate = true.obs;
  final isSwitchingWorkspace = false.obs; // 标记是否正在切换工作空间

  // 实现TaskStateMixin需要的allTasks getter
  @override
  List<Task> get allTasks => _taskManager.tasks;

  // 使用TaskManager的简化属性访问
  List<Task> get tasks => _taskManager.tasks;

  // 暴露TaskManager的响应式tasks列表供其他组件监听
  RxList<Task> get reactiveTasks => _taskManager.tasks;

  // 重写TaskStateMixin的回调方法
  @override
  void onTaskSelected(Task? task) {
    _logger.d('Task selected: ${task?.uuid}');
  }

  @override
  void onTaskDeselected() {
    _logger.d('Task deselected');
  }

  @override
  void onInit() async {
    super.onInit();
    _logger.i('Initializing HomeController');
    await _initializeTasks();
    initScrollController();
    await 1.delay(() => shouldAnimate.value = false);
  }

  Future<void> _initializeTasks() async {
    await _taskManager.initialize();

    // 初始化工作空间控制器并刷新任务
    if (Get.isRegistered<WorkspaceController>()) {
      await refreshData();
    } else {
      await _taskManager.refresh();
    }

    if (_taskManager.tasks.isEmpty) {
      await _showEmptyTaskToast();
    }
  }

  Future<void> resetTasksTemplate() async {
    await _taskManager.resetTasksTemplate();
    // 刷新导出预览数据
    _refreshExportPreview();
  }

  /// 刷新数据（用于数据导入后更新UI）
  /// [showEmptyPrompt] 如果为true，当任务为空时显示创建模板的提示
  /// [clearBeforeRefresh] 如果为true，在刷新前清空任务列表（用于切换工作空间时避免显示旧任务）
  Future<void> refreshData(
      {bool showEmptyPrompt = false, bool clearBeforeRefresh = false}) async {
    _logger.i('刷新主页数据...');
    try {
      // 如果需要在刷新前清空，先清空任务列表
      if (clearBeforeRefresh) {
        _taskManager.tasks.clear();
        _taskManager.tasks.refresh();
      }

      // 获取当前工作空间ID
      String? workspaceId;
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        workspaceId = workspaceCtrl.currentWorkspaceId.value;
      }
      // 直接刷新TaskManager，从数据库加载最新数据
      await _taskManager.refresh(workspaceId: workspaceId);
      _logger.i('主页数据刷新成功');

      // 如果任务为空且需要显示提示，则显示创建模板的提示
      if (showEmptyPrompt && _taskManager.tasks.isEmpty) {
        await _showEmptyTaskToast();
      }
    } catch (e) {
      _logger.e('刷新主页数据失败: $e');
    }
  }

  /// 保存当前所有任务为模板
  void saveAsTemplate() {
    if (tasks.isEmpty) {
      showErrorNotification('noTasksToSave'.tr);
      return;
    }

    // 过滤掉已删除的任务
    final validTasks = tasks.where((task) => task.deletedAt == 0).toList();

    if (validTasks.isEmpty) {
      showErrorNotification('noTasksToSave'.tr);
      return;
    }

    showSaveTemplateDialog(validTasks);
  }

  /// 刷新导出预览数据
  void _refreshExportPreview() {
    try {
      final dataController = Get.find<DataExportImportController>();
      dataController.refreshPreview();
    } catch (e) {
      // 如果找不到DataExportImportController，忽略错误
      _logger.d('未找到DataExportImportController，跳过刷新导出预览: $e');
    }
  }

  /// 刷新回收站数据
  void _refreshTrash() {
    try {
      if (Get.isRegistered<TrashController>()) {
        final trashController = Get.find<TrashController>();
        trashController.refresh();
      }
    } catch (e) {
      // 如果找不到TrashController，忽略错误
      _logger.d('未找到TrashController，跳过刷新回收站: $e');
    }
  }

  Future<void> _showEmptyTaskToast() async {
    // 减少延迟，让提示更快出现
    await 0.5.delay();
    showToast(
      "isResetTasksTemplate".tr,
      alwaysShow: true,
      confirmMode: true,
      tag: 'empty_task_prompt', // 添加唯一 tag，方便后续关闭
      onYesCallback: () async {
        await resetTasksTemplate();
      },
    );
  }

  // 添加Todo到指定任务
  Future<bool> addTodo(Todo todo, String taskId) async {
    try {
      _logger.d('Adding todo to task: $taskId');

      // 检查任务是否存在
      final task = allTasks.firstWhere(
        (task) => task.uuid == taskId,
      );

      // 初始化 todos 列表并添加新的 todo（创建可变副本）
      final newTodos = List<Todo>.from(task.todos ?? []);
      newTodos.add(todo);
      task.todos = newTodos;

      // 重要：保存修改后的任务到数据库
      await _taskManager.updateTask(taskId, task);

      // 刷新导出预览数据
      _refreshExportPreview();

      _logger.d('Todo added successfully and saved to database');
      return true;
    } catch (e) {
      _logger.e('Error adding todo: $e');
      return false;
    }
  }

  Future<void> addTask(Task task) async {
    // 设置工作空间ID
    if (Get.isRegistered<WorkspaceController>()) {
      final workspaceCtrl = Get.find<WorkspaceController>();
      task.workspaceId = workspaceCtrl.currentWorkspaceId.value;
    }
    await _taskManager.addTask(task);
    // 刷新导出预览数据
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

      // 使用repository.delete标记task和所有todos为已删除
      await _taskManager.repository.delete(uuid);

      // 从内存中移除（因为已标记为删除，readAll不会读取）
      _taskManager.tasks.removeAt(taskIndex);
      _taskManager.tasks.refresh();

      // 刷新导出预览数据
      _refreshExportPreview();
      // 刷新回收站数据，更新badge
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

      // 从数据库读取task（包括已删除的）
      final task = await _taskManager.repository.readOne(uuid);
      if (task == null) {
        _logger.w('Task $uuid not found in database');
        return false;
      }

      // 恢复task（将deletedAt设置为0）
      task.deletedAt = 0;

      // 恢复所有相关的todos
      if (task.todos != null && task.todos!.isNotEmpty) {
        final newTodos = List<Todo>.from(task.todos!);
        for (var todo in newTodos) {
          todo.deletedAt = 0;
        }
        task.todos = newTodos;
      }

      // 保存到数据库
      await _taskManager.repository.update(uuid, task);

      // 重新加载所有任务（包括恢复的task）
      await _taskManager.refresh();

      // 刷新导出预览数据
      _refreshExportPreview();

      // 刷新回收站数据，更新badge
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
      // 根据邮箱提醒设置决定是否发送删除请求
      final shouldSendDeleteReq = appCtrl.appConfig.value.emailReminderEnabled;

      for (var todo in task.todos!) {
        appCtrl.localNotificationManager?.destroy(
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
    // 刷新导出预览数据
    _refreshExportPreview();
    return true;
  }

  /// 移动任务到另一个工作空间
  /// [duplicateAction] 如果存在同名任务时的处理方式
  Future<bool> moveTaskToWorkspace(
    String taskUuid,
    String targetWorkspaceId, {
    DuplicateNameAction? duplicateAction,
  }) async {
    try {
      _logger.d('Moving task $taskUuid to workspace $targetWorkspaceId');

      // 获取任务
      final task = await _taskManager.repository.readOne(taskUuid);
      if (task == null) {
        _logger.w('Task $taskUuid not found');
        return false;
      }

      // 检查目标工作空间是否存在
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        final targetWorkspace = workspaceCtrl.workspaces.firstWhereOrNull(
          (w) => w.uuid == targetWorkspaceId,
        );
        if (targetWorkspace == null) {
          _logger.w('Target workspace $targetWorkspaceId not found');
          return false;
        }
      }

      // 获取当前工作空间ID（在更新之前）
      String? currentWorkspaceId;
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        currentWorkspaceId = workspaceCtrl.currentWorkspaceId.value;
      }

      final originalWorkspaceId = task.workspaceId;

      // 检查目标工作空间是否已有同名任务
      final targetTasks =
          await _taskManager.repository.readAll(workspaceId: targetWorkspaceId);
      final duplicateTask = targetTasks.firstWhereOrNull(
        (t) => t.title == task.title && t.uuid != task.uuid,
      );

      // 如果存在同名任务且未指定处理方式，需要用户选择
      if (duplicateTask != null && duplicateAction == null) {
        _logger.d('Target workspace has task with same name: ${task.title}');
        // 返回false，让UI层显示对话框
        return false;
      }

      // 根据用户选择处理同名任务
      if (duplicateTask != null && duplicateAction != null) {
        switch (duplicateAction) {
          case DuplicateNameAction.merge:
            // 合并：将源task的todos合并到目标task，然后删除源task
            await _mergeTasks(duplicateTask.uuid, taskUuid);
            return true;
          case DuplicateNameAction.rename:
            // 重命名：添加工作空间后缀
            String? sourceWorkspaceName;
            if (Get.isRegistered<WorkspaceController>()) {
              final workspaceCtrl = Get.find<WorkspaceController>();
              final sourceWorkspace = workspaceCtrl.workspaces.firstWhereOrNull(
                (w) => w.uuid == originalWorkspaceId,
              );
              if (sourceWorkspace != null) {
                sourceWorkspaceName = sourceWorkspace.uuid == 'default'
                    ? 'defaultWorkspace'.tr
                    : sourceWorkspace.name;
              }
            }
            task.title = '${task.title} - $sourceWorkspaceName';
            break;
          case DuplicateNameAction.allow:
            // 允许同名：直接移动
            break;
          case DuplicateNameAction.cancel:
            // 取消：不执行移动
            return false;
        }
      }

      // 更新任务的工作空间ID
      task.workspaceId = targetWorkspaceId;

      // 保存到数据库
      await _taskManager.updateTask(taskUuid, task);

      // 如果任务原本在当前工作空间中，从列表中移除
      if (originalWorkspaceId == currentWorkspaceId) {
        // 如果移动到其他工作空间，从当前列表中移除
        if (targetWorkspaceId != currentWorkspaceId) {
          final taskIndex =
              _taskManager.tasks.indexWhere((t) => t.uuid == taskUuid);
          if (taskIndex != -1) {
            _taskManager.tasks.removeAt(taskIndex);
            _taskManager.tasks.refresh();
          }
        }
        // 如果移动到当前工作空间（不应该发生，但处理一下），刷新列表
        // 实际上这种情况不应该发生，因为对话框会禁用当前工作空间
      }

      // 刷新导出预览数据
      _refreshExportPreview();

      _logger.d('Task moved successfully to workspace $targetWorkspaceId');
      return true;
    } catch (e) {
      _logger.e('Error moving task to workspace: $e');
      return false;
    }
  }

  /// 合并两个任务（将源任务的todos合并到目标任务，然后删除源任务）
  Future<void> _mergeTasks(String targetTaskUuid, String sourceTaskUuid) async {
    try {
      _logger.d('Merging task $sourceTaskUuid into $targetTaskUuid');

      // 获取目标task和源task
      final targetTask = await _taskManager.repository.readOne(targetTaskUuid);
      final sourceTask = await _taskManager.repository.readOne(sourceTaskUuid);

      if (targetTask == null || sourceTask == null) {
        _logger.w('Target or source task not found');
        return;
      }

      // 合并todos
      final targetTodos = List<Todo>.from(targetTask.todos ?? []);
      final sourceTodos = List<Todo>.from(sourceTask.todos ?? []);

      // 添加源task的todos到目标task（避免重复uuid）
      for (var todo in sourceTodos) {
        if (!targetTodos.any((t) => t.uuid == todo.uuid)) {
          targetTodos.add(todo);
        }
      }

      targetTask.todos = targetTodos;

      // 更新目标task
      await _taskManager.updateTask(targetTaskUuid, targetTask);

      // 删除源task
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

      // 获取任务
      final task = await _taskManager.repository.readOne(taskUuid);
      if (task == null) {
        _logger.w('Task $taskUuid not found');
        return false;
      }

      // 获取当前工作空间ID
      String? currentWorkspaceId;
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        currentWorkspaceId = workspaceCtrl.currentWorkspaceId.value;
      }

      // 恢复原始工作空间ID
      task.workspaceId = originalWorkspaceId;

      // 保存到数据库
      await _taskManager.updateTask(taskUuid, task);

      // 如果原始工作空间是当前工作空间，刷新列表以显示任务
      // 如果原始工作空间不是当前工作空间，任务已经移回，但不会显示在当前UI中（这是正常的）
      if (originalWorkspaceId == currentWorkspaceId) {
        // 任务移回当前工作空间，需要刷新显示
        await refreshData();
        // 确保任务在列表中
        final taskExists = _taskManager.tasks.any((t) => t.uuid == taskUuid);
        if (!taskExists) {
          // 如果任务不在列表中，重新加载
          await _taskManager.refresh(workspaceId: originalWorkspaceId);
        }
      } else {
        // 任务移回其他工作空间，只需要刷新当前工作空间的数据
        await refreshData();
      }

      // 刷新导出预览数据
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

      // 找到要删除的todo
      final todoIndex = task.todos!.indexWhere((todo) => todo.uuid == todoUuid);
      if (todoIndex == -1) {
        _logger.w('Todo $todoUuid not found in task');
        return false;
      }

      // 清理通知，根据邮箱提醒设置决定是否发送删除请求
      final shouldSendDeleteReq = appCtrl.appConfig.value.emailReminderEnabled;
      await appCtrl.localNotificationManager?.destroy(
        timerKey: todoUuid,
        sendDeleteReq: shouldSendDeleteReq,
      );

      // 标记todo为已删除而不是从列表中移除
      // 创建一个新的todos列表，确保触发UI更新
      final newTodos = List<Todo>.from(task.todos!);
      final updatedTodo = newTodos[todoIndex];
      final deleteTime = DateTime.now().millisecondsSinceEpoch;
      updatedTodo.deletedAt = deleteTime;
      task.todos = newTodos;

      // 注意：不再自动删除空的 task
      // 即使所有 todos 都被删除，task 也应该保留，除非用户手动删除 task

      // 关键：先保存到数据库
      await _taskManager.repository.update(taskUuid, task);

      // 然后触发内存更新（创建新对象，确保引用变化）
      final updatedTask = Task()
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
        ..todos = task.todos; // 包含已更新的 todos

      _taskManager.tasks[taskIndex] = updatedTask;

      // 延迟刷新UI，避免与正在进行的动画冲突（修复 setState after dispose 错误）
      // 使用多个 postFrameCallback 确保所有动画完成后再刷新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_taskManager.tasks.isNotEmpty || _taskManager.tasks.isEmpty) {
            _taskManager.tasks.refresh();
          }
        });
      });

      // 刷新导出预览数据
      _refreshExportPreview();

      // 刷新回收站数据，更新badge
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

      // 找到要恢复的todo
      final todoIndex = task.todos!.indexWhere((todo) => todo.uuid == todoUuid);
      if (todoIndex == -1) {
        _logger.w('Todo $todoUuid not found in task');
        return false;
      }

      // 恢复todo（将deletedAt设置为0）
      final newTodos = List<Todo>.from(task.todos!);
      final updatedTodo = newTodos[todoIndex];
      updatedTodo.deletedAt = 0;
      task.todos = newTodos;

      // 保存到数据库
      await _taskManager.repository.update(taskUuid, task);

      // 触发内存更新
      final updatedTask = Task()
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
        ..todos = task.todos;

      _taskManager.tasks[taskIndex] = updatedTask;

      // 延迟刷新UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_taskManager.tasks.isNotEmpty || _taskManager.tasks.isEmpty) {
            _taskManager.tasks.refresh();
          }
        });
      });

      // 刷新导出预览数据
      _refreshExportPreview();

      // 刷新回收站数据，更新badge
      _refreshTrash();

      _logger.d('Todo undo successfully and UI refreshed');
      return true;
    } catch (e) {
      _logger.e('Error undoing todo: $e');
      return false;
    }
  }

  Future<void> sort({bool reverse = false}) async {
    _logger.d('Sorting tasks by creation date (reverse: $reverse)');
    await _taskManager.sort(reverse: reverse);
  }

  @override
  void onClose() {
    _logger.d('Cleaning up HomeController resources');
    disposeScrollController();
    super.onClose();
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

  void startDragging() {
    shouldAnimate.value = true;
  }

  void endDragging() {
    shouldAnimate.value = false;
  }

  TaskStats get taskStats => TaskStats(
        total: allTasks.length,
        todo: allTasks.where((t) => t.status == TaskStatus.todo).length,
        inProgress:
            allTasks.where((t) => t.status == TaskStatus.inProgress).length,
        done: allTasks.where((t) => t.status == TaskStatus.done).length,
      );

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

      // 如果索引相同，不需要操作
      if (oldIndex == newIndex) {
        _logger.d('Same index, no reorder needed');
        return;
      }

      // 创建新的todos列表
      final List<Todo> newTodos = List.from(task.todos!);
      final todo = newTodos.removeAt(oldIndex);

      // 在 removeAt 之后调整 newIndex（此时列表长度已经减1）
      // 确保 newIndex 在有效范围内
      if (newIndex > newTodos.length) {
        newIndex = newTodos.length;
      }
      if (newIndex < 0) {
        newIndex = 0;
      }

      newTodos.insert(newIndex, todo);

      // 更新task的todos
      task.todos = newTodos;

      // 保存更改到存储（updateTask 会自动刷新UI）
      await _taskManager.updateTask(taskId, task);

      _logger.d('Todo reordered successfully');
    } catch (e) {
      _logger.e('Error reordering todo: $e');
      // 发生错误时，重新加载数据以确保一致性
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

      // 找到要移动的todo
      final todoToMove = fromTask.todos!.firstWhere(
        (todo) => todo.uuid == todoId,
        orElse: () {
          _logger.w('Todo $todoId not found in source task');
          throw Exception('Todo not found');
        },
      );

      // 根据目标task的类型智能更新todo的状态
      final newStatus = _getStatusFromTaskTitle(toTask.title);
      if (newStatus != null && newStatus != todoToMove.status) {
        _logger.d(
            'Updating todo status from ${todoToMove.status} to $newStatus based on target task: ${toTask.title}');
        todoToMove.status = newStatus;

        // 如果移动到完成状态，记录完成时间
        if (newStatus == TodoStatus.done) {
          todoToMove.finishedAt = DateTime.now().millisecondsSinceEpoch;
        } else {
          // 如果从完成状态移动到其他状态，清除完成时间
          todoToMove.finishedAt = 0;
        }
      }

      // 从原task中移除（创建可变副本）
      final fromTodos = List<Todo>.from(fromTask.todos!);
      fromTodos.removeWhere((todo) => todo.uuid == todoId);
      fromTask.todos = fromTodos;

      // 添加到新task中（创建可变副本）
      final toTodos = List<Todo>.from(toTask.todos ?? []);
      toTodos.add(todoToMove);
      toTask.todos = toTodos;

      // 批量更新，避免多次数据库操作（updateTask 会自动刷新UI）
      await Future.wait([
        _taskManager.updateTask(fromTaskId, fromTask),
        _taskManager.updateTask(toTaskId, toTask),
      ]);

      // 刷新导出预览数据
      _refreshExportPreview();

      _logger.d(
          'Todo $todoId moved successfully with status updated to ${todoToMove.status}');
    } catch (e) {
      _logger.e('Error moving todo between tasks: $e');
      // 发生错误时，重新加载数据以确保一致性
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

      // 找到要移动的 todo
      final todoToMove = fromTask.todos!.firstWhere(
        (todo) => todo.uuid == todoId,
        orElse: () {
          _logger.w('Todo $todoId not found in source task');
          throw Exception('Todo not found');
        },
      );

      // 根据目标 task 的类型智能更新 todo 的状态
      final newStatus = _getStatusFromTaskTitle(toTask.title);
      if (newStatus != null && newStatus != todoToMove.status) {
        _logger.d(
            'Updating todo status from ${todoToMove.status} to $newStatus based on target task: ${toTask.title}');
        todoToMove.status = newStatus;
        if (newStatus == TodoStatus.done) {
          todoToMove.finishedAt = DateTime.now().millisecondsSinceEpoch;
        } else {
          todoToMove.finishedAt = 0;
        }
      }

      // 从原 task 中移除
      final fromTodos = List<Todo>.from(fromTask.todos!);
      fromTodos.removeWhere((todo) => todo.uuid == todoId);
      fromTask.todos = fromTodos;

      // 插入到目标 task 的指定位置
      final toTodos = List<Todo>.from(toTask.todos ?? []);
      targetIndex = targetIndex.clamp(0, toTodos.length);
      toTodos.insert(targetIndex, todoToMove);
      toTask.todos = toTodos;

      // 批量更新（updateTask 会自动刷新UI）
      await Future.wait([
        _taskManager.updateTask(fromTaskId, fromTask),
        _taskManager.updateTask(toTaskId, toTask),
      ]);

      _refreshExportPreview();
      _logger.d(
          'Todo $todoId moved successfully to index $targetIndex with status ${todoToMove.status}');
    } catch (e) {
      _logger.e('Error moving todo between tasks at index: $e');
      await _taskManager.refresh();
    }
  }

  /// 根据task的标题推断todo的状态
  TodoStatus? _getStatusFromTaskTitle(String taskTitle) {
    final lowerTitle = taskTitle.toLowerCase();

    // 匹配常见的任务类型名称
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

    // 对于"其他"或其他无法识别的task类型，保持原状态
    _logger.d(
        'Cannot determine status for task title: "$taskTitle", keeping original status');
    return null;
  }

  /// 检查是否可以将todo移动到目标task
  bool canMoveTodoToTask(String fromTaskId, String toTaskId) {
    // 这里可以添加一些验证逻辑，比如检查目标task是否允许添加todo等
    return fromTaskId != toTaskId;
  }

  /// 移动todo到另一个工作空间的task
  /// [duplicateAction] 如果存在同名todo时的处理方式
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

      // 获取源task
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

      // 找到要移动的todo
      final todoToMove = fromTask.todos!.firstWhere(
        (todo) => todo.uuid == todoId,
        orElse: () {
          _logger.w('Todo $todoId not found in source task');
          throw Exception('Todo not found');
        },
      );

      // 获取目标task（可能不在当前工作空间，需要从数据库读取）
      Task? toTask;
      if (targetWorkspaceId == fromTask.workspaceId) {
        // 如果在同一个工作空间，从内存中获取
        toTask = allTasks.firstWhereOrNull((task) => task.uuid == targetTaskId);
      }

      if (toTask == null) {
        // 如果不在当前工作空间，从数据库读取
        toTask = await _taskManager.repository.readOne(targetTaskId);
        if (toTask == null) {
          _logger.w('Target task $targetTaskId not found');
          return false;
        }
        // 确保目标task在目标工作空间中
        if (toTask.workspaceId != targetWorkspaceId) {
          _logger.w(
              'Target task $targetTaskId is not in workspace $targetWorkspaceId');
          return false;
        }
      }

      // 检查目标task是否已有同名todo
      final duplicateTodo = (toTask.todos ?? []).firstWhereOrNull(
        (t) =>
            t.title == todoToMove.title &&
            t.uuid != todoToMove.uuid &&
            t.deletedAt == 0,
      );

      // 如果存在同名todo且未指定处理方式，需要用户选择
      if (duplicateTodo != null && duplicateAction == null) {
        _logger.d('Target task has todo with same name: ${todoToMove.title}');
        // 返回false，让UI层显示对话框
        return false;
      }

      // 根据用户选择处理同名todo
      if (duplicateTodo != null && duplicateAction != null) {
        switch (duplicateAction) {
          case DuplicateNameAction.merge:
            // 合并：将源todo的内容合并到目标todo，然后删除源todo
            await _mergeTodos(duplicateTodo.uuid, todoId, fromTaskId);
            return true;
          case DuplicateNameAction.rename:
            // 重命名：添加工作空间后缀
            String? sourceWorkspaceName;
            if (Get.isRegistered<WorkspaceController>()) {
              final workspaceCtrl = Get.find<WorkspaceController>();
              final sourceWorkspace = workspaceCtrl.workspaces.firstWhereOrNull(
                (w) => w.uuid == fromTask.workspaceId,
              );
              if (sourceWorkspace != null) {
                sourceWorkspaceName = sourceWorkspace.uuid == 'default'
                    ? 'defaultWorkspace'.tr
                    : sourceWorkspace.name;
              }
            }
            todoToMove.title = '${todoToMove.title} - $sourceWorkspaceName';
            break;
          case DuplicateNameAction.allow:
            // 允许同名：直接移动
            break;
          case DuplicateNameAction.cancel:
            // 取消：不执行移动
            return false;
        }
      }

      // 根据目标task的类型智能更新todo的状态
      final newStatus = _getStatusFromTaskTitle(toTask.title);
      if (newStatus != null && newStatus != todoToMove.status) {
        _logger.d(
            'Updating todo status from ${todoToMove.status} to $newStatus based on target task: ${toTask.title}');
        todoToMove.status = newStatus;

        // 如果移动到完成状态，记录完成时间
        if (newStatus == TodoStatus.done) {
          todoToMove.finishedAt = DateTime.now().millisecondsSinceEpoch;
        } else {
          // 如果从完成状态移动到其他状态，清除完成时间
          todoToMove.finishedAt = 0;
        }
      }

      // 从源task中移除（创建可变副本）
      final fromTodos = List<Todo>.from(fromTask.todos!);
      fromTodos.removeWhere((todo) => todo.uuid == todoId);
      fromTask.todos = fromTodos;

      // 添加到目标task中（创建可变副本）
      final toTodos = List<Todo>.from(toTask.todos ?? []);
      toTodos.add(todoToMove);
      toTask.todos = toTodos;

      // 批量更新
      await Future.wait([
        _taskManager.updateTask(fromTaskId, fromTask),
        _taskManager.updateTask(targetTaskId, toTask),
      ]);

      // 如果目标task不在当前工作空间，刷新当前工作空间的任务列表
      String? currentWorkspaceId;
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        currentWorkspaceId = workspaceCtrl.currentWorkspaceId.value;
      }

      if (targetWorkspaceId != currentWorkspaceId) {
        // 目标task不在当前工作空间，只需要刷新当前工作空间的任务列表
        await refreshData();
      } else {
        // 目标task在当前工作空间，但可能不在内存中（如果是从其他工作空间移动过来的）
        // 刷新数据以确保显示最新的任务列表
        await refreshData();
      }

      // 刷新导出预览数据
      _refreshExportPreview();

      _logger.d(
          'Todo $todoId moved successfully to workspace $targetWorkspaceId, task $targetTaskId');
      return true;
    } catch (e) {
      _logger.e('Error moving todo to workspace task: $e');
      return false;
    }
  }

  /// 合并两个todo（将源todo的内容合并到目标todo，然后删除源todo）
  Future<void> _mergeTodos(
      String targetTodoUuid, String sourceTodoUuid, String sourceTaskId) async {
    try {
      _logger.d('Merging todo $sourceTodoUuid into $targetTodoUuid');

      // 获取源task
      final sourceTask = await _taskManager.repository.readOne(sourceTaskId);
      if (sourceTask == null) {
        _logger.w('Source task not found');
        return;
      }

      // 找到源todo
      final sourceTodo = (sourceTask.todos ?? []).firstWhereOrNull(
        (t) => t.uuid == sourceTodoUuid,
      );

      if (sourceTodo == null) {
        _logger.w('Source todo not found');
        return;
      }

      // 找到目标todo所在的task
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

      // 找到目标todo
      final targetTodoIndex = (targetTask.todos ?? []).indexWhere(
        (t) => t.uuid == targetTodoUuid,
      );

      if (targetTodoIndex == -1) {
        _logger.w('Target todo not found');
        return;
      }

      // 合并内容：合并描述、标签等
      final targetTodo = targetTask.todos![targetTodoIndex];
      if (sourceTodo.description.isNotEmpty) {
        if (targetTodo.description.isEmpty) {
          targetTodo.description = sourceTodo.description;
        } else {
          targetTodo.description =
              '${targetTodo.description}\n\n${sourceTodo.description}';
        }
      }

      // 合并标签
      if (sourceTodo.tagsWithColor.isNotEmpty) {
        final targetTags = List<TagWithColor>.from(targetTodo.tagsWithColor);
        for (var tag in sourceTodo.tagsWithColor) {
          if (!targetTags.any((t) => t.name == tag.name)) {
            targetTags.add(tag);
          }
        }
        targetTodo.tagsWithColor = targetTags;
      }

      // 从源task中移除源todo
      final sourceTodos = List<Todo>.from(sourceTask.todos ?? []);
      sourceTodos.removeWhere((t) => t.uuid == sourceTodoUuid);
      sourceTask.todos = sourceTodos;

      // 更新目标task中的todo
      targetTask.todos![targetTodoIndex] = targetTodo;

      // 批量更新
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
    String? currentTaskId, // 可选：todo当前所在的taskId，如果不提供则尝试查找
  ) async {
    try {
      _logger.d(
          'Undoing move todo $todoId back to task $originalTaskId in workspace $originalWorkspaceId');

      // 获取原始task
      final originalTask =
          await _taskManager.repository.readOne(originalTaskId);
      if (originalTask == null) {
        _logger.w('Original task $originalTaskId not found');
        return false;
      }

      // 获取当前task（todo现在所在的task）
      Task? currentTask;
      String? actualCurrentTaskId = currentTaskId;

      // 如果没有提供currentTaskId，尝试查找
      if (actualCurrentTaskId == null) {
        try {
          final taskRepository = await TaskRepository.getInstance();
          actualCurrentTaskId = await taskRepository.getTaskUuidForTodo(todoId);

          if (actualCurrentTaskId == null) {
            // 如果getTaskUuidForTodo找不到，尝试从所有task中查找
            _logger.d(
                'getTaskUuidForTodo returned null, searching all tasks for todo $todoId');
            final allTasks = await _taskManager.repository.readAll();
            for (final task in allTasks) {
              if (task.todos != null) {
                final hasTodo = task.todos!
                    .any((todo) => todo.uuid == todoId && todo.deletedAt == 0);
                if (hasTodo) {
                  actualCurrentTaskId = task.uuid;
                  currentTask = task;
                  _logger.d(
                      'Found todo $todoId in task ${task.uuid} by searching all tasks');
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

      // 如果还是没有找到，返回失败
      if (actualCurrentTaskId == null) {
        _logger.w('Current task not found for todo $todoId');
        return false;
      }

      // 如果currentTask还没有设置，从数据库读取
      if (currentTask == null) {
        currentTask =
            await _taskManager.repository.readOne(actualCurrentTaskId);
        if (currentTask == null) {
          _logger.w('Current task $actualCurrentTaskId not found');
          return false;
        }
      }

      // 尝试从currentTask的todos中找到todo
      Todo? todoToMove;
      if (currentTask.todos != null) {
        todoToMove = currentTask.todos!.firstWhereOrNull(
          (todo) => todo.uuid == todoId && todo.deletedAt == 0,
        );
      }

      // 如果从task的todos中找不到，尝试从数据库直接读取
      if (todoToMove == null) {
        _logger.d(
            'Todo $todoId not found in current task todos, trying to read from database');
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

      // 从当前task中移除
      final currentTodos = List<Todo>.from(currentTask.todos ?? []);
      currentTodos.removeWhere((todo) => todo.uuid == todoId);
      currentTask.todos = currentTodos;

      // 添加到原始task中
      final originalTodos = List<Todo>.from(originalTask.todos ?? []);
      originalTodos.add(todoToMove);
      originalTask.todos = originalTodos;

      // 批量更新
      await Future.wait([
        _taskManager.updateTask(actualCurrentTaskId, currentTask),
        _taskManager.updateTask(originalTaskId, originalTask),
      ]);

      // 刷新数据以确保UI状态正确
      await refreshData();

      // 刷新导出预览数据
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

      // 移除原来的todo并重新插入（创建可变副本）
      final todoIndex = task.todos!.indexWhere((t) => t.uuid == todo.uuid);
      if (todoIndex == -1) {
        _logger.w('Todo ${todo.uuid} not found in task');
        return;
      }

      final newTodos = List<Todo>.from(task.todos!);
      newTodos.removeAt(todoIndex);

      // 在新位置插入
      newIndex = newIndex.clamp(0, newTodos.length);
      newTodos.insert(newIndex, todo);
      task.todos = newTodos;

      // 保存更改（updateTask 会自动刷新UI）
      await _taskManager.updateTask(taskId, task);

      _logger.d('Todo reordered in same task successfully');
    } catch (e) {
      _logger.e('Error reordering todo in same task: $e');
      // 发生错误时，重新加载数据以确保一致性
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
