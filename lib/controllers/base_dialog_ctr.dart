import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:logger/logger.dart';

abstract class BaseDialogController extends GetxController {
  @protected
  static final logger = Logger();

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final tagController = TextEditingController();
  final selectedTags = <String>[].obs;
  final selectedDate = Rx<DateTime?>(null);
  final isEditing = false.obs;

  void addTag() {
    logger.d('Attempting to add tag: ${tagController.text}');
    final tag = tagController.text.trim();

    if (tag.isEmpty) {
      logger.w('Tag is empty');
      showToast('tagEmpty'.tr, toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    if (selectedTags.length >= 3) {
      logger.w('Tags limit reached');
      showToast('tagsUpperLimit'.tr,
          toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    if (selectedTags.contains(tag)) {
      logger.w('Duplicate tag found');
      showToast('tagDuplicate'.tr,
          toastStyleType: TodoCatToastStyleType.warning);
      return;
    }

    logger.d('Adding new tag: $tag');
    selectedTags.add(tag);
    tagController.clear();
  }

  void removeTag(int index) {
    if (index >= 0 && index < selectedTags.length) {
      logger.d('Removing tag at index $index: ${selectedTags[index]}');
      selectedTags.removeAt(index);
    } else {
      logger.w('Invalid tag index for removal: $index');
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      logger.w('Title validation failed: empty title');
      return 'titleRequired'.tr;
    }
    return null;
  }

  void clearForm() {
    logger.d('Clearing form data');
    titleController.clear();
    descriptionController.clear();
    tagController.clear();
    selectedTags.clear();
    selectedDate.value = null;
  }

  @override
  void onInit() {
    super.onInit();
    logger.i('Initializing BaseDialogController');
  }

  @override
  void onClose() {
    logger.d('Cleaning up BaseDialogController resources');
    isEditing.value = false;
    titleController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    super.onClose();
  }
}
