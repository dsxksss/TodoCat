import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/pages/home/controller.dart';
import 'package:todo_cat/app/pages/home/widgets/task_card.dart';
import 'package:todo_cat/env.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "addTask".tr,
        ),
        onPressed: () => {
          controller.addTask(Task(
            id: 5,
            title: "new Task",
            createdAt: DateTime.now().millisecondsSinceEpoch,
            tags: [],
            todos: [],
          ))
        },
        isExtended: true,
        icon: const Icon(
          Icons.add_task,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            GestureDetector(
              onPanDown: (DragDownDetails details) {
                WindowManager.instance.startDragging();
              },
              child: Container(
                width: 1.sw,
                color: isDebugMode ? Colors.greenAccent : null,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.w),
                child: Text(
                  "myTasks".tr,
                  style: TextStyle(
                    fontSize: 60.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Obx(
              () => Wrap(
                direction: Axis.horizontal,
                runSpacing: 40.w,
                children: [
                  ...controller.tasks.map((element) => TaskCard(task: element))
                ],
              ),
            ),
            SizedBox(
              height: 0.05.sw,
            )
          ],
        ),
      ),
    );
  }
}
