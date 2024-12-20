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
    ever(isEditing, (_) {
      // 当编辑状态改变时，确保数据正确更新
      if (isEditing.value && taskToEdit != null) {
        _updateFormData();
      }
    });
  }

  void _updateFormData() {
    titleController.text = taskToEdit!.title;
    descriptionController.text =
        taskToEdit!.description.isEmpty ? '' : taskToEdit!.description;
    selectedTags.value = List<String>.from(taskToEdit!.tags);
  }

  void initForEditing(Task task) {
    taskToEdit = task;
    isEditing.value = true;

    // 保存原有状态
    titleController.text = task.title;
    descriptionController.text =
        task.description.isEmpty ? '' : task.description;
    selectedTags.value = List<String>.from(task.tags);

    // 记录原始状态用于比较
    _originalState = {
      'title': task.title,
      'description': task.description.isEmpty ? '' : task.description,
      'tags': List<String>.from(task.tags),
    };

    BaseDialogController.logger.d('Original task state saved: $_originalState');
  }

  bool hasChanges() {
    if (!isEditing.value || _originalState == null) return false;

    // 只有当实际有改变时才返回 true
    bool titleChanged = titleController.text != _originalState!['title'];
    bool descriptionChanged =
        descriptionController.text != _originalState!['description'];
    bool tagsChanged =
        !listEquals(selectedTags, _originalState!['tags'] as List<String>);

    // 调试日志
    if (titleChanged) {
      BaseDialogController.logger.d(
          'Task title changed: ${titleController.text} != ${_originalState!['title']}');
    }
    if (descriptionChanged) {
      BaseDialogController.logger.d(
          'Task description changed: ${descriptionController.text} != ${_originalState!['description']}');
    }
    if (tagsChanged) {
      BaseDialogController.logger
          .d('Task tags changed: $selectedTags != ${_originalState!['tags']}');
    }

    return titleChanged || descriptionChanged || tagsChanged;
  }

  void restoreOriginalState() {
    if (!isEditing.value || _originalState == null) return;

    titleController.text = _originalState!['title'] as String;
    descriptionController.text = _originalState!['description'] as String;
    selectedTags.value =
        List<String>.from(_originalState!['tags'] as List<String>);
  }

  @override
  void clearForm() {
    BaseDialogController.logger.d('Clearing task form');
    super.clearForm();
    taskToEdit = null;
    isEditing.value = false;
    _originalState = null;
  }

  Future<void> submitTask() async {
    if (!formKey.currentState!.validate()) return;

    if (isEditing.value && taskToEdit != null) {
      final updatedTask = Task()
        ..uuid = taskToEdit!.uuid
        ..title = titleController.text
        ..description = descriptionController.text
        ..tags = selectedTags.toList()
        ..createdAt = taskToEdit!.createdAt
        ..todos = taskToEdit!.todos;

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
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = [];

      await homeController.addTask(task);

      SmartDialog.dismiss(tag: addTaskDialogTag);

      showToast(
        'taskAddedSuccessfully'.tr,
        toastStyleType: TodoCatToastStyleType.success,
      );
    }
  }
}
