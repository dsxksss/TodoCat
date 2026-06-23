import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_cat/controllers/base/base_form_controller.dart';
import 'package:todo_cat/controllers/mixins/edit_state_mixin.dart';

import 'package:todo_cat/core/utils/l10n.dart';

part 'task_dialog_ctr.g.dart';

/// 新增/编辑 Task 对话框的表单状态。
@immutable
class TaskFormState {
  final List<TagWithColor> selectedTags;
  final bool isDirty;
  final bool isEditing;
  final int? selectedCustomColor;
  final int? selectedCustomIcon;

  const TaskFormState({
    this.selectedTags = const [],
    this.isDirty = false,
    this.isEditing = false,
    this.selectedCustomColor,
    this.selectedCustomIcon,
  });

  TaskFormState copyWith({
    List<TagWithColor>? selectedTags,
    bool? isDirty,
    bool? isEditing,
    int? selectedCustomColor,
    bool clearSelectedCustomColor = false,
    int? selectedCustomIcon,
    bool clearSelectedCustomIcon = false,
  }) {
    return TaskFormState(
      selectedTags: selectedTags ?? this.selectedTags,
      isDirty: isDirty ?? this.isDirty,
      isEditing: isEditing ?? this.isEditing,
      selectedCustomColor: clearSelectedCustomColor
          ? null
          : (selectedCustomColor ?? this.selectedCustomColor),
      selectedCustomIcon: clearSelectedCustomIcon
          ? null
          : (selectedCustomIcon ?? this.selectedCustomIcon),
    );
  }
}

