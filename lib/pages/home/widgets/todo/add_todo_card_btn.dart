import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/todo/add_todo_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:uuid/uuid.dart';

class AddTodoCardBtn extends StatelessWidget {
  AddTodoCardBtn({super.key, required Task task}) : _task = task;
  final HomeController _homeCtrl = Get.find();
  final Task _task;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onPressed: () => {
        _homeCtrl.selectTask(_task),
        context.isPhone
            ? _showAddTodoBottomSheet(context)
            : _showAddTodoDialog(),
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
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

void _showAddTodoDialog() {
  SmartDialog.show(
    useSystem: false,
    tag: "AddTodoDialog",
    maskColor: Colors.transparent,
    animationTime: 100.ms,
    builder: (context) {
      return AddTodoDialog();
    },
    animationBuilder: (controller, child, _) => child
        .animate(controller: controller)
        .fade(duration: controller.duration)
        .moveY(
          begin: -2,
          duration: controller.duration,
        ),
  );
}

void _showAddTodoBottomSheet(BuildContext context) {
  final HomeController homeCtrl = Get.find();

  Get.bottomSheet(
    Container(
      height: 0.6.sh,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: context.theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("开发中..."),
              ElevatedButton(
                onPressed: () {
                  final todo = Todo(
                    id: const Uuid().v4(),
                    title: "Test",
                    description: "Test description",
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    tags: ["test", "description", "default"],
                    priority: TodoPriority.lowLevel,
                    reminders: DateTime.now()
                        .add(const Duration(minutes: 1))
                        .millisecondsSinceEpoch,
                  );
                  homeCtrl.addTodo(todo);

                  Get.back();
                },
                child: const Text("add Todo"),
              )
            ],
          ),
        ],
      ),
    ),
    enterBottomSheetDuration: 200.ms,
    exitBottomSheetDuration: 200.ms,
  );
}
