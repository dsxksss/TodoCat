import 'package:flutter/material.dart';
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
            key: _dialogCtrl.formKey,
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
                        editingController: _dialogCtrl.titleFormCtrl,
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: SelectPriorityPanel(
                        titile: "${'task'.tr}${'priority'.tr}",
                        onTap: (index) => _dialogCtrl.selectedPriority.value =
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                  fieldTitle: "description".tr,
                  validator: (_) => null,
                  editingController: _dialogCtrl.descriptionFormCtrl,
                ),
                AddTagScreen(),
                DatePickerBtn(
                  text: _dialogCtrl.remindersText,
                  value: _dialogCtrl.remindersValue,
                  fieldTitle: 'reminderTime'.tr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
