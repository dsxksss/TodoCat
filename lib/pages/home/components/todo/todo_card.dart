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

class TodoCard extends StatelessWidget {
  TodoCard({super.key, required String taskId, required Todo todo})
      : _taskId = taskId,
        _todo = todo;
  final HomeController _homeCtrl = Get.find();
  final String _taskId;
  final Todo _todo;

  IconData _getStatusIconData() {
    switch (_todo.status) {
      case TodoStatus.todo:
        return FontAwesomeIcons.hourglassStart;
      case TodoStatus.inProgress:
        return FontAwesomeIcons.hourglassEnd;
      case TodoStatus.done:
        return FontAwesomeIcons.checkDouble;
    }
  }

  Color _getPriorityColor() {
    switch (_todo.priority) {
      case TodoPriority.lowLevel:
        return const Color.fromRGBO(46, 204, 147, 1);
      case TodoPriority.mediumLevel:
        return const Color.fromARGB(255, 251, 136, 94);
      case TodoPriority.highLevel:
        return const Color.fromARGB(255, 251, 98, 98);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
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
                          _todo.title,
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
                      callback: () => {
                        showToast(
                          _todo.title,
                          suffix: "编辑成功",
                          suffixGap: 5,
                          toastStyleType: TodoCatToastStyleType.success,
                        )
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
                            final isDeleted =
                                _homeCtrl.deleteTodo(_taskId, _todo.id);
                            0.5.delay(() {
                              if (isDeleted) {
                                showToast(
                                  "${"todo".tr} '${_todo.title.tr}' ${"deletedSuccessfully".tr}",
                                  toastStyleType: TodoCatToastStyleType.success,
                                );
                              } else {
                                showToast(
                                  "${"todo".tr} '${_todo.title.tr}' ${"deletionFailed".tr}",
                                  toastStyleType: TodoCatToastStyleType.error,
                                );
                              }
                            });
                          },
                        )
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (_todo.tags.isNotEmpty)
              const SizedBox(
                height: 10,
              ),
            if (_todo.tags.isNotEmpty)
              SizedBox(
                height: 20,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._todo.tags
                        .sublist(0, _todo.tags.length > 3 ? 3 : null)
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
                      timestampToDate(_todo.finishedAt),
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
    );
  }
}
