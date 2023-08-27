import 'dart:io';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/data/services/repositorys/task.dart';

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
  final selectedPriority = Rx<TodoPriority>(TodoPriority.lowLevel);

  @override
  void onInit() async {
    super.onInit();
    taskRepository = await TaskRepository().init();
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
    if (!taskRepository.has(taskId)) {
      return false;
    }

    tasks.removeWhere((task) => task.id == taskId);
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

    if (!taskRepository.has(currentTask.value!.id)) {
      return false;
    }

    int taskIndex = tasks.indexOf(currentTask.value);
    if (taskIndex == -1) {
      return false;
    }

    tasks[taskIndex].todos.add(todo);
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
