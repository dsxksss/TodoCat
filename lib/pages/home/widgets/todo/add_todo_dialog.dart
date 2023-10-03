import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/add_tag_screen.dart';
import 'package:todo_cat/pages/home/widgets/date_picker_btn.dart';
import 'package:todo_cat/pages/home/widgets/select_priority_panel.dart';
import 'package:todo_cat/pages/home/widgets/text_form_field_item.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/widgets/tag_dialog_btn.dart';
import 'package:uuid/uuid.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({
    super.key,
  });

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final HomeController _homeCtrl = Get.find();
  late final AddTodoDialogController _dialogCtrl;

  @override
  void initState() {
    _dialogCtrl = Get.find();
    // 由于和其他组件生命周期不同，需要手动切换本地化
    _dialogCtrl.remindersText.value = "${"enter".tr}${"time".tr}";
    super.initState();
  }

  @override
  void dispose() {
    _dialogCtrl.onDialogClose();
    _homeCtrl.deselectTask();
    super.dispose();
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
            blurRadius: context.isDarkMode ? 1 : 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          Form(
            key: _dialogCtrl.formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "addTodo".tr,
                        textAlign: context.isPhone ? null : TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (context.isPhone)
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
                          onPressed: () {
                            if (_dialogCtrl.formKey.currentState!.validate()) {
                              final todo = Todo(
                                id: const Uuid().v4(),
                                title: _dialogCtrl.titleFormCtrl.text.trim(),
                                description:
                                    _dialogCtrl.descriptionFormCtrl.text.trim(),
                                createdAt:
                                    DateTime.now().millisecondsSinceEpoch,
                                tags: _dialogCtrl.selectedTags.toList(),
                                priority: _dialogCtrl.selectedPriority.value,
                                reminders: _dialogCtrl.remindersValue.value,
                              );

                              _homeCtrl.addTodo(todo);

                              SmartDialog.dismiss(tag: "AddTodoDialog");
                            }
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 20),
                    physics: const AlwaysScrollableScrollPhysics(
                      //当内容不足时也可以启动反弹刷新
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      Flex(
                        direction:
                            context.isPhone ? Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: context.isPhone
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: context.isPhone
                            ? CrossAxisAlignment.stretch
                            : CrossAxisAlignment.center,
                        children: [
                          TagDialogBtn(
                            title: Text(
                              "dueDate".tr,
                              style: const TextStyle(fontSize: 16),
                            ),
                            icon: const Icon(Icons.event_available_outlined,
                                size: 20),
                            margin: context.isPhone
                                ? const EdgeInsets.symmetric(vertical: 5)
                                : null,
                          ),
                          TagDialogBtn(
                            title: Text(
                              "priority".tr,
                              style: const TextStyle(fontSize: 16),
                            ),
                            icon: const Icon(Icons.flag_outlined, size: 20),
                            margin: context.isPhone
                                ? const EdgeInsets.symmetric(vertical: 5)
                                : null,
                          ),
                          TagDialogBtn(
                            title: Text(
                              "reminderTime".tr,
                              style: const TextStyle(fontSize: 16),
                            ),
                            icon: const Icon(Icons.alarm, size: 20),
                            margin: context.isPhone
                                ? const EdgeInsets.symmetric(vertical: 5)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormFieldItem(
                        maxLength: 20,
                        maxLines: 1,
                        radius: 6,
                        fieldTitle: "title".tr,
                        editingController: _dialogCtrl.titleFormCtrl,
                      ),
                      TextFormFieldItem(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        maxLength: 400,
                        maxLines: 8,
                        radius: 6,
                        fieldTitle: "description".tr,
                        validator: (_) => null,
                        editingController: _dialogCtrl.descriptionFormCtrl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!context.isPhone)
            Positioned(
              right: 20,
              bottom: 20,
              child: Row(
                children: [
                  LabelBtn(
                    onHoverAnimationEnabled: false,
                    onHoverBgColorChangeEnabled: true,
                    label: Text(
                      "cancel".tr,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    ghostStyle: true,
                    onPressed: () => SmartDialog.dismiss(tag: "AddTodoDialog"),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    onPressed: () {
                      if (_dialogCtrl.formKey.currentState!.validate()) {
                        final todo = Todo(
                          id: const Uuid().v4(),
                          title: _dialogCtrl.titleFormCtrl.text.trim(),
                          description:
                              _dialogCtrl.descriptionFormCtrl.text.trim(),
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                          tags: _dialogCtrl.selectedTags.toList(),
                          priority: _dialogCtrl.selectedPriority.value,
                          reminders: _dialogCtrl.remindersValue.value,
                        );

                        _homeCtrl.addTodo(todo);

                        SmartDialog.dismiss(tag: "AddTodoDialog");
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
