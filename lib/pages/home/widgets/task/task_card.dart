import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/task/task_dpd_menu_btn.dart';
import 'package:todo_cat/pages/home/widgets/todo/add_todo_card_btn.dart';
import 'package:todo_cat/pages/home/widgets/todo/todo_card.dart';

class TaskCard extends StatelessWidget {
  TaskCard({super.key, required this.task});
  final HomeController ctrl = Get.find();
  final Task task;

  Color getColor() {
    switch (task.title) {
      case 'todo':
        return Colors.grey;
      case 'inProgress':
        return Colors.orangeAccent;
      case 'done':
        return Colors.greenAccent;
      default:
        return Colors.lightBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosLength = task.todos.length;
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 245, 247, 1),
        borderRadius: BorderRadius.circular(
          10,
        ),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      task.title.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (todosLength > 0)
                    const SizedBox(
                      width: 10,
                    ),
                  if (todosLength > 0)
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
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: getColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 15),
                child: TaskDropDownMenuBtn(
                  menuItems: [
                    MenuItem(
                      title: 'edit',
                      iconData: FontAwesomeIcons.penToSquare,
                      callback: () => {SmartDialog.showToast("编辑事项")},
                    ),
                    MenuItem(
                      title: 'delete',
                      iconData: FontAwesomeIcons.trashCan,
                      callback: () => {ctrl.deleteTask(task.id)},
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
            task: task,
          ),
          const SizedBox(
            height: 15,
          ),
          Obx(
            () => Column(
              children: [
                ...ctrl.tasks[ctrl.tasks.indexOf(task)].todos
                    .map((e) => PressableDough(child: TodoCard(todo: e)))
              ].animate(interval: 100.ms).fadeIn(duration: 150.ms),
            ),
          ),
        ],
      ),
    );
  }
}
