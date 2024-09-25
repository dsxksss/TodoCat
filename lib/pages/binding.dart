import 'package:get/get.dart';
import 'package:todo_cat/pages/home/home_ctr.dart';
import 'package:todo_cat/pages/settings/settings_ctr.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(SettingsController());
    Get.put(DatePickerController());
    Get.put(AddTodoDialogController());
  }
}
