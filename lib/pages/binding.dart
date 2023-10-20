import 'package:get/get.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/settings/controller.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => DatePickerController());
    Get.put(AddTodoDialogController());
  }
}
