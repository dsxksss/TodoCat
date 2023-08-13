import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/pages/home/controller.dart';
import 'package:todo_cat/app/pages/home/widgets/task_card.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});
  final Task task = Task(title: "Task1", icon: 1, color: '#000000');
  final Todo todo = Todo(
      doThing: "写程序", icon: 2, color: '#000000', done: true, createdAt: 21213);

  @override
  Widget build(context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "addTask".tr,
        ),
        onPressed: () => {},
        isExtended: true,
        icon: const Icon(
          Icons.add_task,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.w),
              child: Text(
                "myTasks".tr,
                style: TextStyle(
                  fontSize: 60.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              direction: Axis.horizontal,
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskCard(
                  task: task.copyWith(title: "todo".tr),
                ),
                TaskCard(
                  task: task
                      .copyWith(title: "inProgress".tr, todos: [todo, todo]),
                ),
                TaskCard(
                  task: task.copyWith(title: "done".tr, todos: [todo]),
                ),
                TaskCard(
                  task: task.copyWith(title: "another".tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
