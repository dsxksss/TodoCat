import 'dart:math';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/test/todo.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/controllers/task_manager.dart';
import 'package:todo_cat/controllers/mixins/scroll_controller_mixin.dart';
import 'package:todo_cat/controllers/mixins/task_state_mixin.dart';

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
      if (appCtrl.appConfig.value.isDebugMode) {
        await _addDebugTasks();
      } else {
        await _showEmptyTaskToast();
      }
    }
  }

  Future<void> resetTasksTemplate() async {
    await _taskManager.resetTasksTemplate();
  }

  /// 刷新数据（用于数据导入后更新UI）
  Future<void> refreshData() async {
    _logger.i('刷新主页数据...');
    try {
      // 重新初始化TaskManager，从数据库加载最新数据
      await _taskManager.initialize();
      _logger.i('主页数据刷新成功');
    } catch (e) {
      _logger.e('主页数据刷新失败: $e');
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
        showSuccessNotification("tasksTemplateResetSuccess".tr);
      },
    );
  }

  Future<void> _addDebugTasks() async {
    _logger.d('Adding debug tasks');
    for (var task in defaultTasks) {
      await _taskManager.addTask(task);
      selectTask(task);

      final random = Random();
      final todoCount = random.nextInt(5);
      for (var i = 0; i < todoCount; i++) {
        final todoIndex = random.nextInt(3);
        if (task.todos == null ||
            !task.todos!
                .any((todo) => todo.uuid == todoTestList[todoIndex].uuid)) {
          await addTodo(todoTestList[todoIndex], task.uuid);
        }
      }
      deselectTask();
    }
  }

  // 添加Todo到指定任务
  Future<bool> addTodo(Todo todo, String taskId) async {
    try {
      _logger.d('Adding todo to task: $taskId');

      // 检查任务是否存在
      final task = allTasks.firstWhere(
        (task) => task.uuid == taskId,
      );

      // 初始化 todos 列表
      task.todos ??= [];

      // 添加新的 todo
      task.todos!.add(todo);

      // 重要：保存修改后的任务到数据库
      await _taskManager.updateTask(taskId, task);

      _logger.d('Todo added successfully and saved to database');
      return true;
    } catch (e) {
      _logger.e('Error adding todo: $e');
      return false;
    }
  }

  Future<void> addTask(Task task) async {
    await _taskManager.addTask(task);
  }

  Future<bool> deleteTask(String uuid) async {
    try {
      final task = _taskManager.tasks.firstWhere((task) => task.uuid == uuid);
      _cleanupTaskNotifications(task);
      await _taskManager.removeTask(uuid);
      return true;
    } catch (e) {
      _logger.e('Error deleting task: $e');
      return false;
    }
  }

  void _cleanupTaskNotifications(Task task) {
    if (task.todos != null) {
      for (var todo in task.todos!) {
        appCtrl.localNotificationManager.destroy(
          timerKey: todo.uuid,
          sendDeleteReq: true,
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
    return true;
  }

  Future<bool> deleteTodo(String taskUuid, String todoUuid) async {
    if (!_taskManager.has(taskUuid)) {
      _logger.w('Task $taskUuid not found for todo deletion');
      return false;
    }

    try {
      _logger.d('Deleting todo $todoUuid from task $taskUuid');

      final task =
          _taskManager.tasks.firstWhere((task) => task.uuid == taskUuid);

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

      final todo = task.todos![todoIndex];

      // 清理通知
      await appCtrl.localNotificationManager.destroy(
        timerKey: todoUuid,
        sendDeleteReq: true,
      );

      // 从任务中移除todo
      final removed = task.todos!.remove(todo);
      if (!removed) {
        _logger.w('Todo ${todo.uuid} was not found in task for removal');
        return false;
      }

      // 重要：保存修改后的任务到数据库
      await _taskManager.updateTask(taskUuid, task);

      _logger.d('Todo deleted successfully and saved to database');
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

      // 如果新位置在列表末尾，调整索引
      if (newIndex >= task.todos!.length) {
        newIndex = task.todos!.length - 1;
      }
      if (newIndex < 0) {
        newIndex = 0;
      }

      // 如果索引相同，不需要操作
      if (oldIndex == newIndex) {
        _logger.d('Same index, no reorder needed');
        return;
      }

      // 创建新的todos列表
      final List<Todo> newTodos = List.from(task.todos!);
      final todo = newTodos.removeAt(oldIndex);
      newTodos.insert(newIndex, todo);

      // 更新task的todos
      task.todos = newTodos;

      // 保存更改到存储
      await _taskManager.updateTask(taskId, task);

      // 只刷新UI，不重新从数据库加载
      _taskManager.tasks.refresh();

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

      // 从原task中移除
      fromTask.todos!.removeWhere((todo) => todo.uuid == todoId);

      // 添加到新task中
      toTask.todos ??= [];
      toTask.todos!.add(todoToMove);

      // 批量更新，避免多次数据库操作
      await Future.wait([
        _taskManager.updateTask(fromTaskId, fromTask),
        _taskManager.updateTask(toTaskId, toTask),
      ]);

      // 只刷新一次UI，不重新从数据库加载
      _taskManager.tasks.refresh();

      _logger.d(
          'Todo $todoId moved successfully with status updated to ${todoToMove.status}');
    } catch (e) {
      _logger.e('Error moving todo between tasks: $e');
      // 发生错误时，重新加载数据以确保一致性
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

      // 移除原来的todo
      final todoIndex = task.todos!.indexWhere((t) => t.uuid == todo.uuid);
      if (todoIndex == -1) {
        _logger.w('Todo ${todo.uuid} not found in task');
        return;
      }

      task.todos!.removeAt(todoIndex);

      // 在新位置插入
      newIndex = newIndex.clamp(0, task.todos!.length);
      task.todos!.insert(newIndex, todo);

      // 保存更改
      await _taskManager.updateTask(taskId, task);

      // 只刷新UI，不重新从数据库加载
      _taskManager.tasks.refresh();

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
