import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/services/repositorys/task.dart';

class HomeController extends GetxController {
  late TaskRepository taskRepository;
  var tasks = <Task>[].obs;

  @override
  void onInit() async {
    super.onInit();
    taskRepository = await TaskRepository().init();
    tasks.value = await taskRepository.readAll();
  }
}
