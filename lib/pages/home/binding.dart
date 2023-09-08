import 'package:get/get.dart';
import 'package:todo_cat/pages/home/controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.put(AddTodoDialogController());
  }
}
