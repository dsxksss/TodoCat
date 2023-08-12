import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/services/repositorys/task.dart';

class HomeController extends GetxController {
  late TaskRepository taskRepository;
  final tasks = <Task>[].obs;

  @override
  void onInit() async {
    super.onInit();
    taskRepository = await TaskRepository().init();
    tasks.assignAll(await taskRepository.readAll());
    ever(tasks, (_) => taskRepository.writeMany(tasks));
  }

  bool addTask(Task task) {
    if (taskRepository.has(task.title)) {
      return false;
    }

    tasks.add(task);
    taskRepository.write(task.title, task);
    return true;
  }

  bool deleteTask(String taskTitle) {
    if (!taskRepository.has(taskTitle)) {
      return false;
    }

    tasks.removeWhere((task) => task.title == taskTitle);
    taskRepository.delete(taskTitle);
    return true;
  }
}
