import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_cat/controllers/base/base_form_controller.dart';
import 'package:todo_cat/controllers/mixins/edit_state_mixin.dart';

class TaskDialogController extends BaseFormController with EditStateMixin {
  final homeController = Get.find<HomeController>();

  final Rxn<int> selectedCustomColor = Rxn<int>();
  final Rxn<int> selectedCustomIcon = Rxn<int>();

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
    selectedCustomColor.value = task.customColor;
    selectedCustomIcon.value = task.customIcon;

    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (task.tagsWithColor.isNotEmpty) {
      selectedTags.value = task.tagsWithColor;
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      selectedTags.value =
          task.tags.map((tag) => TagWithColor.fromString(tag)).toList();
    }
  }

  void initForEditing(Task task) {
    // 从 HomeController 的响应式列表中获取最新的 task 数据
    Task latestTask = task;
    try {
      final foundTask = homeController.reactiveTasks.firstWhereOrNull(
        (t) => t.uuid == task.uuid,
      );
      if (foundTask != null) {
        latestTask = foundTask;
      }
    } catch (e) {
      // 如果获取失败，使用传入的 task
    }

    // 设置表单数据
    titleController.text = latestTask.title;
    descriptionController.text =
        latestTask.description.isEmpty ? '' : latestTask.description;
    selectedCustomColor.value = latestTask.customColor;
    selectedCustomIcon.value = latestTask.customIcon;

    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (latestTask.tagsWithColor.isNotEmpty) {
      // 创建深拷贝，避免直接修改原始数据
      selectedTags.value = latestTask.tagsWithColor
          .map((tag) => TagWithColor(name: tag.name, color: tag.color))
          .toList();
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      selectedTags.value =
          latestTask.tags.map((tag) => TagWithColor.fromString(tag)).toList();
    }

    // 使用编辑状态管理
    final state = {
      'title': latestTask.title,
      'description':
          latestTask.description.isEmpty ? '' : latestTask.description,
      'tags': List<String>.from(latestTask.tags),
      'tagsWithColor':
          latestTask.tagsWithColor.map((tag) => tag.toJson()).toList(),
      'customColor': latestTask.customColor,
      'customIcon': latestTask.customIcon,
    };

    initEditing(latestTask, state);
  }

  @override
  bool checkForChanges(Map<String, dynamic> originalState) {
    bool titleChanged =
        !compareStrings(titleController.text, originalState['title']);
    bool descriptionChanged = !compareStrings(
        descriptionController.text, originalState['description']);

    // 比较带颜色的标签
    bool tagsChanged = false;
    if (originalState['tagsWithColor'] != null) {
      final originalTags = (originalState['tagsWithColor'] as List<dynamic>)
          .map((tag) => TagWithColor.fromJson(tag as Map<String, dynamic>))
          .toList();
      tagsChanged = selectedTags.length != originalTags.length ||
          !selectedTags.every((tag) => originalTags.any((originalTag) =>
              originalTag.name == tag.name &&
              originalTag.colorValue == tag.colorValue));
    } else {
      // 兼容旧格式
      tagsChanged = !compareListEquality(
          selectedTags.map((t) => t.name).toList(),
          originalState['tags'] as List<String>);
    }
    bool colorChanged =
        selectedCustomColor.value != originalState['customColor'];
    bool iconChanged = selectedCustomIcon.value != originalState['customIcon'];

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
    if (colorChanged) {
      BaseFormController.logger.d(
          'Task color changed: ${selectedCustomColor.value} != ${originalState['customColor']}');
    }
    if (iconChanged) {
      BaseFormController.logger.d(
          'Task icon changed: ${selectedCustomIcon.value} != ${originalState['customIcon']}');
    }

    return titleChanged ||
        descriptionChanged ||
        tagsChanged ||
        colorChanged ||
        iconChanged;
  }

  @override
  void restoreToOriginalState(Map<String, dynamic> originalState) {
    titleController.text = originalState['title'] as String;
    descriptionController.text = originalState['description'] as String;
    selectedCustomColor.value = originalState['customColor'] as int?;
    selectedCustomIcon.value = originalState['customIcon'] as int?;

    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (originalState['tagsWithColor'] != null) {
      final tagsWithColorJson = originalState['tagsWithColor'] as List<dynamic>;
      selectedTags.value = tagsWithColorJson
          .map((tagJson) =>
              TagWithColor.fromJson(tagJson as Map<String, dynamic>))
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
    selectedCustomColor.value = null;
    selectedCustomIcon.value = null;
    exitEditing();
  }

  Future<bool> submitTask() async {
    if (!validateForm()) return false;

    if (isEditing.value && getEditingItem<Task>() != null) {
      final currentTask = getEditingItem<Task>()!;
      final updatedTask = Task()
        ..uuid = currentTask.uuid
        ..workspaceId = currentTask.workspaceId // 保留原有 workspaceId
        ..order = currentTask.order // 保留排序
        ..title = titleController.text
        ..description = descriptionController.text
        ..tagsWithColor = selectedTags.toList()
        ..createdAt = currentTask.createdAt
        ..status = currentTask.status // 保留状态
        ..finishedAt = currentTask.finishedAt // 保留完成时间
        ..progress = currentTask.progress // 保留进度
        ..deletedAt = currentTask.deletedAt // 保留删除时间戳
        ..todos = currentTask.todos
        ..customColor = selectedCustomColor.value
        ..customIcon = selectedCustomIcon.value;

      final success =
          await homeController.updateTask(currentTask.uuid, updatedTask);

      // 只在失败时显示通知，成功时不添加消息到消息中心
      if (!success) {
        showErrorToast('taskUpdateFailed'.tr);
        return false;
      }
      return true;
    } else {
      final task = Task()
        ..uuid = const Uuid().v4()
        ..title = titleController.text
        ..description = descriptionController.text
        ..tagsWithColor = selectedTags.toList()
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = []
        ..customColor = selectedCustomColor.value
        ..customIcon = selectedCustomIcon.value;

      await homeController.addTask(task);
      showSuccessToast('taskAddedSuccessfully'.tr);
      return true;
    }
  }
}
