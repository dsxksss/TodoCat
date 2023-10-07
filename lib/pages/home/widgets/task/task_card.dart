import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/task/task_dpd_menu_btn.dart';
import 'package:todo_cat/pages/home/widgets/todo/add_todo_card_btn.dart';
import 'package:todo_cat/pages/home/widgets/todo/todo_card.dart';
import 'package:todo_cat/widgets/show_toast.dart';

class TaskCard extends StatelessWidget {
  TaskCard({super.key, required Task task}) : _task = task;
  final HomeController _homeCtrl = Get.find();
  final Task _task;

  List<dynamic> _getColorAndIcon() {
    switch (_task.title) {
      case 'todo':
        return [Colors.grey, FontAwesomeIcons.clipboard];
      case 'inProgress':
        return [Colors.orangeAccent, FontAwesomeIcons.pencil];
      case 'done':
        return [
          const Color.fromRGBO(46, 204, 147, 1),
          FontAwesomeIcons.circleCheck
        ];
      default:
        return [Colors.lightBlue, FontAwesomeIcons.listOl];
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosLength = _task.todos.length;
    final colorAndIcon = _getColorAndIcon();
    return Container(
      width: context.isPhone ? 0.9.sw : 240,
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(width: 0.4, color: context.theme.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.theme.dividerColor,
            blurRadius: context.isDarkMode ? 0.2 : 3.5,
          ),
        ],
      ),
      child: Flex(
        direction: Axis.vertical,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                  ),
                  Container(
                    width: 5,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorAndIcon[0],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    colorAndIcon[1],
                    size: colorAndIcon[1] == FontAwesomeIcons.pencil ? 18 : 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    _task.title.tr,
                    style: GoogleFonts.getFont(
                      'Ubuntu',
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (todosLength > 0)
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 24,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color.fromRGBO(225, 224, 240, 1),
                          ),
                          child: Center(
                            child: Text(
                              todosLength.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(17, 10, 76, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: TaskDropDownMenuBtn(
                  menuItems: [
                    MenuItem(
                      title: 'edit',
                      iconData: FontAwesomeIcons.penToSquare,
                      callback: () => {
                        showToast(
                          "${_task.title} 编辑成功",
                          toastStyleType: TodoCatToastStyleType.success,
                        )
                      },
                    ),
                    MenuItem(
                      title: 'delete',
                      iconData: FontAwesomeIcons.trashCan,
                      callback: () => {
                        if (_homeCtrl.deleteTask(_task.id))
                          {
                            showToast(
                              "${"task".tr} '${_task.title.tr}' ${"deletedSuccessfully".tr}",
                              toastStyleType: TodoCatToastStyleType.success,
                            )
                          }
                        else
                          {
                            showToast(
                              "${"task".tr} '${_task.title.tr}' ${"deletionFailed".tr}",
                              toastStyleType: TodoCatToastStyleType.error,
                            )
                          }
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          AddTodoCardBtn(
            task: _task,
          ),
          const SizedBox(
            height: 15,
          ),
          Obx(
            () => Column(
              children: [
                ..._homeCtrl.tasks[_homeCtrl.tasks.indexOf(_task)].todos.map(
                    (e) => context.isPhone
                        ? TodoCard(todo: e)
                        : PressableDough(child: TodoCard(todo: e)))
              ].animate(interval: 100.ms).fadeIn(duration: 150.ms),
            ),
          ),
        ],
      ),
    );
  }
}
