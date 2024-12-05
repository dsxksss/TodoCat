import 'package:get/get.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/add_todo_dialog_ctr.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    // 主控制器
    Get.put(HomeController(), permanent: true);

    // 功能控制器 - 常驻内存以提高性能
    Get.put(AddTodoDialogController(), permanent: true);
    Get.put(DatePickerController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }
}
