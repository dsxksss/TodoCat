import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/data/services/repositorys/task.dart';

class HomeController extends GetxController {
  late TaskRepository taskRepository;

  final tasks = <Task>[].obs;
  final currentTask = Rx<Task?>(null);

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
