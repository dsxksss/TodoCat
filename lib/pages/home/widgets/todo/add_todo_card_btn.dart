import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/todo/add_todo_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class AddTodoCardBtn extends StatelessWidget {
  AddTodoCardBtn({super.key, required this.task});
  final HomeController ctrl = Get.find();
  final Task task;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onPressed: () => {
        ctrl.selectTask(task),
        showAddTodoDialog(),
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(238, 238, 240, 1),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                size: 15,
                FontAwesomeIcons.plus,
                color: Colors.grey[600],
              ),
              const SizedBox(
                width: 2,
              ),
              Text(
                "addTodo".tr,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAddTodoDialog() {
  Get.generalDialog(
    barrierLabel: "showAddTodoDialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: 250.ms,
    pageBuilder: (_, __, ___) {
      return GestureDetector(child: const AddTodoDialog());
    },
  );
}
