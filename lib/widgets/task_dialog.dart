import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_cat/core/utils/responsive.dart';
import 'package:todo_cat/controllers/task_dialog_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/config/task_icons.dart';
import 'package:todo_cat/pages/home/components/add_tag_with_color_screen.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:todo_cat/widgets/show_toast.dart';

import 'package:todo_cat/core/utils/l10n.dart';

/// 新增/编辑任务对话框的意图：决定对话框自初始化为「新增」还是「编辑」。
@immutable
class TaskDialogIntent {
  const TaskDialogIntent.add()
      : task = null,
        isEdit = false;
  const TaskDialogIntent.edit({required this.task}) : isEdit = true;

  final Task? task;
  final bool isEdit;
}

class TaskDialog extends ConsumerStatefulWidget {
  const TaskDialog({
    super.key,
    required this.dialogTag,
    required this.intent,
  });

  final String dialogTag;
  final TaskDialogIntent intent;

  @override
  ConsumerState<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<TaskDialog> {
  bool _didInit = false; // 一次性初始化守卫（每次打开新建 State，自动复位）

  @override
  void initState() {
    super.initState();
    // 对话框挂载后(已 ref.watch 订阅同一 tag)再初始化控制器，编辑/新增上下文由
    // widget.intent 携带，避免“先 ref.read 改、再弹窗”的 tag 不一致与 autoDispose 间隙。
    WidgetsBinding.instance.addPostFrameCallback((_) => _initOnce());
  }

  void _initOnce() {
    if (_didInit || !mounted) return;
    _didInit = true;
    final c = ref.read(taskDialogControllerProvider(widget.dialogTag).notifier);
    if (widget.intent.isEdit) {
      c.initForEditing(widget.intent.task!);
    } else {
      c.initForAdding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState =
        ref.watch(taskDialogControllerProvider(widget.dialogTag));
    final controller =
        ref.read(taskDialogControllerProvider(widget.dialogTag).notifier);

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
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            DialogHeader(
              title: formState.isEditing ? l10n.editTask : l10n.addTask,
              onCancel: () => _handleClose(),
              onConfirm: () => _handleSubmit(),
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
                      maxLength: 200,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: l10n.taskTitle,
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
                      fieldTitle: l10n.tag,
                      validator: (_) => null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      editingController: controller.tagController,
                      selectedTags: formState.selectedTags,
                      onDeleteTag: controller.removeTag,
                      onAddTagWithColor: controller.addTagWithColor,
                      onEditTag: controller.editTagAt,
                    ),
                    const SizedBox(height: 15),

                    // Task Color Picker
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.taskColor,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      final selectedColor = formState.selectedCustomColor;
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
                                controller.setSelectedCustomColor(null),
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
                                  .setSelectedCustomColor(color.value),
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
                        l10n.taskIcon,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      final selectedIconCode = formState.selectedCustomIcon;
                      final icons = TaskIcons.icons;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          // Default (Clear) option
                          GestureDetector(
                            onTap: () =>
                                controller.setSelectedCustomIcon(null),
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
                              onTap: () => controller
                                  .setSelectedCustomIcon(icon.codePoint),
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
                      fieldTitle: l10n.taskDescription,
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
    final controller =
        ref.read(taskDialogControllerProvider(widget.dialogTag).notifier);
    if (controller.hasUnsavedChanges()) {
      showToast(
        "${l10n.saveEditing}?",
        tag: confirmDialogTag,
        alwaysShow: true,
        confirmMode: true,
        onYesCallback: () async {
          if (await controller.submitTask()) {
            SmartDialog.dismiss(tag: widget.dialogTag);
          }
        },
        onNoCallback: () {
          controller.revertChanges();
          SmartDialog.dismiss(tag: widget.dialogTag);
        },
      );
    } else {
      SmartDialog.dismiss(tag: widget.dialogTag);
    }
  }

  void _handleSubmit() async {
    final controller =
        ref.read(taskDialogControllerProvider(widget.dialogTag).notifier);
    if (await controller.submitTask()) {
      SmartDialog.dismiss(tag: widget.dialogTag);
    }
  }
}
