import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/pages/home/controller.dart';
import 'package:todo_cat/app/pages/home/widgets/add_tag_screen.dart';
import 'package:todo_cat/app/pages/home/widgets/select_priority_btn.dart';
import 'package:todo_cat/app/pages/home/widgets/text_form_field_item.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({
    super.key,
  });

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final HomeController ctrl = Get.find();

  @override
  void dispose() {
    ctrl.deselectTask();
    ctrl.onDialogClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 0.7.sw,
        height: 0.5.sw,
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: SizedBox.expand(
          child: Form(
            key: ctrl.formKey,
            child: Material(
              type: MaterialType.transparency,
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
                          if (ctrl.formKey.currentState!.validate()) {
                            ctrl.addTodo(
                              Todo(
                                id: 1,
                                title: ctrl.titleFormCtrl.text,
                                description: ctrl.descriptionFormCtrl.text,
                                createdAt:
                                    DateTime.now().millisecondsSinceEpoch,
                                tags: ctrl.selectedTags,
                                priority: ctrl.selectedPriority.value,
                              ),
                            );

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
                          editingController: ctrl.titleFormCtrl,
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
                    editingController: ctrl.descriptionFormCtrl,
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  AddTagScreen(),
                ].animate(interval: 100.ms).moveX(begin: 20).fade(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
