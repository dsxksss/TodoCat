import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/pages/home/components/task/task_card.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/nav_bar.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reorderables/reorderables.dart' as reorderables;

/// 首页类，继承自 GetView<HomeController>
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 在构建页面时就初始化 SettingsController
    Get.put(SettingsController(), permanent: true);

    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(context),
      body: TodoCatScaffold(
        title: _buildTitle(context),
        leftWidgets: _buildLeftWidgets(),
        rightWidgets: _buildRightWidgets(context),
        body: ListView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            Obx(
              () => Animate(
                target: controller.tasks.isEmpty ? 1 : 0,
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
                  child: reorderables.ReorderableWrap(
                    controller: ScrollController(),
                    spacing: context.isPhone ? 0 : 50,
                    runSpacing: context.isPhone ? 50 : 30,
                    onReorder: (oldIndex, int newIndex) async {
                      await controller.reorderTask(oldIndex, newIndex);
                    },
                    onNoReorder: (index) {
                      debugPrint('重新排序已取消，索引: $index');
                    },
                    onReorderStarted: (index) {
                      controller.startDragging();
                      debugPrint('开始重新排序，索引: $index');
                    },
                    buildDraggableFeedback: (context, constraints, child) {
                      return Material(
                        elevation: 6.0,
                        color: Colors.transparent,
                        child: SizedBox(
                          width: context.isPhone ? 0.9.sw : 240,
                          child: child,
                        ),
                      );
                    },
                    enableReorder: true,
                    footer: 100.verticalSpace,
                    alignment: context.isPhone
                        ? WrapAlignment.center
                        : WrapAlignment.start,
                    children: [
                      ...controller.tasks
                          .map((task) => TaskCard(
                                key: ValueKey(task.uuid),
                                task: task,
                              ))
                          .toList(),
                      if (controller.tasks.isNotEmpty)
                        SizedBox(
                          width: context.isPhone ? 0.9.sw : 240,
                          height: 0,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建浮动按钮
  Widget _buildFloatingActionButton(BuildContext context) {
    return AnimationBtn(
      onPressed: () async {
        final task = Task()
          ..uuid = const Uuid().v4()
          ..title = Random().nextInt(1000).toString()
          ..createdAt = DateTime.now().millisecondsSinceEpoch
          ..tags = []
          ..todos = [];

        await controller.addTask(task);
        await controller.scrollMaxDown();
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
        .moveX(begin: 100, duration: 1000.ms, curve: Curves.easeOut);
  }

  /// 构建标题
  String _buildTitle(BuildContext context) {
    return context.isPhone
        ? "myTasks".tr
        : "${"myTasks".tr} ${controller.appCtrl.appConfig.value.isDebugMode ? 'Debug' : 'Release'}";
  }

  /// 构建左侧控件列表
  List<Widget> _buildLeftWidgets() {
    return [
      Image.asset(
        'assets/imgs/logo-light-rounded.png',
        width: 34,
        height: 34,
        filterQuality: FilterQuality.medium,
      ),
      const SizedBox(
        width: 20,
      ),
    ];
  }

  /// 构建右侧控件列表
  List<Widget> _buildRightWidgets(BuildContext context) {
    return [
      NavBarBtn(
        onPressed: () {
          // 获取已初始化的控制器
          final settingsController = Get.find<SettingsController>();
          settingsController.showSettings();
        },
        child: const Icon(
          Icons.settings,
          size: 24,
        ),
      ),
    ];
  }
}
