import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_cat/data/schemas/task.dart';import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/todo_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_cat/controllers/home_ctr.dart';

import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/responsive.dart';

class AddTodoCardBtn extends ConsumerWidget {
  const AddTodoCardBtn({
    super.key,
    required this.task,
  });

  final Task task;

  void _handlePress(BuildContext context, WidgetRef ref) {
    ref.read(homeControllerProvider.notifier).selectTask(task);

    final dialogTag = 'add_todo_card_btn_${task.uuid}';
    DialogService.showFormDialog(
      tag: dialogTag,
      dialog: TodoDialog(
        dialogTag: dialogTag,
        // 新增模式：taskId 与草稿恢复由控制器 initForAdding 处理。
        intent: TodoDialogIntent.add(taskId: task.uuid),
      ),
      useFixedSize: false, // TodoDialog 需要动态调整宽度以支持预览窗口
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: AnimationBtn(
        onHoverAnimationEnabled: false,
        onPressed: () => _handlePress(context, ref),
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
                  l10n.addTodo,
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
