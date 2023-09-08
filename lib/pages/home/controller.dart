import 'dart:io';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:todo_cat/app.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';

class HomeController extends GetxController {
  late TaskRepository taskRepository;

  final logger = Logger(
    // printer: PrettyPrinter(),
    output: FileOutput(
      file: File("TodoCat-HomeCtrlLog.txt"),
    ),
  );

  final tasks = RxList<Task>();
  final currentTask = Rx<Task?>(null);

  final AppController appCtrl = Get.find();

  @override
  void onInit() async {
    super.onInit();
    taskRepository = await TaskRepository.getInstance();
    final localTasks = await taskRepository.readAll();
    tasks.assignAll(localTasks);

    // 按创建序号排序渲染
    sort(reverse: true);

    // 后续数据发生改变则运行更新操作
    ever(tasks, (_) => taskRepository.updateMany(tasks));
  }

  bool addTask(Task task) {
    if (taskRepository.has(task.id)) {
      return false;
    }

    tasks.add(task);
    return true;
  }

  bool deleteTask(String taskId) {
    if (taskRepository.hasNot(taskId)) {
      return false;
    }

    tasks.removeWhere((task) => task.id == taskId);
    return true;
  }

  bool updateTask(String taskId, Task task) {
    if (!taskRepository.hasNot(taskId)) {
      return false;
    }

    taskRepository.update(taskId, task);
    return true;
  }

  void selectTask(Task? task) {
    currentTask.value = task;
  }

  void deselectTask() {
    currentTask.value = null;
  }

  bool addTodo(Todo todo) {
    if (currentTask.value == null) {
      return false;
    }

    if (taskRepository.hasNot(currentTask.value!.id)) {
      return false;
    }

    int taskIndex = tasks.indexOf(currentTask.value);
    if (taskIndex == -1) {
      return false;
    }

    tasks[taskIndex].todos.add(todo);

    if (todo.reminders != 0) {
      final LocalNotice notice = LocalNotice(
        id: todo.id,
        title: "您有一个任务已经失效",
        description: "${todo.title},创建时间:${todo.createdAt}",
        createdAt: DateTime.now().millisecondsSinceEpoch,
        remindersAt: todo.reminders,
      );
      appCtrl.localNotificationManager.saveNotification(notice.id, notice);
    }

    tasks.refresh();
    return true;
  }

  void sort({bool reverse = false}) {
    tasks.sort(reverse
        ? (a, b) => a.createdAt.compareTo(b.createdAt)
        : (a, b) => b.createdAt.compareTo(a.createdAt));
    tasks.refresh();
  }
}

class AddTodoDialogController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final selectedTags = RxList<String>();
  final selectedPriority = Rx<TodoPriority>(TodoPriority.lowLevel);
  final titleFormCtrl = TextEditingController();
  final descriptionFormCtrl = TextEditingController();
  final tagController = TextEditingController();
  final remindersController = TextEditingController();

  void addTag() {
    if (tagController.text.isNotEmpty && selectedTags.length < 3) {
      selectedTags.add(tagController.text);
      tagController.clear();
    }
  }

  void removeTag(int index) {
    selectedTags.removeAt(index);
  }

  void onDialogClose() {
    titleFormCtrl.clear();
    descriptionFormCtrl.clear();
    tagController.clear();
    selectedTags.clear();
  }
}
