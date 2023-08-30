import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/task_card.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/nav_bar.dart';
import 'package:uuid/uuid.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      floatingActionButton: AnimationBtn(
        onPressed: () {
          controller.addTask(
            Task(
              id: const Uuid().v4(),
              title: Random().nextInt(1000).toString(),
              createdAt: DateTime.now().millisecondsSinceEpoch,
              tags: [],
              todos: [],
            ),
          );
        },
        padding: EdgeInsets.all(8.w),
        child: Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            color: Colors.lightBlue,
          ),
          child: Icon(
            Icons.add_task,
            size: 45.w,
            color: Colors.white,
          ),
        ),
      )
          .animate(delay: 2200.ms)
          .rotate(begin: 1, duration: 1000.ms, curve: Curves.easeOut)
          .moveX(begin: 100, duration: 1000.ms, curve: Curves.easeOut),
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
