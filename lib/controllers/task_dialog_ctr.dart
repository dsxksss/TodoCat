import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_cat/controllers/base_dialog_ctr.dart';

class TaskDialogController extends BaseDialogController {
  Task? taskToEdit;
  final homeController = Get.find<HomeController>();

  Map<String, dynamic>? _originalState;

  @override
  void onInit() {
    super.onInit();
    _originalState = null;
  }

  void initForEditing(Task task) {
    taskToEdit = task;
    isEditing.value = true;

    // 保存原有状态
    titleController.text = task.title;
    descriptionController.text = task.description;
    selectedTags.value = List<String>.from(task.tags); // 创建新列表以避免引用

    // 记录原始状态用于比较
    _originalState = {
      'title': task.title,
      'description': task.description,
      'tags': List<String>.from(task.tags),
    };
  }

  // 添加一个方法检查是否有更改
  bool hasChanges() {
    if (!isEditing.value || _originalState == null) return false;

    return titleController.text != _originalState!['title'] ||
        descriptionController.text != _originalState!['description'] ||
        !listEquals(selectedTags, _originalState!['tags'] as List<String>);
  }

  // 添加一个方法恢复原始状态
  void restoreOriginalState() {
    if (!isEditing.value || _originalState == null) return;

    titleController.text = _originalState!['title'] as String;
    descriptionController.text = _originalState!['description'] as String;
    selectedTags.value =
        List<String>.from(_originalState!['tags'] as List<String>);
  }

  @override
  void clearForm() {
    super.clearForm();
    taskToEdit = null;
    isEditing.value = false;
    _originalState = null;
  }

  void submitTask() async {
    if (!formKey.currentState!.validate()) return;

    if (isEditing.value && taskToEdit != null) {
      final updatedTask = Task()
        ..uuid = taskToEdit!.uuid
        ..title = titleController.text
        ..description = descriptionController.text
        ..tags = selectedTags.toList()
        ..createdAt = taskToEdit!.createdAt;

      final success =
          await homeController.updateTask(taskToEdit!.uuid, updatedTask);

      SmartDialog.dismiss(tag: addTaskDialogTag);

      if (success) {
        showToast(
          'taskUpdatedSuccessfully'.tr,
          toastStyleType: TodoCatToastStyleType.success,
        );
      } else {
        showToast(
          'taskUpdateFailed'.tr,
          toastStyleType: TodoCatToastStyleType.error,
        );
      }
    } else {
      final task = Task()
        ..uuid = const Uuid().v4()
        ..title = titleController.text
        ..description = descriptionController.text
        ..tags = selectedTags.toList()
        ..createdAt = DateTime.now().millisecondsSinceEpoch;

      await homeController.addTask(task);

      SmartDialog.dismiss(tag: addTaskDialogTag);

      showToast(
        'taskAddedSuccessfully'.tr,
        toastStyleType: TodoCatToastStyleType.success,
      );
    }
  }
}
