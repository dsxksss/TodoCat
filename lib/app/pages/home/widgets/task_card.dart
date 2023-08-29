import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/pages/home/controller.dart';
import 'package:todo_cat/app/pages/home/widgets/add_todo_card_btn.dart';
import 'package:todo_cat/app/pages/home/widgets/todo_card.dart';
import 'package:todo_cat/app/widgets/animation_btn.dart';

class TaskCard extends StatelessWidget {
  TaskCard({super.key, required this.task});
  final HomeController ctrl = Get.find();
  final Task task;

  @override
  Widget build(BuildContext context) {
    final todosLength = task.todos.length;
    return Container(
      width: 400.w,
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 245, 247, 1),
        borderRadius: BorderRadius.circular(
          20.r,
        ),
      ),
      child: Flex(
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: 10.w,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 28.sp,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    if (todosLength > 0)
                      Container(
                        width: 34.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: const Color.fromRGBO(225, 224, 240, 1),
                        ),
                        child: Center(
                          child: Text(
                            todosLength.toString(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(17, 10, 76, 1),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                AnimationBtn(
                  onClickScale: 0.8,
                  onClickDuration: 100.ms,
                  onHoverAnimationEnabled: false,
                  padding: EdgeInsets.all(8.w),
                  onPressed: () => {print("p")},
                  child: Center(
                    child: Icon(
                      size: 35.w,
                      Icons.more_horiz,
                      color: const Color.fromRGBO(129, 127, 158, 1),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20.w,
          ),
          AddTodoCardBtn(
            task: task,
          ),
          SizedBox(
            height: 20.w,
          ),
          Obx(
            () => Column(
              children: [
                ...ctrl.tasks[ctrl.tasks.indexOf(task)].todos
                    .map((e) => TodoCard(todo: e))
              ].animate(interval: 100.ms).fadeIn(duration: 150.ms),
            ),
          ),
        ],
      ),
    );
  }
}
