import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/add_todo_dialog_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/todo/add_todo_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class AddTodoCardBtn extends StatelessWidget {
  AddTodoCardBtn({super.key, required Task task}) : _task = task;
  final HomeController _homeCtrl = Get.find();
  final AddTodoDialogController _addTodoCtrl = Get.find();
  final Task _task;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onPressed: () {
        _homeCtrl.selectTask(_task);
        _addTodoCtrl.clearForm();
        context.isPhone
            ? _showAddTodoBottomSheet(context)
            : _showAddTodoDialog();
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
    debounce: true,
    keepSingle: true,
    tag: addTodoDialogTag,
    backDismiss: false,
    animationTime: const Duration(milliseconds: 150),
    builder: (_) => const AddTodoDialog(),
    clickMaskDismiss: false,
    animationBuilder: (controller, child, _) => child
        .animate(controller: controller)
        .fade(duration: controller.duration)
        .scaleXY(
          begin: 0.98,
          duration: controller.duration,
          curve: Curves.easeIn,
        ),
  );
}

void _showAddTodoBottomSheet(BuildContext context) {
  SmartDialog.show(
    debounce: true,
    keepSingle: true,
    tag: addTodoDialogTag,
    backDismiss: false,
    animationTime: const Duration(milliseconds: 110),
    alignment: Alignment.bottomCenter,
    builder: (_) => const Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AddTodoDialog(),
      ),
    ),
    clickMaskDismiss: false,
    animationBuilder: (controller, child, _) => child
        .animate(controller: controller)
        .fade(duration: controller.duration)
        .scaleXY(
          begin: 0.97,
          duration: controller.duration,
          curve: Curves.easeIn,
        )
        .moveY(
          begin: 0.6.sh,
          duration: controller.duration,
          curve: Curves.easeOutCirc,
        ),
  );
}
