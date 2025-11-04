import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/schemas/tag_with_color.dart';
import 'package:TodoCat/keys/dialog_keys.dart';
import 'package:uuid/uuid.dart';
import 'package:TodoCat/controllers/base/base_form_controller.dart';
import 'package:TodoCat/controllers/mixins/edit_state_mixin.dart';

class TaskDialogController extends BaseFormController with EditStateMixin {
  final homeController = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    ever(isEditing, (_) {
      // 当编辑状态改变时，确保数据正确更新
      if (isEditing.value && getEditingItem<Task>() != null) {
        _updateFormData();
      }
    });
  }

  void _updateFormData() {
    final task = getEditingItem<Task>()!;
    titleController.text = task.title;
    descriptionController.text =
        task.description.isEmpty ? '' : task.description;
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (task.tagsWithColor.isNotEmpty) {
      selectedTags.value = task.tagsWithColor;
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      selectedTags.value = task.tags.map((tag) => TagWithColor.fromString(tag)).toList();
    }
  }

  void initForEditing(Task task) {
    // 设置表单数据
    titleController.text = task.title;
    descriptionController.text =
        task.description.isEmpty ? '' : task.description;
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (task.tagsWithColor.isNotEmpty) {
      selectedTags.value = task.tagsWithColor;
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      selectedTags.value = task.tags.map((tag) => TagWithColor.fromString(tag)).toList();
    }

    // 使用编辑状态管理
    final state = {
      'title': task.title,
      'description': task.description.isEmpty ? '' : task.description,
      'tags': List<String>.from(task.tags),
    };

    initEditing(task, state);
  }

  @override
  bool checkForChanges(Map<String, dynamic> originalState) {
    bool titleChanged =
        !compareStrings(titleController.text, originalState['title']);
    bool descriptionChanged = !compareStrings(
        descriptionController.text, originalState['description']);
    bool tagsChanged = !compareListEquality(
        selectedTags, originalState['tags'] as List<String>);

    // 调试日志
    if (titleChanged) {
      BaseFormController.logger.d(
          'Task title changed: ${titleController.text} != ${originalState['title']}');
    }
    if (descriptionChanged) {
      BaseFormController.logger.d(
          'Task description changed: ${descriptionController.text} != ${originalState['description']}');
    }
    if (tagsChanged) {
      BaseFormController.logger
          .d('Task tags changed: $selectedTags != ${originalState['tags']}');
    }

    return titleChanged || descriptionChanged || tagsChanged;
  }

  @override
  void restoreToOriginalState(Map<String, dynamic> originalState) {
    titleController.text = originalState['title'] as String;
    descriptionController.text = originalState['description'] as String;
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (originalState['tagsWithColor'] != null) {
      final tagsWithColorJson = originalState['tagsWithColor'] as List<dynamic>;
      selectedTags.value = tagsWithColorJson
          .map((tagJson) => TagWithColor.fromJson(tagJson as Map<String, dynamic>))
          .toList();
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      selectedTags.value = (originalState['tags'] as List<String>)
          .map((tag) => TagWithColor.fromString(tag))
          .toList();
    }
  }

  @override
  void clearForm() {
    BaseFormController.logger.d('Clearing task form');
    super.clearForm();
    exitEditing();
  }

  Future<void> submitTask() async {
    if (!validateForm()) return;

    if (isEditing.value && getEditingItem<Task>() != null) {
      final currentTask = getEditingItem<Task>()!;
      final updatedTask = Task()
        ..uuid = currentTask.uuid
        ..title = titleController.text
        ..description = descriptionController.text
        ..tagsWithColor = selectedTags.toList()
        ..createdAt = currentTask.createdAt
        ..todos = currentTask.todos;

      final success =
          await homeController.updateTask(currentTask.uuid, updatedTask);

      SmartDialog.dismiss(tag: addTaskDialogTag);

      // 只在失败时显示通知，成功时不添加消息到消息中心
      if (!success) {
        showErrorToast('taskUpdateFailed'.tr);
      }
    } else {
      final task = Task()
        ..uuid = const Uuid().v4()
        ..title = titleController.text
        ..description = descriptionController.text
        ..tagsWithColor = selectedTags.toList()
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = [];

      await homeController.addTask(task);
      SmartDialog.dismiss(tag: addTaskDialogTag);
      showSuccessToast('taskAddedSuccessfully'.tr);
    }
  }
}
