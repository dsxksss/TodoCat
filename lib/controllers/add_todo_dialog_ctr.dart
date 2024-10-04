import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/show_toast.dart';

class AddTodoDialogController extends GetxController {
  final formKey = GlobalKey<FormState>(); // 用于验证的表单键。
  final selectedTags = RxList<String>(); // 可观察的选中标签列表。
  final selectedPriority =
      Rx<TodoPriority>(TodoPriority.lowLevel); // 可观察的选中优先级。
  final titleFormCtrl = TextEditingController(); // 标题输入控制器。
  final descriptionFormCtrl = TextEditingController(); // 描述输入控制器。
  final tagController = TextEditingController(); // 标签输入控制器。
  final remindersText = RxString("${"enter".tr}${"time".tr}"); // 可观察的提醒文本。
  final remindersValue = RxInt(0); // 可观察的提醒值。

  // 向选中标签列表添加标签。
  void addTag() {
    if (tagController.text.isNotEmpty) {
      if (selectedTags.length < 3) {
        selectedTags.add(tagController.text); // 如果标签少于 3 个，添加标签。
        tagController.clear(); // 清空标签输入。
      } else {
        showToast(
          "tagsUpperLimit".tr,
          toastStyleType: TodoCatToastStyleType.warning,
        ); // 如果标签达到上限，显示警告。
      }
    }
  }

  // 检查所有表单数据是否为空。
  bool isDataEmpty() {
    return selectedTags.isEmpty &&
        titleFormCtrl.text.isEmpty &&
        descriptionFormCtrl.text.isEmpty &&
        tagController.text.isEmpty &&
        remindersValue.value == 0;
  }

  // 检查是否有任何表单数据不为空。
  bool isDataNotEmpty() => !isDataEmpty();

  // 从选中标签列表中移除标签。
  void removeTag(int index) {
    selectedTags.removeAt(index);
  }

  // 清空所有表单数据。
  void clearForm() {
    titleFormCtrl.clear();
    descriptionFormCtrl.clear();
    tagController.clear();
    selectedTags.clear();
    selectedPriority.value = TodoPriority.lowLevel;
    remindersText.value = "";
    remindersValue.value = 0;
  }
}
