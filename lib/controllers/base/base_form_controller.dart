import 'package:flutter/material.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:logger/logger.dart';

import 'package:todo_cat/core/utils/l10n.dart';

/// 通用表单 Mixin（Riverpod 版，替代原 `abstract class BaseFormController`）。
///
/// 作用于表单类 [Notifier]，提供：
/// - `formKey` / `titleController` / `descriptionController` / `tagController`
///   作为实例字段（用 [disposeFormControllers] 在 `ref.onDispose` 里释放）；
/// - 表单验证、标签增删、toast 等通用方法。
///
/// `selectedTags` / `isDirty` 不再属于本 mixin —— 它们存放在每个表单的 state 对象中，
/// 因此 mixin 通过抽象的 [selectedTags] getter 与 [updateSelectedTags] / [markDirty]
/// 钩子与具体表单 Notifier 协作。
mixin FormControllerMixin {
  static final logger = Logger();

  // 表单相关
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // 标签管理
  final tagController = TextEditingController();

  /// 当前已选标签（由具体表单从 state 暴露）。
  List<TagWithColor> get selectedTags;

  /// 用新的标签列表更新 state（由具体表单实现）。
  void updateSelectedTags(List<TagWithColor> tags);

  /// 标记表单为已修改（由具体表单实现，写入 state.isDirty）。
  void markDirty();

  /// 验证表单
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// 标题验证器
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      logger.w('Title validation failed: empty title');
      return l10n.titleRequired;
    }
    return null;
  }

  /// 添加标签（带颜色）
  void addTagWithColor(Color color) {
    logger.d('Attempting to add tag: ${tagController.text}');
    final tag = tagController.text.trim();

    if (tag.isEmpty) {
      logger.w('Tag is empty');
      showToast(l10n.tagEmpty, toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    if (selectedTags.length >= 3) {
      logger.w('Tags limit reached');
      showToast(l10n.tagsUpperLimit,
          toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    if (selectedTags.any((t) => t.name == tag)) {
      logger.w('Duplicate tag found');
      showToast(l10n.tagDuplicate,
          toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    logger.d('Adding new tag: $tag with color: $color');
    updateSelectedTags([
      ...selectedTags,
      TagWithColor(name: tag, color: color),
    ]);
    tagController.clear();
    markDirty();
  }

  /// 添加标签（兼容旧版本，使用默认颜色）
  void addTag() {
    addTagWithColor(Colors.blueAccent);
  }

  /// 移除标签
  void removeTag(int index) {
    if (index >= 0 && index < selectedTags.length) {
      logger.d('Removing tag at index $index: ${selectedTags[index]}');
      final newTags = List<TagWithColor>.from(selectedTags)..removeAt(index);
      updateSelectedTags(newTags);
      markDirty();
    } else {
      logger.w('Invalid tag index for removal: $index');
    }
  }

  /// 清理表单文本控制器（标签列表由具体表单 clearForm 重置 state）。
  void clearFormControllers() {
    logger.d('Clearing form data');
    titleController.clear();
    descriptionController.clear();
    tagController.clear();
  }

  /// 检查数据是否为空
  bool isDataEmpty() {
    return titleController.text.isEmpty &&
        descriptionController.text.isEmpty &&
        selectedTags.isEmpty;
  }

  /// 显示成功提示
  void showSuccessToast(String message) {
    showSuccessNotification(message);
  }

  /// 显示错误提示
  void showErrorToast(String message) {
    showToast(message, toastStyleType: TodoCatToastStyleType.error);
  }

  /// 显示警告提示
  void showWarningToast(String message) {
    showToast(message, toastStyleType: TodoCatToastStyleType.warning);
  }

  /// 释放文本控制器（在 Notifier 的 `ref.onDispose` 中调用）。
  void disposeFormControllers() {
    logger.d('Cleaning up form controllers');
    titleController.dispose();
    descriptionController.dispose();
    tagController.dispose();
  }
}
