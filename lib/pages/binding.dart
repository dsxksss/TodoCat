import 'package:get/get.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/todo_dialog_ctr.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/controllers/task_dialog_ctr.dart';
import 'package:todo_cat/controllers/timepicker_ctr.dart';
import 'package:todo_cat/controllers/data_export_import_ctr.dart';
import 'package:todo_cat/core/notification_stack_manager.dart';
import 'package:todo_cat/core/notification_center_manager.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    // 核心服务
    Get.put(NotificationStackManager(), permanent: true);
    Get.put(NotificationCenterManager(), permanent: true);

    // 主控制器
    Get.put(AppController(), permanent: true);
    Get.put(HomeController(), permanent: true);

    // 功能控制器 - 常驻内存以提高性能
    Get.put(AddTodoDialogController(), tag: 'add_todo_dialog', permanent: true);
    Get.put(DatePickerController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(TaskDialogController(), permanent: true);
    Get.put(TimePickerController(), permanent: true);
    Get.put(DataExportImportController(), permanent: true);
  }
}