/// 新增/编辑 Task 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
/// 生成 `taskDialogControllerProvider(tag)`。
@riverpod
class TaskDialogController extends _$TaskDialogController
    with FormControllerMixin, EditStateMixin {
  @override
  TaskFormState build(String tag) {
    ref.onDispose(disposeFormControllers);
    return const TaskFormState();
  }

  // ---- FormControllerMixin 钩子 ----
  @override
  List<TagWithColor> get selectedTags => state.selectedTags;

  @override
  void updateSelectedTags(List<TagWithColor> tags) =>
      state = state.copyWith(selectedTags: tags);

  @override
  void markDirty() => state = state.copyWith(isDirty: true);

  void initForEditing(Task task) {
    // 从 HomeController 的任务列表中获取最新的 task 数据
    Task latestTask = task;
    try {
      final foundTask = ref
          .read(homeControllerProvider.notifier)
          .tasks
          .firstWhereOrNull((t) => t.uuid == task.uuid);
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

    final List<TagWithColor> tags;
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (latestTask.tagsWithColor.isNotEmpty) {
      // 创建深拷贝，避免直接修改原始数据
      tags = latestTask.tagsWithColor
          .map((tag) => TagWithColor(name: tag.name, color: tag.color))
          .toList();
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      tags =
          latestTask.tags.map((tag) => TagWithColor.fromString(tag)).toList();
    }

    // 使用编辑状态管理
    final editState = {
      'title': latestTask.title,
      'description':
          latestTask.description.isEmpty ? '' : latestTask.description,
      'tags': List<String>.from(latestTask.tags),
      'tagsWithColor':
          latestTask.tagsWithColor.map((tag) => tag.toJson()).toList(),
      'customColor': latestTask.customColor,
      'customIcon': latestTask.customIcon,
    };

    initEditing(latestTask, editState);

    state = state.copyWith(
      selectedTags: tags,
      isEditing: true,
      selectedCustomColor: latestTask.customColor,
      clearSelectedCustomColor: latestTask.customColor == null,
      selectedCustomIcon: latestTask.customIcon,
      clearSelectedCustomIcon: latestTask.customIcon == null,
    );
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
        state.selectedCustomColor != originalState['customColor'];
    bool iconChanged = state.selectedCustomIcon != originalState['customIcon'];

    // 调试日志
    if (titleChanged) {
      FormControllerMixin.logger.d(
          'Task title changed: ${titleController.text} != ${originalState['title']}');
    }
    if (descriptionChanged) {
      FormControllerMixin.logger.d(
          'Task description changed: ${descriptionController.text} != ${originalState['description']}');
    }
    if (tagsChanged) {
      FormControllerMixin.logger
          .d('Task tags changed: $selectedTags != ${originalState['tags']}');
    }
    if (colorChanged) {
      FormControllerMixin.logger.d(
          'Task color changed: ${state.selectedCustomColor} != ${originalState['customColor']}');
    }
    if (iconChanged) {
      FormControllerMixin.logger.d(
          'Task icon changed: ${state.selectedCustomIcon} != ${originalState['customIcon']}');
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

    final List<TagWithColor> tags;
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (originalState['tagsWithColor'] != null) {
      final tagsWithColorJson = originalState['tagsWithColor'] as List<dynamic>;
      tags = tagsWithColorJson
          .map((tagJson) =>
              TagWithColor.fromJson(tagJson as Map<String, dynamic>))
          .toList();
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      tags = (originalState['tags'] as List<String>)
          .map((tag) => TagWithColor.fromString(tag))
          .toList();
    }

    final customColor = originalState['customColor'] as int?;
    final customIcon = originalState['customIcon'] as int?;
    state = state.copyWith(
      selectedTags: tags,
      selectedCustomColor: customColor,
      clearSelectedCustomColor: customColor == null,
      selectedCustomIcon: customIcon,
      clearSelectedCustomIcon: customIcon == null,
    );
  }

  void clearForm() {
    FormControllerMixin.logger.d('Clearing task form');
    clearFormControllers();
    exitEditing();
    state = const TaskFormState();
  }

  Future<bool> submitTask() async {
    if (!validateForm()) return false;

    final homeCtrl = ref.read(homeControllerProvider.notifier);

    if (state.isEditing && getEditingItem<Task>() != null) {
      final currentTask = getEditingItem<Task>()!;
      final updatedTask = Task()
        ..uuid = currentTask.uuid
        ..workspaceId = currentTask.workspaceId // 保留原有 workspaceId
        ..order = currentTask.order // 保留排序
        ..title = titleController.text
        ..description = descriptionController.text
        ..tagsWithColor = state.selectedTags.toList()
        ..createdAt = currentTask.createdAt
        ..status = currentTask.status // 保留状态
        ..finishedAt = currentTask.finishedAt // 保留完成时间
        ..progress = currentTask.progress // 保留进度
        ..deletedAt = currentTask.deletedAt // 保留删除时间戳
        ..todos = currentTask.todos
        ..customColor = state.selectedCustomColor
        ..customIcon = state.selectedCustomIcon;

      final success = await homeCtrl.updateTask(currentTask.uuid, updatedTask);

      // 只在失败时显示通知，成功时不添加消息到消息中心
      if (!success) {
        showErrorToast(l10n.taskUpdateFailed);
        return false;
      }
      return true;
    } else {
      final task = Task()
        ..uuid = const Uuid().v4()
        ..title = titleController.text
        ..description = descriptionController.text
        ..tagsWithColor = state.selectedTags.toList()
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = []
        ..customColor = state.selectedCustomColor
        ..customIcon = state.selectedCustomIcon;

      await homeCtrl.addTask(task);
      showSuccessToast(l10n.taskAddedSuccessfully);
      return true;
    }
  }

  // ---- state 字段的便捷 setter（供对话框 UI 调用）----
  void setSelectedCustomColor(int? color) => state = state.copyWith(
      selectedCustomColor: color, clearSelectedCustomColor: color == null);
  void setSelectedCustomIcon(int? icon) => state = state.copyWith(
      selectedCustomIcon: icon, clearSelectedCustomIcon: icon == null);

  /// 编辑某个已选标签（替换索引处的标签）。
  void editTagAt(int index, TagWithColor tag) {
    if (index < 0 || index >= selectedTags.length) return;
    final newTags = List<TagWithColor>.from(selectedTags);
    newTags[index] = tag;
    state = state.copyWith(selectedTags: newTags);
  }
}
