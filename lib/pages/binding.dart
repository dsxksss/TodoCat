import 'package:get/get.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/add_todo_dialog_ctr.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(AddTodoDialogController());
    Get.put(DatePickerController());
    Get.lazyPut(() => SettingsController());
  }
}
