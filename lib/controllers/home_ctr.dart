import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/controllers/app_ctr.dart';
import 'package:TodoCat/controllers/data_export_import_ctr.dart';
import 'package:TodoCat/controllers/trash_ctr.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:logger/logger.dart';
import 'package:TodoCat/controllers/task_manager.dart';
import 'package:TodoCat/controllers/mixins/scroll_controller_mixin.dart';
import 'package:TodoCat/controllers/mixins/task_state_mixin.dart';

class HomeController extends GetxController
    with ScrollControllerMixin, TaskStateMixin {
  static final _logger = Logger();
  final TaskManager _taskManager = TaskManager();
  final AppController appCtrl = Get.find();
  final shouldAnimate = true.obs;

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
  Future<void> refreshData() async {
    _logger.i('刷新主页数据...');
    try {
      // 直接刷新TaskManager，从数据库加载最新数据
      await _taskManager.refresh();
      _logger.i('主页数据刷新成功');
    } catch (e) {
      _logger.e('主页数据刷新失败: $e');
    }
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
    await 2.delay();
    showToast(
      "isResetTasksTemplate".tr,
      alwaysShow: true,
      confirmMode: true,
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
    await _taskManager.addTask(task);
    // 刷新导出预览数据
    _refreshExportPreview();
  }

  Future<bool> deleteTask(String uuid) async {
    try {
      final task = _taskManager.tasks.firstWhere((task) => task.uuid == uuid);
      _cleanupTaskNotifications(task);
      await _taskManager.removeTask(uuid);
      
      // removeTask 已经会自动刷新UI，无需额外调用 refresh()
      
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

  void _cleanupTaskNotifications(Task task) {
    if (task.todos != null) {
      // 根据邮箱提醒设置决定是否发送删除请求
      final shouldSendDeleteReq = appCtrl.appConfig.value.emailReminderEnabled;
      
      for (var todo in task.todos!) {
        appCtrl.localNotificationManager.destroy(
          timerKey: todo.uuid,
          sendDeleteReq: shouldSendDeleteReq,
        );
      }
    }
  }

  Future<bool> updateTask(String uuid, Task task) async {
    if (!_taskManager.has(uuid)) {
      _logger.w('Task $uuid not found for update');
      return false;
    }

    _logger.d('Updating task: $uuid');
    await _taskManager.updateTask(uuid, task);
    // 刷新导出预览数据
    _refreshExportPreview();
    return true;
  }

  Future<bool> deleteTodo(String taskUuid, String todoUuid) async {
    if (!_taskManager.has(taskUuid)) {
      _logger.w('Task $taskUuid not found for todo deletion');
      return false;
    }

    try {
      _logger.d('Deleting todo $todoUuid from task $taskUuid');

      final taskIndex = _taskManager.tasks.indexWhere((t) => t.uuid == taskUuid);
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
      await appCtrl.localNotificationManager.destroy(
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
  Future<void> moveTodoToTaskAt(
      String fromTaskId, String toTaskId, String todoId, int targetIndex) async {
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
