import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/todo_dialog_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/add_tag_screen.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/date_picker_panel.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/tag_dialog_btn.dart';
import 'package:todo_cat/widgets/priority_picker_panel.dart';
import 'package:todo_cat/widgets/reminder_picker_panel.dart';
import 'package:todo_cat/widgets/status_picker_panel.dart';
import 'package:intl/intl.dart';
import 'package:todo_cat/data/schemas/todo.dart';

class TodoDialog extends GetView<AddTodoDialogController> {
  const TodoDialog({
    super.key,
    required this.dialogTag,
  });

  final String dialogTag;

  @override
  String? get tag => dialogTag;

  @override
  AddTodoDialogController get controller =>
      Get.find<AddTodoDialogController>(tag: dialogTag);

  void _handleSubmit() async {
    // 先获取编辑状态和标题，再提交表单
    final isEditing = controller.isEditing.value;
    final todoTitle = controller.titleController.text;
    
    if (await controller.submitForm()) {
      SmartDialog.dismiss(tag: addTodoDialogTag);
      
      // 根据之前获取的编辑状态显示不同的提示
      final actionText = isEditing ? "updatedSuccessfully".tr : "addedSuccessfully".tr;
      
      // 使用左下角通知显示成功信息
      showSuccessNotification(
        "${"todo".tr} '$todoTitle' $actionText",
      );
      
      // 清理表单状态（在显示提示后）
      controller.clearForm();
    }
  }

