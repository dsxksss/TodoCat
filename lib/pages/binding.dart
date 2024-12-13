import 'package:get/get.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/add_todo_dialog_ctr.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/controllers/task_dialog_ctr.dart';
import 'package:todo_cat/controllers/timepicker_ctr.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    // 主控制器
    Get.put(AppController(), permanent: true);
    Get.put(HomeController(), permanent: true);

    // 功能控制器 - 常驻内存以提高性能
    Get.put(AddTodoDialogController(), tag: 'add_todo_dialog', permanent: true);
    Get.put(DatePickerController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(TaskDialogController(), permanent: true);
    Get.put(TimePickerController(), permanent: true);
  }
}
