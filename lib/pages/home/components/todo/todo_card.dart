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

  bool _isOverdue() {
    if (todo.dueDate <= 0 || todo.status == TodoStatus.done) {
      return false;
    }
    final now = DateTime.now();
    final dueDate = DateTime.fromMillisecondsSinceEpoch(todo.dueDate);
    return now.isAfter(dueDate);
  }

  Color _getStatusColor() {
    if (_isOverdue()) {
      return Colors.red;
    }
    switch (todo.status) {
      case TodoStatus.todo:
        return Colors.orange;
      case TodoStatus.inProgress:
        return Colors.blue;
      case TodoStatus.done:
        return Colors.green;
    }
  }

  String _getStatusText() {
    if (_isOverdue()) {
      return "已过期";
    }
    switch (todo.status) {
      case TodoStatus.todo:
        return 'todo'.tr;
      case TodoStatus.inProgress:
        return 'inProgress'.tr;
      case TodoStatus.done:
        return 'done'.tr;
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
        _homeCtrl.startDragging();
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
      child: GestureDetector(
        onTap: () {
          Get.toNamed('/todo-detail', arguments: {
            'todoId': todo.uuid,
            'taskId': taskId,
          });
        },
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
                              dialog: const TodoDialog(
                                  dialogTag: 'edit_todo_dialog'),
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
                if (todo.tagsWithColor.isNotEmpty)
                  const SizedBox(
                    height: 10,
                  ),
                if (todo.tagsWithColor.isNotEmpty)
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: todo.tagsWithColor.take(3).map((tagWithColor) {
                                // 限制标签文本长度
                                String displayText = tagWithColor.name;
                                if (tagWithColor.name.length > 8) {
                                  displayText = '${tagWithColor.name.substring(0, 6)}...';
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Tag(
                                    tag: displayText,
                                    color: tagWithColor.color, // 使用存储的颜色
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (todo.tagsWithColor.length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${todo.tagsWithColor.length - 3}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
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
                        Icon(
                          size: 15,
                          todo.dueDate > 0
                              ? (_isOverdue()
                                  ? FontAwesomeIcons.triangleExclamation
                                  : FontAwesomeIcons.calendarCheck)
                              : FontAwesomeIcons.calendar,
                          color: todo.dueDate > 0
                              ? (_isOverdue() ? Colors.red : Colors.grey)
                              : Colors.grey,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          todo.dueDate > 0
                              ? timestampToDate(todo.dueDate)
                              : "未设置",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: todo.dueDate > 0
                                ? (_isOverdue()
                                    ? Colors.red
                                    : Colors.grey.shade600)
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
      ),
    );
  }
}
