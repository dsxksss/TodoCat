import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/task_dialog_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/add_tag_screen.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/label_btn.dart';

class TaskDialog extends GetView<TaskDialogController> {
  const TaskDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 430,
      height: context.isPhone ? 0.6.sh : 500,
      decoration: BoxDecoration(
        color: context.theme.dialogBackgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.theme.dividerColor,
            blurRadius: context.isDarkMode ? 1 : 2,
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.theme.dividerColor,
                    width: 0.3,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "addTask".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      LabelBtn(
                        ghostStyle: true,
                        label: Text(
                          "cancel".tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onPressed: () =>
                            SmartDialog.dismiss(tag: addTaskDialogTag),
                      ),
                      const SizedBox(width: 8),
                      LabelBtn(
                        label: Text(
                          "confirm".tr,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onPressed: controller.submitTask,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    TextFormFieldItem(
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      maxLength: 20,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: "taskTitle".tr,
                      editingController: controller.titleController,
                      validator: controller.validateTitle,
                      onFieldSubmitted: (_) {},
                    ),
                    const SizedBox(height: 15),
                    AddTagScreen(
                      textInputAction: TextInputAction.next,
                      maxLength: 6,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: "tag".tr,
                      validator: (_) => null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      editingController: controller.tagController,
                      ghostStyle: true,
                      onSubmitted: (_) => controller.addTag(),
                      selectedTags: controller.selectedTags,
                      onDeleteTag: controller.removeTag,
                    ),
                    const SizedBox(height: 15),
                    TextFormFieldItem(
                      textInputAction: TextInputAction.done,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      maxLength: 400,
                      maxLines: 8,
                      radius: 6,
                      fieldTitle: "taskDescription".tr,
                      validator: (_) => null,
                      editingController: controller.descriptionController,
                      onFieldSubmitted: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
