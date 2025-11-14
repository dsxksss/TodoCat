import 'package:get/get.dart';
import 'package:TodoCat/controllers/app_ctr.dart';
import 'package:TodoCat/controllers/datepicker_ctr.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/controllers/todo_dialog_ctr.dart';
import 'package:TodoCat/controllers/settings_ctr.dart';
import 'package:TodoCat/controllers/task_dialog_ctr.dart';
import 'package:TodoCat/controllers/timepicker_ctr.dart';
import 'package:TodoCat/controllers/data_export_import_ctr.dart';
import 'package:TodoCat/controllers/trash_ctr.dart';
import 'package:TodoCat/controllers/workspace_ctr.dart';
import 'package:TodoCat/core/notification_stack_manager.dart';
import 'package:TodoCat/core/notification_center_manager.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    // 核心服务
    Get.put(NotificationStackManager(), permanent: true);
    Get.put(NotificationCenterManager(), permanent: true);

    // 主控制器
    Get.put(AppController(), permanent: true);
    Get.put(WorkspaceController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(TrashController(), permanent: true);

    // 功能控制器 - 常驻内存以提高性能
    Get.put(AddTodoDialogController(), tag: 'add_todo_dialog', permanent: true);
    Get.put(DatePickerController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(TaskDialogController(), permanent: true);
    Get.put(TimePickerController(), permanent: true);
    Get.put(DataExportImportController(), permanent: true);
  }
}
