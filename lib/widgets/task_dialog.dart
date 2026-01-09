import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/task_dialog_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/config/task_icons.dart';
import 'package:todo_cat/pages/home/components/add_tag_with_color_screen.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:todo_cat/widgets/show_toast.dart';

class TaskDialog extends GetView<TaskDialogController> {
  const TaskDialog({
    super.key,
    required this.dialogTag,
  });

  final String dialogTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 430,
      height: context.isPhone ? 0.6.sh : 500,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : BorderRadius.circular(10),
        // 移除阴影效果，避免亮主题下的亮光高亮
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: context.theme.dividerColor,
        //     blurRadius: context.isDarkMode ? 1 : 2,
        //   ),
        // ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Obx(() => DialogHeader(
                  title:
                      controller.isEditing.value ? "editTask".tr : "addTask".tr,
                  onCancel: _handleClose,
                  onConfirm: _handleSubmit,
                )),
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
                      maxLength: 200,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: "taskTitle".tr,
                      editingController: controller.titleController,
                      validator: controller.validateTitle,
                      onFieldSubmitted: (_) {},
                    ),
                    const SizedBox(height: 15),
                    AddTagWithColorPicker(
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: "tag".tr,
                      validator: (_) => null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      editingController: controller.tagController,
                      selectedTags: controller.selectedTags,
                      onDeleteTag: controller.removeTag,
                      onAddTagWithColor: controller.addTagWithColor,
                    ),
                    const SizedBox(height: 15),

                    // Task Color Picker
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "taskColor".tr,
                        // Fallback title if 'taskColor' key doesn't exist yet,
                        // effectively assuming the user accepts 'taskColor' key or I should use hardcoded text.
                        // Since I can't easily add keys, I'll use a hardcoded text or try to find a similar key.
                        // "Color" might exist. Let's assume "color".tr or use "Side Bar Color".
                        // Better: just "Color" or "Theme".
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final selectedColor =
                          controller.selectedCustomColor.value;
                      final colors = [
                        Colors.grey,
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.cyan,
                        Colors.blue,
                        Colors.purple,
                        Colors.pink,
                      ];

                      return Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          // Default (Clear) option
                          GestureDetector(
                            onTap: () =>
                                controller.selectedCustomColor.value = null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(
                                  color: selectedColor == null
                                      ? context.theme.primaryColor
                                      : context.theme.dividerColor,
                                  width: selectedColor == null ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.format_color_reset,
                                  size: 18,
                                  color: context.theme.iconTheme.color,
                                ),
                              ),
                            ),
                          ),
                          ...colors.map((color) {
                            final isSelected = selectedColor == color.value;
                            return GestureDetector(
                              onTap: () => controller
                                  .selectedCustomColor.value = color.value,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: isSelected
                                      ? Border.all(
                                          color: context.theme.colorScheme
                                              .primary, // Ring color
                                          width: 2,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }),
                    const SizedBox(height: 15),

                    // Task Icon Picker
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "taskIcon".tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final selectedIconCode =
                          controller.selectedCustomIcon.value;
                      final icons = TaskIcons.icons;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          // Default (Clear) option
                          GestureDetector(
                            onTap: () =>
                                controller.selectedCustomIcon.value = null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(
                                  color: selectedIconCode == null
                                      ? context.theme.primaryColor
                                      : context.theme.dividerColor,
                                  width: selectedIconCode == null ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.do_not_disturb_alt,
                                  size: 16,
                                  color: context.theme.iconTheme.color,
                                ),
                              ),
                            ),
                          ),
                          ...icons.map((icon) {
                            final isSelected =
                                selectedIconCode == icon.codePoint;
                            return GestureDetector(
                              onTap: () => controller.selectedCustomIcon.value =
                                  icon.codePoint,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? context.theme.primaryColor
                                      : Colors.transparent,
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: context.theme.dividerColor
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                ),
                                child: Center(
                                  child: FaIcon(
                                    icon,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : context.theme.iconTheme.color
                                            ?.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }),
                    const SizedBox(height: 10),
                    TextFormFieldItem(
                      textInputAction: TextInputAction.done,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 5,
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

  void _handleClose() {
    if (controller.hasUnsavedChanges()) {
      showToast(
        "${"saveEditing".tr}?",
        tag: confirmDialogTag,
        alwaysShow: true,
        confirmMode: true,
        onYesCallback: () async {
          if (await controller.submitTask()) {
            SmartDialog.dismiss(tag: dialogTag);
          }
        },
        onNoCallback: () {
          controller.revertChanges();
          SmartDialog.dismiss(tag: dialogTag);
        },
      );
    } else {
      SmartDialog.dismiss(tag: dialogTag);
    }
  }

  void _handleSubmit() async {
    if (await controller.submitTask()) {
      SmartDialog.dismiss(tag: dialogTag);
    }
  }
}
