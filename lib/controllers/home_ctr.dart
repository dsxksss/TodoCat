import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/test/todo.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/controllers/task_manager.dart';

mixin ScrollControllerMixin {
  final ScrollController scrollController = ScrollController();
  double currentScrollOffset = 0.0;

  void initScrollController() {
    scrollController.addListener(_scrollListener);
  }

  void disposeScrollController() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
  }

  void _scrollListener() {
    if (_isScrolledToTop() || _isScrolledToBottom()) {
      return;
    }

    if (scrollController.offset != currentScrollOffset &&
        !scrollController.position.outOfRange) {
      SmartDialog.dismiss(tag: dropDownMenuBtnTag);
    }

    currentScrollOffset = scrollController.offset;
  }

  bool _isScrolledToTop() {
    return scrollController.offset <=
            scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange;
  }

  bool _isScrolledToBottom() {
    return scrollController.offset >=
            scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange;
  }

  Future<void> scrollMaxDown() async {
    await 0.1.delay(() => scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: 1000.ms,
          curve: Curves.easeOutCubic,
        ));
  }

  Future<void> scrollMaxTop() async {
    await 0.1.delay(
      () => scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: 1000.ms,
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

class HomeController extends GetxController with ScrollControllerMixin {
  static final _logger = Logger();
  final TaskManager _taskManager = TaskManager();
  final currentTask = Rx<Task?>(null);
  final AppController appCtrl = Get.find();
  final shouldAnimate = true.obs;
  final groupByStatus = false.obs;
  final searchQuery = ''.obs;
  final selectedTaskId = RxString('');

  void selectTask(Task? task) {
    _logger.d('Selecting task: ${task?.uuid}');
    currentTask.value = task;
    selectedTaskId.value = task?.uuid ?? ''; // 更新 selectedTaskId
  }

  void deselectTask() {
    _logger.d('Deselecting current task');
    currentTask.value = null;
    selectedTaskId.value = ''; // 清除 selectedTaskId
  }

  Future<bool> addTodo(Todo todo, String taskId) async {
    try {
      _logger.d('Adding todo to task: $taskId');

      // 检查任务是否存在
      final task = tasks.firstWhere(
        (task) => task.uuid == taskId,
      );

      // 初始化 todos 列表
      task.todos ??= [];

      // 添加新的 todo
      task.todos!.add(todo);
      await updateTask(taskId, task);

      _logger.d('Todo added successfully');
      return true;
    } catch (e) {
      _logger.e('Error adding todo: $e');
      return false;
    }
  }

  List<Task> get filteredTasks {
    if (searchQuery.value.isEmpty) return tasks;
    return tasks
        .where((task) =>
            task.title
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            task.tags.any((tag) =>
                tag.toLowerCase().contains(searchQuery.value.toLowerCase())))
        .toList();
  }

  Map<TaskStatus, List<Task>> get groupedTasks {
    if (!groupByStatus.value) {
      return {TaskStatus.todo: tasks};
    }

    return {
      TaskStatus.todo: tasks.where((t) => t.status == TaskStatus.todo).toList(),
      TaskStatus.inProgress:
          tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
      TaskStatus.done: tasks.where((t) => t.status == TaskStatus.done).toList(),
    };
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

  Future<void> _showEmptyTaskToast() async {
    await 2.delay();
    showToast(
      "当前任务为空, 是否需要添加任务示例模板?",
      alwaysShow: true,
      confirmMode: true,
      onYesCallback: () async {
        await _taskManager.assignAll(defaultTasks);
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
            !task.todos!.contains(todoTestList[todoIndex])) {
          await addTodo(todoTestList[todoIndex], task.uuid);
        }
      }
      deselectTask();
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
      Task task =
          _taskManager.tasks.firstWhere((task) => task.uuid == taskUuid);
      int taskIndex = _taskManager.tasks.indexOf(task);
      if (taskIndex == -1) {
        _logger.w('Task index not found');
        return false;
      }

      if (task.todos == null) {
        _logger.w('Task todos is null');
        return false;
      }

      _logger.d('Deleting todo $todoUuid from task $taskUuid');
      Todo todo = task.todos!.firstWhere((todo) => todo.uuid == todoUuid);
      await appCtrl.localNotificationManager.destroy(
        timerKey: todoUuid,
        sendDeleteReq: true,
      );
      task.todos!.remove(todo);
      await _taskManager.refresh();
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

  /// 获取任务列表
  RxList<Task> get tasks => _taskManager.tasks;

  /// 重新排序任务
  Future<void> reorderTask(int oldIndex, int newIndex) async {
    try {
      if (newIndex == tasks.length + 1) {
        newIndex = tasks.length;
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
        total: tasks.length,
        todo: tasks.where((t) => t.status == TaskStatus.todo).length,
        inProgress:
            tasks.where((t) => t.status == TaskStatus.inProgress).length,
        done: tasks.where((t) => t.status == TaskStatus.done).length,
      );
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
