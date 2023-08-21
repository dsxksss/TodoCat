import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/pages/home/controller.dart';
import 'package:todo_cat/app/pages/home/widgets/add_tag_screen.dart';
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
    ctrl.tags.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 0.6.sw,
        height: 600.w,
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
                                tags: ctrl.tags,
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
                    height: 20.w,
                  ),
                  TextFormFieldItem(
                    fieldTitle: "title".tr,
                    editingController: ctrl.titleFormCtrl,
                  ),
                  TextFormFieldItem(
                    fieldTitle: "description".tr,
                    editingController: ctrl.descriptionFormCtrl,
                  ),
                  AddTagScreen()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
