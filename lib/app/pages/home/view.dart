import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/core/utils/extensions.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/pages/home/controller.dart';
import 'package:todo_cat/app/pages/home/widgets/task_card.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});
  final Task task = Task(title: "Task1", icon: 1, color: '#000000');
  @override
  Widget build(context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(4.0.wp),
              child: Text(
                "myTasks".tr,
                style: TextStyle(
                  fontSize: 8.0.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                TaskCard(
                  task: task,
                ),
                TaskCard(
                  task: task,
                ),
                TaskCard(
                  task: task,
                ),
                TaskCard(
                  task: task,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
