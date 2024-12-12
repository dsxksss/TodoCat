import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/test/todo.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/core/utils/date_time.dart';
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
  final listAnimatInterval = 200.ms.obs;
  final AppController appCtrl = Get.find();
  final shouldAnimate = true.obs;

  final groupByStatus = false.obs;

  final searchQuery = ''.obs;

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
      await _showEmptyTaskToast();
    }

    if (appCtrl.appConfig.value.isDebugMode) {
      _addDebugTasks();
    }

    sort(reverse: true);

    ever(_taskManager.tasks, (_) {
      _logger.d('Tasks changed, updating repository');
      _taskManager.updateMany(_taskManager.tasks, (task) => task.id);
    });
  }

  Future<void> _showEmptyTaskToast() async {
    await 2.delay();
    showToast(
      "当前任务为空, 是否需要添加任务示例模板?",
      alwaysShow: true,
      confirmMode: true,
      onYesCallback: () => _taskManager.assignAll(defaultTasks),
    );
  }

  void _addDebugTasks() {
    _logger.d('Adding debug tasks');
    final random = Random();
    for (var task in defaultTasks) {
      selectTask(task);
      final todoCount = random.nextInt(5);
      for (var i = 0; i < todoCount; i++) {
        final todoIndex = random.nextInt(3);
        if (!task.todos.contains(todoTestList[todoIndex])) {
          addTodo(todoTestList[todoIndex]);
        }
      }
      deselectTask();
    }
  }

  void addTask(Task task) {
    _taskManager.addTask(task);
  }

  bool deleteTask(String taskId) {
    try {
      final task = _taskManager.tasks.firstWhere((task) => task.id == taskId);
      _cleanupTaskNotifications(task);
      _taskManager.removeTask(taskId);
      return true;
    } catch (e) {
      _logger.e('Error deleting task: $e');
      return false;
    }
  }

  void _cleanupTaskNotifications(Task task) {
    for (var todo in task.todos) {
      appCtrl.localNotificationManager.destroy(
        timerKey: todo.id,
        sendDeleteReq: true,
      );
    }
  }

  bool updateTask(String taskId, Task task) {
    if (!_taskManager.has(taskId)) {
      _logger.w('Task $taskId not found for update');
      return false;
    }

    _logger.d('Updating task: $taskId');
    _taskManager.updateTask(taskId, task);
    return true;
  }

  void selectTask(Task? task) {
    _logger.d('Selecting task: ${task?.id}');
    currentTask.value = task;
  }

  void deselectTask() {
    _logger.d('Deselecting current task');
    currentTask.value = null;
  }

  bool addTodo(Todo todo) {
    if (currentTask.value == null || !_taskManager.has(currentTask.value!.id)) {
      _logger.w('No current task selected or task not found');
      return false;
    }

    int taskIndex = _taskManager.tasks.indexOf(currentTask.value);
    if (taskIndex == -1) {
      _logger.w('Task index not found');
      return false;
    }

    _logger.d('Adding todo to task: ${currentTask.value!.id}');
    _taskManager.tasks[taskIndex].todos.add(todo);
    _handleTodoReminder(todo);

    _taskManager.tasks[taskIndex].todos
        .sort((a, b) => b.priority.index.compareTo(a.priority.index));
    _taskManager.refresh();
    return true;
  }

  void _handleTodoReminder(Todo todo) {
    if (todo.reminders != 0) {
      _logger.d('Setting up reminder for todo: ${todo.id}');
      final LocalNotice notice = LocalNotice(
        id: todo.id,
        title: "${"todoCat".tr} ${"taskReminder".tr}",
        description:
            "${todo.title} ${"createTime".tr}:${timestampToDate(todo.createdAt)} ${getTimeString(DateTime.fromMillisecondsSinceEpoch(todo.createdAt))}",
        createdAt: todo.createdAt,
        remindersAt: todo.reminders,
        email: "2546650292@qq.com",
      );
      appCtrl.localNotificationManager.saveNotification(
        key: notice.id,
        notice: notice,
        emailReminderEnabled: appCtrl.appConfig.value.emailReminderEnabled,
      );
    }
  }

  bool deleteTodo(String taskId, String todoId) {
    if (!_taskManager.has(taskId)) {
      _logger.w('Task $taskId not found for todo deletion');
      return false;
    }

    Task task = _taskManager.tasks.singleWhere((task) => task.id == taskId);
    int taskIndex = _taskManager.tasks.indexOf(task);
    if (taskIndex == -1) {
      _logger.w('Task index not found');
      return false;
    }

    _logger.d('Deleting todo $todoId from task $taskId');
    Todo todo = task.todos.singleWhere((todo) => todo.id == todoId);
    appCtrl.localNotificationManager.destroy(
      timerKey: todoId,
      sendDeleteReq: true,
    );
    task.todos.remove(todo);
    _taskManager.refresh();
    return true;
  }

  void sort({bool reverse = false}) {
    _logger.d('Sorting tasks by creation date (reverse: $reverse)');
    _taskManager.sort(reverse: reverse);
    _taskManager.refresh();
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
  void reorderTask(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= tasks.length) return;
    if (newIndex < 0 || newIndex > tasks.length) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
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
