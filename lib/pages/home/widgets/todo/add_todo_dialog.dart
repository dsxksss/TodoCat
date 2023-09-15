import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/add_tag_screen.dart';
import 'package:todo_cat/pages/home/widgets/date_picker_btn.dart';
import 'package:todo_cat/pages/home/widgets/select_priority_panel.dart';
import 'package:todo_cat/pages/home/widgets/text_form_field_item.dart';
import 'package:uuid/uuid.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({
    super.key,
  });

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final HomeController homeCtrl = Get.find();
  late final AddTodoDialogController dialogCtrl;

  @override
  void initState() {
    dialogCtrl = Get.find();
    super.initState();
  }

  @override
  void dispose() {
    dialogCtrl.onDialogClose();
    homeCtrl.deselectTask();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 1000,
          height: 610,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: context.theme.dialogBackgroundColor,
            border: Border.all(width: 0.18, color: context.theme.dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Form(
            key: dialogCtrl.formKey,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "addTodo".tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      // 取消按钮按下时出现的颜色
                      style: const ButtonStyle(
                          overlayColor:
                              MaterialStatePropertyAll(Colors.transparent)),
                      onPressed: () {
                        if (dialogCtrl.formKey.currentState!.validate()) {
                          final todo = Todo(
                            id: const Uuid().v4(),
                            title: dialogCtrl.titleFormCtrl.text.trim(),
                            description:
                                dialogCtrl.descriptionFormCtrl.text.trim(),
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            tags: dialogCtrl.selectedTags.toList(),
                            priority: dialogCtrl.selectedPriority.value,
                            reminders: DateTime.now()
                                .add(const Duration(seconds: 10))
                                .millisecondsSinceEpoch,
                          );

                          homeCtrl.addTodo(todo);

                          Get.back();
                        }
                      },
                      child: Text("done".tr),
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 500,
                      child: TextFormFieldItem(
                        maxLength: 40,
                        fieldTitle: "title".tr,
                        editingController: dialogCtrl.titleFormCtrl,
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: SelectPriorityPanel(
                        titile: "${'task'.tr}${'priority'.tr}",
                        onTap: (index) => dialogCtrl.selectedPriority.value =
                            TodoPriority.values[index],
                        tabs: [
                          Tab(
                            text: "lowLevel".tr,
                          ),
                          Tab(
                            text: "mediumLevel".tr,
                          ),
                          Tab(
                            text: "highLevel".tr,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                TextFormFieldItem(
                  maxLength: 400,
                  maxLines: 5,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  fieldTitle: "description".tr,
                  validator: (_) => null,
                  editingController: dialogCtrl.descriptionFormCtrl,
                ),
                AddTagScreen(),
                DatePickerBtn(
                  text: dialogCtrl.remindersText,
                  value: dialogCtrl.remindersValue,
                  fieldTitle: 'reminderTime'.tr,
                ),
              ].animate(interval: 100.ms).moveX(begin: 20).fade(),
            ),
          ),
        ),
      ),
    );
  }
}
