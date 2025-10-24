import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:logger/logger.dart';

/// 通用表单控制器基类
/// 提供表单验证、编辑状态管理、数据缓存等通用功能
abstract class BaseFormController extends GetxController {
  @protected
  static final logger = Logger();

  // 表单相关
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // 标签管理
  final tagController = TextEditingController();
  final selectedTags = <TagWithColor>[].obs;
  
  // 数据变更追踪
  final isDirty = false.obs;

  /// 验证表单
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// 标题验证器
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      logger.w('Title validation failed: empty title');
      return 'titleRequired'.tr;
    }
    return null;
  }

  /// 添加标签（带颜色）
  void addTagWithColor(Color color) {
    logger.d('Attempting to add tag: ${tagController.text}');
    final tag = tagController.text.trim();

    if (tag.isEmpty) {
      logger.w('Tag is empty');
      showToast('tagEmpty'.tr, toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    if (selectedTags.length >= 3) {
      logger.w('Tags limit reached');
      showToast('tagsUpperLimit'.tr, toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    if (selectedTags.any((t) => t.name == tag)) {
      logger.w('Duplicate tag found');
      showToast('tagDuplicate'.tr, toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    logger.d('Adding new tag: $tag with color: $color');
    selectedTags.add(TagWithColor(name: tag, color: color));
    tagController.clear();
    _markDirty();
  }

  /// 添加标签（兼容旧版本，使用默认颜色）
  void addTag() {
    addTagWithColor(Colors.blueAccent);
  }

  /// 移除标签
  void removeTag(int index) {
    if (index >= 0 && index < selectedTags.length) {
      logger.d('Removing tag at index $index: ${selectedTags[index]}');
      selectedTags.removeAt(index);
      _markDirty();
    } else {
      logger.w('Invalid tag index for removal: $index');
    }
  }

  /// 清理表单
  void clearForm() {
    logger.d('Clearing form data');
    titleController.clear();
    descriptionController.clear();
    tagController.clear();
    selectedTags.clear();
    isDirty.value = false;
  }

  /// 标记为已修改
  void _markDirty() {
    isDirty.value = true;
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

  @override
  void onInit() {
    super.onInit();
    logger.i('Initializing ${runtimeType}');
    
    // 监听表单变化
    titleController.addListener(_markDirty);
    descriptionController.addListener(_markDirty);
    
    // 监听标签变化
    ever(selectedTags, (_) => _markDirty());
  }

  @override
  void onClose() {
    logger.d('Cleaning up ${runtimeType} resources');
    titleController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    super.onClose();
  }
}