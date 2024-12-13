import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/controllers/add_todo_dialog_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:uuid/uuid.dart';

class TaskDialogController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final tagController = TextEditingController();
  final selectedTags = <String>[].obs;
  final homeController = Get.find<HomeController>();
  final tagService = TagService();
  final selectedDate = Rx<DateTime?>(null);

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'titleRequired'.tr;
    }
    return null;
  }

  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isEmpty) {
      showToast('tagEmpty'.tr, toastStyleType: TodoCatToastStyleType.warning);
      return;
    }
    if (selectedTags.length >= 3) {
      showToast('tagsUpperLimit'.tr,
          toastStyleType: TodoCatToastStyleType.warning);
      return;
    }
    if (selectedTags.contains(tag)) {
      showToast('tagDuplicate'.tr,
          toastStyleType: TodoCatToastStyleType.warning);
      return;
    }
    selectedTags.add(tag);
    tagController.clear();
  }

  void removeTag(int index) {
    if (index >= 0 && index < selectedTags.length) {
      selectedTags.removeAt(index);
    }
  }

  void submitTask() async {
    if (!formKey.currentState!.validate()) return;

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

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    super.onClose();
  }
}
