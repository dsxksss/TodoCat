import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/data/services/repositorys/task.dart';

class HomeController extends GetxController {
  late TaskRepository taskRepository;

  final tasks = <Task>[].obs;
  final List<String> selectedTags = <String>[].obs;
  final currentTask = Rx<Task?>(null);
  final selectedPriority = Rx<TodoPriority>(TodoPriority.lowLevel);

  final formKey = GlobalKey<FormState>();
  final titleFormCtrl = TextEditingController();
  final descriptionFormCtrl = TextEditingController();
  final tagController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    taskRepository = await TaskRepository().init();
    final localTasks = await taskRepository.readAll();
    tasks.assignAll(localTasks);

    // 按创建序号排序渲染
    sort(reverse: true);
    // 第一次读取内容复写给tasks
    once(tasks, (_) => taskRepository.writeMany(tasks));
    // 后续数据发生改变则运行更新操作
    ever(tasks, (_) => taskRepository.updateMant(tasks));
  }

  void addTag() {
    if (tagController.text.isNotEmpty && selectedTags.length < 3) {
      selectedTags.add(tagController.text);
      tagController.clear();
    }
  }

  void removeTag(int index) {
    selectedTags.removeAt(index);
  }

  bool addTask(Task task) {
    if (taskRepository.has(task.title)) {
      return false;
    }

    tasks.add(task);
    return true;
  }

  bool deleteTask(String taskTitle) {
    if (!taskRepository.has(taskTitle)) {
      return false;
    }

    tasks.removeWhere((task) => task.title == taskTitle);
    return true;
  }

  void selectTask(Task? task) {
    currentTask.value = task;
  }

  void deselectTask() {
    currentTask.value = null;
  }

  void onDialogClose() {
    titleFormCtrl.text = "";
    descriptionFormCtrl.text = '';
    tagController.text = "";
    selectedTags.clear();
  }

  bool addTodo(Todo todo) {
    if (currentTask.value == null) {
      return false;
    }

    if (!taskRepository.has(currentTask.value!.title)) {
      return false;
    }

    int taskIndex = tasks.indexOf(currentTask.value);
    if (taskIndex < 0) {
      return false;
    }

    tasks[taskIndex].todos.add(todo);
    tasks.refresh();
    return true;
  }

  void sort({bool reverse = false}) {
    tasks.sort(reverse
        ? (a, b) => a.id.compareTo(b.id)
        : (a, b) => b.id.compareTo(a.id));
    tasks.refresh();
  }
}
