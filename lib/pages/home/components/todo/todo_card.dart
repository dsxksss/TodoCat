import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/pages/home/components/tag.dart';
import 'package:todo_cat/core/utils/date_time.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/controllers/todo_dialog_ctr.dart';
import 'package:todo_cat/widgets/todo_dialog.dart';
import 'package:todo_cat/services/dialog_service.dart';

class TodoCard extends StatelessWidget {
  TodoCard({
    super.key,
    required this.taskId,
    required this.todo,
  });

  final String taskId;
  final Todo todo;
  final HomeController _homeCtrl = Get.find();

  IconData _getStatusIconData() {
    switch (todo.status) {
      case TodoStatus.todo:
        return FontAwesomeIcons.hourglassStart;
      case TodoStatus.inProgress:
        return FontAwesomeIcons.hourglassEnd;
      case TodoStatus.done:
        return FontAwesomeIcons.checkDouble;
    }
  }

  Color _getPriorityColor() {
    switch (todo.priority) {
      case TodoPriority.lowLevel:
        return const Color.fromRGBO(46, 204, 147, 1);
      case TodoPriority.mediumLevel:
        return const Color.fromARGB(255, 251, 136, 94);
      case TodoPriority.highLevel:
        return const Color.fromARGB(255, 251, 98, 98);
    }
  }

  Future<void> _handleDelete() async {
    await _homeCtrl.deleteTodo(taskId, todo.uuid);
  }

  @override
  Widget build(BuildContext context) {
    final todoContent = buildTodoContent(context);

    return Draggable<Map<String, dynamic>>(
      data: {
        'todoId': todo.uuid,
        'fromTaskId': taskId,
        'todo': todo,
      },
      maxSimultaneousDrags: 1,
      onDragStarted: () {
        if (context.findRenderObject() != null) {
          final box = context.findRenderObject() as RenderBox;
          final position = box.localToGlobal(Offset.zero);
          if (position.dx.abs() > position.dy.abs()) {
            _homeCtrl.startDragging();
          }
        }
      },
      onDragEnd: (details) {
        _homeCtrl.endDragging();
      },
      onDraggableCanceled: (velocity, offset) {
        _homeCtrl.endDragging();
      },
      feedback: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style,
        child: todoContent,
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: todoContent,
      ),
      child: todoContent,
    );
  }

  Widget buildTodoContent(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          border: Border.all(color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: context.theme.shadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.solidCircle,
                        size: 11,
                        color: _getPriorityColor(),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 120,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 1.0),
                          child: Text(
                            todo.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  DPDMenuBtn(
                    tag: dropDownMenuBtnTag,
                    menuItems: [
                      MenuItem(
                        title: 'edit',
                        iconData: FontAwesomeIcons.penToSquare,
                        callback: () async {
                          final todoDialogController = Get.put(
                            AddTodoDialogController(),
                            tag: 'edit_todo_dialog',
                            permanent: true,
                          );
                          todoDialogController.initForEditing(taskId, todo);

                          DialogService.showFormDialog(
                            tag: addTodoDialogTag,
                            dialog:
                                const TodoDialog(dialogTag: 'edit_todo_dialog'),
                          );
                        },
                      ),
                      MenuItem(
                        title: 'delete',
                        iconData: FontAwesomeIcons.trashCan,
                        callback: () => {
                          showToast(
                            "sureDeleteTodo".tr,
                            alwaysShow: true,
                            confirmMode: true,
                            toastStyleType: TodoCatToastStyleType.error,
                            onYesCallback: () {
                              _handleDelete();
                            },
                          )
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (todo.tags.isNotEmpty)
                const SizedBox(
                  height: 10,
                ),
              if (todo.tags.isNotEmpty)
                SizedBox(
                  height: 20,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...todo.tags
                          .sublist(0, todo.tags.length > 3 ? 3 : null)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Tag(tag: e, color: Colors.blueAccent),
                            ),
                          ),
                    ],
                  ),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        size: 15,
                        FontAwesomeIcons.calendarCheck,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        timestampToDate(todo.finishedAt),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'status'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        _getStatusIconData(),
                        size: 15,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
        ),
      ),
    );
  }
}
