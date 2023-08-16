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
