import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/data/services/repositorys/task.dart';

class HomeController extends GetxController {
  late TaskRepository taskRepository;

  final tasks = <Task>[].obs;

  @override
  void onInit() async {
    super.onInit();
    taskRepository = await TaskRepository().init();
    tasks.assignAll(await taskRepository.readAll());
    sort(reverse: true);
    ever(tasks, (_) => taskRepository.writeMany(tasks));
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

  bool addTodo(Task task, Todo todo) {
    if (!taskRepository.has(task.title)) {
      return false;
    }

    int taskIndex = tasks.indexOf(task);
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
