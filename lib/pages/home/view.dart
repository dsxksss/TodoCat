import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/task_card.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
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
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            color: Colors.lightBlue,
          ),
          child: const Icon(
            Icons.add_task,
            size: 30,
            color: Colors.white,
          ),
        ),
      )
          .animate(delay: 2200.ms)
          .rotate(begin: 1, duration: 1000.ms, curve: Curves.easeOut)
          .moveX(begin: 100, duration: 1000.ms, curve: Curves.easeOut),
      body: TodoCatScaffold(
        body: ListView(
          children: [
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 50,
                    runSpacing: 30,
                    children: [
                      ...controller.tasks
                          .map((element) => TaskCard(task: element))
                    ].animate(interval: 100.ms).moveX().fade()),
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
