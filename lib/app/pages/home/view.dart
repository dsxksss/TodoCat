import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/pages/home/controller.dart';
import 'package:todo_cat/app/pages/home/widgets/task_card.dart';
import 'package:todo_cat/app/widgets/nav_bar.dart';

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
            title: Random().nextInt(1000).toString(),
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
      )
          .animate(delay: 2200.ms)
          .moveX(begin: 150, duration: 1000.ms, curve: Curves.bounceOut),
      body: SafeArea(
        child: ListView(
          children: [
            const NavBar(),
            Obx(
              () => Wrap(
                  direction: Axis.horizontal,
                  runSpacing: 40.w,
                  children: [
                    ...controller.tasks
                        .map((element) => TaskCard(task: element))
                  ].animate(interval: 100.ms).moveX().fade()),
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
