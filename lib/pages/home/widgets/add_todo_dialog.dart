import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/add_tag_screen.dart';
import 'package:todo_cat/pages/home/widgets/date_picker.dart';
import 'package:todo_cat/pages/home/widgets/select_priority_btn.dart';
import 'package:todo_cat/pages/home/widgets/text_form_field_item.dart';
import 'package:uuid/uuid.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({
    super.key,
  });

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final HomeController homeCtrl = Get.find();
  late final AddTodoDialogController dialogCtrl;

  @override
  void initState() {
    Get.lazyPut(() => AddTodoDialogController());
    dialogCtrl = Get.find();
    super.initState();
  }

  @override
  void dispose() {
    dialogCtrl.onDialogClose();
    homeCtrl.deselectTask();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 0.7.sw,
          height: 0.5.sw,
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Form(
            key: dialogCtrl.formKey,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "addTodo".tr,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      // 取消按钮按下时出现的颜色
                      style: const ButtonStyle(
                          overlayColor:
                              MaterialStatePropertyAll(Colors.transparent)),
                      onPressed: () {
                        if (dialogCtrl.formKey.currentState!.validate()) {
                          final todo = Todo(
                            id: const Uuid().v4(),
                            title: dialogCtrl.titleFormCtrl.text,
                            description: dialogCtrl.descriptionFormCtrl.text,
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            tags: dialogCtrl.selectedTags,
                            priority: homeCtrl.selectedPriority.value,
                            reminders: DateTime.now()
                                .add(const Duration(seconds: 10))
                                .millisecondsSinceEpoch,
                          );

                          homeCtrl.addTodo(todo);

                          Get.back();
                        }
                      },
                      child: Text("done".tr),
                    )
                  ],
                ),
                SizedBox(
                  height: 40.w,
                ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 0.3.sw,
                      child: TextFormFieldItem(
                        fieldTitle: "title".tr,
                        editingController: dialogCtrl.titleFormCtrl,
                      ),
                    ),
                    SizedBox(
                      width: 0.3.sw,
                      child: SelectPriorityBotton(
                        fieldTitle: "priority".tr,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.w,
                ),
                TextFormFieldItem(
                  fieldTitle: "description".tr,
                  validator: (_) => null,
                  editingController: dialogCtrl.descriptionFormCtrl,
                ),
                SizedBox(
                  height: 20.w,
                ),
                AddTagScreen(),
                SizedBox(
                  height: 25.w,
                ),
                DatePicker(
                  editingController: dialogCtrl.remindersController,
                  fieldTitle: 'reminderTime'.tr,
                ),
              ].animate(interval: 100.ms).moveX(begin: 20).fade(),
            ),
          ),
        ),
      ),
    );
  }
}
