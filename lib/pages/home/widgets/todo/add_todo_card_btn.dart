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
  SmartDialog.dismiss();
  SmartDialog.show(
    useSystem: false,
    debounce: true,
    keepSingle: true,
    tag: "AddTodoDialog",
    maskColor: Colors.transparent,
    animationTime: 100.ms,
    builder: (context) => const AddTodoDialog(),
    clickMaskDismiss: false,
    onMask: () => SmartDialog.dismiss(tag: "AddTodoDialog"),
    animationBuilder: (controller, child, _) => child
        .animate(controller: controller)
        .fade(duration: controller.duration)
        .scaleXY(
          begin: 0.95,
          duration: controller.duration,
        ),
  );
}

void _showAddTodoBottomSheet(BuildContext context) {
  SmartDialog.dismiss();
  SmartDialog.show(
    debounce: true,
    keepSingle: true,
    tag: "AddTodoDialog",
    maskColor: Colors.transparent,
    animationTime: 300.ms,
    alignment: Alignment.bottomCenter,
    builder: (context) => const AddTodoDialog(),
    clickMaskDismiss: false,
    onMask: () => SmartDialog.dismiss(tag: "AddTodoDialog"),
    animationBuilder: (controller, child, _) =>
        child.animate(controller: controller).moveY(
              begin: 0.6.sh,
              duration: controller.duration,
              curve: Curves.easeOut,
            ),
  );
}
