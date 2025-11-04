import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/controllers/todo_dialog_ctr.dart';
import 'package:TodoCat/keys/dialog_keys.dart';
import 'package:TodoCat/services/dialog_service.dart';
import 'package:TodoCat/widgets/animation_btn.dart';
import 'package:TodoCat/widgets/todo_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:TodoCat/controllers/home_ctr.dart';

class AddTodoCardBtn extends StatelessWidget {
  const AddTodoCardBtn({
    super.key,
    required this.task,
  });

  final Task task;

  void _handlePress(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    homeCtrl.selectTask(task);

    final todoDialogController = Get.put(
      AddTodoDialogController(),
      tag: 'add_todo_dialog',
      permanent: true,
    );
    todoDialogController.taskId = task.uuid;

    // 先尝试恢复缓存（只保留输入，不直接创建）
    todoDialogController.restoreCacheIfAny();

    DialogService.showFormDialog(
      tag: addTodoDialogTag,
      dialog: const TodoDialog(dialogTag: 'add_todo_dialog'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: AnimationBtn(
        onHoverAnimationEnabled: false,
        onPressed: () => _handlePress(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.theme.dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.plus,
                  size: 15,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 2),
                Text(
                  "addTodo".tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