  void _handleClose() {
    if (controller.hasUnsavedChanges()) {
      showToast(
        "${"saveEditing".tr}?",
        tag: confirmDialogTag,
        alwaysShow: true,
        confirmMode: true,
        onYesCallback: () {
          controller.submitForm();
          SmartDialog.dismiss(tag: addTodoDialogTag);
        },
        onNoCallback: () {
          controller.revertChanges();
          SmartDialog.dismiss(tag: addTodoDialogTag);
        },
      );
    } else {
      SmartDialog.dismiss(tag: addTodoDialogTag);
    }
  }

  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return "lowPriority".tr;
      case TodoPriority.mediumLevel:
        return "mediumPriority".tr;
      case TodoPriority.highLevel:
        return "highPriority".tr;
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return Colors.green;
      case TodoPriority.mediumLevel:
        return Colors.orange;
      case TodoPriority.highLevel:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return Icons.flag_outlined;
      case TodoPriority.mediumLevel:
        return Icons.flag_outlined;
      case TodoPriority.highLevel:
        return Icons.flag;
    }
  }

  String _getReminderLabel(int reminderMinutes) {
    if (reminderMinutes == 0) {
      return "noReminder".tr;
    } else if (reminderMinutes < 60) {
      return "${reminderMinutes}${'minutesAgo'.tr}";
    } else if (reminderMinutes < 1440) {
      return "${(reminderMinutes / 60).round()}${'hoursAgo'.tr}";
    } else {
      return "${(reminderMinutes / 1440).round()}${'daysAgo'.tr}";
    }
  }

  String _getStatusLabel(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return "statusTodo".tr;
      case TodoStatus.inProgress:
        return "statusInProgress".tr;
      case TodoStatus.done:
        return "statusDone".tr;
    }
  }

  Color _getStatusColor(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Colors.grey[600]!;
      case TodoStatus.inProgress:
        return Colors.orange;
      case TodoStatus.done:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Icons.radio_button_unchecked;
      case TodoStatus.inProgress:
        return Icons.access_time;
      case TodoStatus.done:
        return Icons.check_circle;
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  Obx(() => Text(
                    controller.isEditing.value ? "editTodo".tr : "addTodo".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  Row(
                    children: [
                      LabelBtn(
                        ghostStyle: true,
                        label: Text(
                          "cancel".tr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onPressed: _handleClose,
                      ),
                      const SizedBox(width: 8),
                      LabelBtn(
                        label: Text(
                          "confirm".tr,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onPressed: _handleSubmit,
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
                          // 日期选择器按钮
                          Obx(() => TagDialogBtn(
                                tag: controller.selectedDate.value != null
                                    ? DateFormat('MM-dd HH:mm')
                                        .format(controller.selectedDate.value!)
                                    : "setDueDate".tr,
                                tagColor: controller.selectedDate.value != null
                                    ? const Color(0xFF3B82F6)
                                    : Colors.grey[700]!,
                                dialogTag: 'todo_date',
                                showDelete: false,
                                openDialog: DatePickerPanel(
                                  dialogTag: addTodoTagDialogBtnTag,
                                  initialSelectedDate: controller.selectedDate.value, // 传递当前选中的日期
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
                                          : "setDueDate".tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.event_available_outlined,
                                        size: 20),
                                  ],
                                ),
                              )),
                          const SizedBox(width: 10),
                          Obx(() => TagDialogBtn(
                                tag: _getPriorityLabel(controller.selectedPriority.value),
                                tagColor: _getPriorityColor(controller.selectedPriority.value),
                                dialogTag: 'todo_priority',
                                showDelete: false,
                                openDialog: PriorityPickerPanel(
                                  initialPriority: controller.selectedPriority.value,
                                  onPrioritySelected: (priority) {
                                    controller.selectedPriority.value = priority;
                                  },
                                ),
                                titleWidget: Row(
                                  children: [
                                    Text(
                                      _getPriorityLabel(controller.selectedPriority.value),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      _getPriorityIcon(controller.selectedPriority.value),
                                      size: 20,
                                      color: _getPriorityColor(controller.selectedPriority.value),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(width: 10),
                          Obx(() => TagDialogBtn(
                                tag: _getReminderLabel(controller.remindersValue.value),
                                tagColor: controller.remindersValue.value > 0 
                                    ? const Color(0xFF3B82F6) 
                                    : Colors.grey[700]!,
                                dialogTag: 'todo_reminder',
                                showDelete: false,
                                openDialog: ReminderPickerPanel(
                                  initialReminder: controller.remindersValue.value,
                                  onReminderSelected: (reminder) {
                                    controller.remindersValue.value = reminder;
                                  },
                                ),
                                titleWidget: Row(
                                  children: [
                                    Text(
                                      _getReminderLabel(controller.remindersValue.value),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      controller.remindersValue.value > 0 
                                          ? Icons.alarm 
                                          : Icons.alarm_off,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(width: 10),
                          Obx(() => TagDialogBtn(
                                tag: _getStatusLabel(controller.selectedStatus.value),
                                tagColor: _getStatusColor(controller.selectedStatus.value),
                                dialogTag: 'todo_status',
                                showDelete: false,
                                openDialog: StatusPickerPanel(
                                  initialStatus: controller.selectedStatus.value,
                                  onStatusSelected: (status) {
                                    controller.selectedStatus.value = status;
                                  },
                                ),
                                titleWidget: Row(
                                  children: [
                                    Text(
                                      _getStatusLabel(controller.selectedStatus.value),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      _getStatusIcon(controller.selectedStatus.value),
                                      size: 20,
                                      color: _getStatusColor(controller.selectedStatus.value),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    10.verticalSpace,
                    TextFormFieldItem(
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      focusNode: FocusNode(),
                      maxLength: 20,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: "title".tr,
                      validator: controller.validateTitle,
                      editingController: controller.titleController,
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
                      onSubmitted: (value) => controller.addTag(),
                      selectedTags: controller.selectedTags,
                      onDeleteTag: controller.removeTag,
                    ),
                    const SizedBox(height: 5),
                    TextFormFieldItem(
                      textInputAction: TextInputAction.done,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10,
                      ),
                      maxLength: 400,
                      maxLines: 8,
                      radius: 6,
                      fieldTitle: "description".tr,
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
