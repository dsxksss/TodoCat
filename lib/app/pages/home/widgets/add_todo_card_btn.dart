import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/pages/home/controller.dart';

class AddTodoCardBtn extends StatelessWidget {
  AddTodoCardBtn({super.key, required this.task});
  final HomeController ctrl = Get.find();
  final Task task;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {showAddTodoDialog(task)},
      child: Container(
        width: 1.sw,
        margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(238, 238, 240, 1),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 36.w,
                color: Colors.grey[600],
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "addTodo".tr,
                style: TextStyle(
                    fontSize: 22.sp,
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

class AddTodoDialog extends StatelessWidget {
  AddTodoDialog({
    super.key,
    required this.task,
  });

  final HomeController ctrl = Get.find();
  final Task task;
  final formKey = GlobalKey<FormState>();
  final editCtrl = TextEditingController();

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
            key: formKey,
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
                            fontSize: 30.sp, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        child: Text("done".tr),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            ctrl.addTodo(
                              task,
                              Todo(
                                id: 1,
                                title: editCtrl.text,
                                createdAt:
                                    DateTime.now().millisecondsSinceEpoch,
                                tags: [
                                  "默认awada",
                                  "自带adawda",
                                  "默认",
                                  "自带a",
                                  "默认a",
                                  "自带xaw",
                                ],
                              ),
                            );

                            Get.back();
                          }
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  TextFormField(
                    controller: editCtrl,
                    decoration: InputDecoration(
                        isDense: false,
                        fillColor: Colors.grey,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                        hintText: "Title",
                        hintStyle: const TextStyle(color: Colors.grey),
                        focusColor: Colors.green

                        // prefixIcon: Icon(Icons.title_rounded),
                        ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "请填写完整内容";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showAddTodoDialog(Task task) {
  Get.generalDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: 250.ms,
    pageBuilder: (_, __, ___) {
      return AddTodoDialog(task: task);
    },
  );
}
