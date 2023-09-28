import 'package:flutter/material.dart';
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
      width: 430,
      height: 500,
      decoration: BoxDecoration(
        color: context.theme.dialogBackgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.theme.dividerColor,
            blurRadius: context.isDarkMode ? 1 : 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 20),
              Text(
                "addTodo".tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TagDialogBtn(
                    title: Text("priority".tr),
                    icon: Icon(
                      Icons.flag_outlined,
                    ),
                  ),
                  TagDialogBtn(
                    title: Text("reminderTime".tr),
                    icon: Icon(
                      Icons.alarm,
                    ),
                  ),
                  TagDialogBtn(
                    title: Text("priority".tr),
                    icon: Icon(
                      Icons.event_available_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 5,
            bottom: 10,
            child: Row(
              children: [
                LabelBtn(
                  label: Text("cancel".tr),
                  ghostStyle: true,
                  onPressed: () => SmartDialog.dismiss(tag: "AddTodoDialog"),
                ),
                SizedBox(width: 20),
                LabelBtn(label: Text("create".tr)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
