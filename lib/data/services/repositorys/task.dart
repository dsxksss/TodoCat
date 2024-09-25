import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/strorage.dart';
import 'package:todo_cat/pages/app_ctr.dart';

class TaskRepository extends Storage<Task> {
  final AppController appCtrl = Get.find();
  static TaskRepository? _instance;

  TaskRepository._();

  static Future<TaskRepository> getInstance() async {
    _instance ??= TaskRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    await init('tasksxxxawxl');
    if (appCtrl.appConfig.value.isDebugMode) {
      await box?.clear();
      await writeMany(defaultTasks, (task) => task.id);
    }
  }
}
