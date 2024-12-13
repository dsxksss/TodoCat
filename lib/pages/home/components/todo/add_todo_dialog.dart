import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/add_todo_dialog_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/add_tag_screen.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/date_picker_panel.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/tag_dialog_btn.dart';
import 'package:intl/intl.dart';

class AddTodoDialog extends GetView<AddTodoDialogController> {
  const AddTodoDialog({super.key});

  @override
  AddTodoDialogController get controller =>
      Get.find<AddTodoDialogController>(tag: 'add_todo_dialog');

  void _handleSubmit() async {
    final bool isSuccess = await controller.submitForm();
    if (isSuccess) {
      SmartDialog.dismiss(tag: addTodoDialogTag);
      showToast(
        "${"todo".tr} '${controller.titleFormCtrl.text}' ${"addedSuccessfully".tr}",
        toastStyleType: TodoCatToastStyleType.success,
      );
    } else {
      showToast(
        "${"todo".tr} '${controller.titleFormCtrl.text}' ${"additionFailed".tr}",
        toastStyleType: TodoCatToastStyleType.error,
      );
    }
  }

  void _handleClose() {
    if (controller.isDataNotEmpty()) {
      showToast(
        "${"saveEditing".tr}?",
        tag: confirmDialogTag,
        displayTime: 5000.ms,
        confirmMode: true,
        onYesCallback: () {
          controller.saveCache();
          SmartDialog.dismiss(tag: addTodoDialogTag);
        },
        onNoCallback: () {
          controller.clearForm();
          SmartDialog.dismiss(tag: addTodoDialogTag);
        },
      );
    } else {
      SmartDialog.dismiss(tag: addTodoDialogTag);
    }
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.3,
                    color: context.theme.dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "addTodo".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _handleClose,
                          child: Text(
                            "cancel".tr,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _handleSubmit,
                          child: Text(
                            "create".tr,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 35,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          Obx(() => TagDialogBtn(
                                tag: controller.selectedDate.value != null
                                    ? DateFormat('MM-dd HH:mm')
                                        .format(controller.selectedDate.value!)
                                    : "dueDate".tr,
                                tagColor: Colors.grey[700]!,
                                dialogTag: 'todo_date',
                                showDelete: false,
                                openDialog: DatePickerPanel(
                                  dialogTag: addTodoTagDialogBtnTag,
                                  onDateSelected: (date) {
                                    controller.selectedDate.value = date;
                                  },
                                ),
                                titleWidget: Row(
                                  children: [
                                    Text(
                                      controller.selectedDate.value != null
                                          ? DateFormat('MM-dd HH:mm').format(
                                              controller.selectedDate.value!)
                                          : "dueDate".tr,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.event_available_outlined,
                                        size: 20),
                                  ],
                                ),
                              )),
                          const SizedBox(width: 10),
                          TagDialogBtn(
                            tag: "priority".tr,
                            tagColor: Colors.grey[700]!,
                            dialogTag: 'todo_priority',
                            titleWidget: Row(
                              children: [
                                Text(
                                  "priority".tr,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 5),
                                const Icon(Icons.flag_outlined, size: 20),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          TagDialogBtn(
                            tag: "reminderTime".tr,
                            tagColor: Colors.grey[700]!,
                            dialogTag: 'todo_reminder',
                            titleWidget: Row(
                              children: [
                                Text(
                                  "reminderTime".tr,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 5),
                                const Icon(Icons.alarm, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Column(
                        children: [
                          if (controller.selectedTags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                height: 35,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  children: [
                                    ...controller.selectedTags.map(
                                      (tag) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: TagDialogBtn(
                                          tag: tag,
                                          tagColor: Colors.lightBlue,
                                          dialogTag: 'todo_tag_$tag',
                                          showDelete: true,
                                          onDelete: () => controller.removeTag(
                                              controller.selectedTags
                                                  .indexOf(tag)),
                                          openDialog: Container(
                                              // 这里可以添加标签编辑的对话框内容
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormFieldItem(
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      focusNode: FocusNode(),
                      maxLength: 20,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: "title".tr,
                      editingController: controller.titleFormCtrl,
                      onFieldSubmitted: (_) {},
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    TextFormFieldItem(
                      textInputAction: TextInputAction.done,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      maxLength: 400,
                      maxLines: 8,
                      radius: 6,
                      fieldTitle: "description".tr,
                      validator: (_) => null,
                      editingController: controller.descriptionFormCtrl,
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
