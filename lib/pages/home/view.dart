import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/env.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/task/task_card.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/nav_bar.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:uuid/uuid.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      floatingActionButton: AnimationBtn(
        onPressed: () {
          if (controller.addTask(
            Task(
              id: const Uuid().v4(),
              title: Random().nextInt(1000).toString(),
              createdAt: DateTime.now().millisecondsSinceEpoch,
              tags: [],
              todos: [],
            ),
          )) {
            controller.scrollMaxDown();
          }
        },
        child: Container(
          width: 60,
          height: 60,
          padding: context.isPhone ? EdgeInsets.zero : const EdgeInsets.all(8),
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
          .animate(delay: 200.ms)
          .rotate(begin: 1, duration: 1000.ms, curve: Curves.easeOut)
          .moveX(begin: 100, duration: 1000.ms, curve: Curves.easeOut),
      body: TodoCatScaffold(
        title:
            context.isPhone ? "myTasks".tr : "${"myTasks".tr} ${runMode.name}",
        leftWidgets: [
          Image.asset(
            'assets/imgs/logo-light-rounded.png',
            width: 34,
            height: 34,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(
            width: 20,
          ),
        ],
        rightWidgets: [
          NavBarBtn(
            onPressed: () => {},
            child: const Icon(
              Icons.filter_alt_outlined,
              size: 26,
            ),
          ),
          const SizedBox(width: 10),
          NavBarBtn(
            onPressed: () => Get.toNamed('/settings'),
            child: const Icon(
              Icons.settings,
              size: 24,
            ),
          ),
        ],
        body: ListView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            //当内容不足时也可以启动反弹刷新
            parent: BouncingScrollPhysics(),
          ),
          children: [
            Obx(
              () => Animate(
                target: controller.tasks.isNotEmpty ? 0 : 1,
                effects: [
                  SwapEffect(
                    builder: (_, __) => SizedBox(
                      height: 0.7.sh,
                      child: Center(
                        child: Text(
                          "Do It Now !",
                          style: GoogleFonts.getFont(
                            'Ubuntu',
                            textStyle: const TextStyle(
                              fontSize: 60,
                            ),
                          ),
                        ),
                      ).animate().fade(),
                    ),
                  ),
                ],
                child: Padding(
                  padding: context.isPhone
                      ? const EdgeInsets.only(bottom: 50)
                      : const EdgeInsets.only(left: 20, bottom: 50),
                  child: Wrap(
                    alignment: context.isPhone
                        ? WrapAlignment.center
                        : WrapAlignment.start,
                    direction: Axis.horizontal,
                    spacing: context.isPhone ? 0 : 50,
                    runSpacing: context.isPhone ? 50 : 30,
                    children: AnimateList(
                      onComplete: (_) =>
                          controller.listAnimatInterval.value = Duration.zero,
                      effects: [
                        context.isPhone
                            ? const MoveEffect(begin: Offset(0, 10))
                            : const MoveEffect(begin: Offset(-10, 0)),
                        const FadeEffect(),
                      ],
                      interval: controller.listAnimatInterval.value,
                      children: [
                        ...controller.tasks
                            .map((element) => TaskCard(task: element))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
