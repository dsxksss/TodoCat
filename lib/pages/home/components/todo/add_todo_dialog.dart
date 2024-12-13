import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/add_todo_dialog_ctr.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/add_tag_screen.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/date_picker_panel.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/tag_dialog_btn.dart';
import 'package:uuid/uuid.dart';

class AddTodoDialog extends GetView<AddTodoDialogController> {
  AddTodoDialog({super.key});

  final HomeController _homeCtrl = Get.find();

  void _handleSubmit() async {
    if (controller.formKey.currentState!.validate()) {
      final todo = Todo()
        ..uuid = const Uuid().v4()
        ..title = controller.titleFormCtrl.text
        ..description = controller.descriptionFormCtrl.text
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tags = controller.selectedTags.toList()
        ..priority = controller.selectedPriority.value
        ..status = TodoStatus.todo
        ..finishedAt = 0
        ..reminders = controller.remindersValue.value;

      final bool isSuccess = await _homeCtrl.addTodo(todo);

      if (isSuccess) {
        SmartDialog.dismiss(tag: addTodoDialogTag);
        showToast(
          "${"todo".tr} '${todo.title}' ${"addedSuccessfully".tr}",
          toastStyleType: TodoCatToastStyleType.success,
        );
        controller.clearForm();
      } else {
        showToast(
          "${"todo".tr} '${todo.title}' ${"additionFailed".tr}",
          toastStyleType: TodoCatToastStyleType.error,
        );
      }
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
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: context.isPhone ? 20 : 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "addTodo".tr,
                    textAlign: context.isPhone ? null : TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      LabelBtn(
                        ghostStyle: true,
                        label: Text(
                          "cancel".tr,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 2),
                        onPressed: () {
                          if (controller.isDataNotEmpty()) {
                            showToast("${"saveEditing".tr}?",
                                tag: confirmDialogTag,
                                displayTime: 5000.ms,
                                confirmMode: true, onYesCallback: () {
                              SmartDialog.dismiss(tag: addTodoDialogTag);
                            }, onNoCallback: () {
                              SmartDialog.dismiss(tag: addTodoDialogTag);
                              0.5.delay(() => controller.clearForm());
                            });
                          } else {
                            SmartDialog.dismiss(tag: addTodoDialogTag);
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                      LabelBtn(
                        label: Text(
                          "create".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 2),
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(
                  parent: BouncingScrollPhysics(),
                  decelerationRate: ScrollDecelerationRate.fast,
                ),
                children: [
                  SizedBox(
                    height: 35,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(
                        //当内容不足时也可以启动反弹刷新
                        parent: BouncingScrollPhysics(),
                      ),
                      children: [
                        TagDialogBtn(
                          tag: addTodoTagDialogBtnTag,
                          title: "dueDate".tr,
                          titleStyle: const TextStyle(fontSize: 15),
                          icon: const Icon(Icons.event_available_outlined,
                              size: 20),
                          openDialog: DatePickerPanel(
                            dialogTag: addTodoTagDialogBtnTag,
                          ),
                        ),
                        const SizedBox(width: 10),
                        TagDialogBtn(
                          tag: addTodoTagDialogBtnTag,
                          title: "priority".tr,
                          titleStyle: const TextStyle(fontSize: 15),
                          icon: const Icon(Icons.flag_outlined, size: 20),
                        ),
                        const SizedBox(width: 10),
                        TagDialogBtn(
                          tag: addTodoTagDialogBtnTag,
                          title: "reminderTime".tr,
                          titleStyle: const TextStyle(fontSize: 15),
                          icon: const Icon(Icons.alarm, size: 20),
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
                                  //当内容不足时也可以启动反弹刷新
                                  parent: BouncingScrollPhysics(),
                                ),
                                children: [
                                  ...controller.selectedTags.map(
                                    (tag) => Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: TagDialogBtn(
                                        tag: addTodoTagDialogBtnTag,
                                        icon: const Icon(Icons.tag, size: 20),
                                        titleWidget: Row(
                                          children: [
                                            Text(
                                              tag,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                            const SizedBox(width: 5),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    controller.removeTag(
                                                        controller.selectedTags
                                                            .indexOf(tag)),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 18,
                                                ),
                                              ),
                                            )
                                          ],
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
                  ),
                  const SizedBox(height: 10),
                  TextFormFieldItem(
                    textInputAction: TextInputAction.done,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    maxLength: 400,
                    maxLines: 8,
                    radius: 6,
                    fieldTitle: "description".tr,
                    validator: (_) => null,
                    editingController: controller.descriptionFormCtrl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
