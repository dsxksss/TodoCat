import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/task/task_card.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/nav_bar.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reorderables/reorderables.dart';
import 'package:todo_cat/widgets/task_dialog.dart';

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
                  child: context.isPhone
                      ? ReorderableColumn(
                          needsLongPressDraggable: true,
                          onReorder: (oldIndex, int newIndex) {
                            controller
                                .reorderTask(oldIndex, newIndex)
                                .then((_) {
                              controller.endDragging();
                            });
                          },
                          onNoReorder: (index) {
                            controller.endDragging();
                          },
                          onReorderStarted: (index) {
                            controller.startDragging();
                          },
                          buildDraggableFeedback:
                              (context, constraints, child) {
                            return child.animate().scaleXY(
                                  begin: 1.0,
                                  end: 1.1,
                                  duration: 60.ms,
                                  curve: Curves.easeOut,
                                );
                          },
                          children: controller.tasks
                              .map((task) => Padding(
                                    key: ValueKey(task.uuid),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    child: SizedBox(
                                      width: 0.9.sw,
                                      child: TaskCard(task: task),
                                    ),
                                  ))
                              .toList(),
                        )
                      : SingleChildScrollView(
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: ReorderableWrap(
                            needsLongPressDraggable: true,
                            scrollAnimationDuration:
                                const Duration(milliseconds: 300),
                            reorderAnimationDuration:
                                const Duration(milliseconds: 200),
                            spacing: 50,
                            runSpacing: 30,
                            padding: const EdgeInsets.all(8),
                            onReorder: (oldIndex, int newIndex) {
                              controller
                                  .reorderTask(oldIndex, newIndex)
                                  .then((_) {
                                controller.endDragging();
                              });
                            },
                            onNoReorder: (index) {
                              controller.endDragging();
                            },
                            onReorderStarted: (index) {
                              controller.startDragging();
                            },
                            buildDraggableFeedback:
                                (context, constraints, child) {
                              return child.animate().scaleXY(
                                    begin: 1.0,
                                    end: 1.1,
                                    duration: 60.ms,
                                    curve: Curves.easeOut,
                                  );
                            },
                            enableReorder: true,
                            alignment: WrapAlignment.start,
                            children: controller.tasks
                                .map((task) => TaskCard(
                                      key: ValueKey(task.uuid),
                                      task: task,
                                    ))
                                .toList(),
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

  /// 构建浮动按钮
  Widget _buildFloatingActionButton(BuildContext context) {
    return AnimationBtn(
      onPressed: () {
        _showTaskDialog(context);
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

  /// 添加显示对话框的方法
  void _showTaskDialog(BuildContext context) {
    SmartDialog.show(
      useSystem: false,
      debounce: true,
      keepSingle: true,
      tag: addTaskDialogTag, // 需要在 dialog_keys.dart 中添加
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 150),
      builder: (_) => const TaskDialog(),
      clickMaskDismiss: false,
      animationBuilder: (controller, child, _) => child
          .animate(controller: controller)
          .fade(duration: controller.duration)
          .scaleXY(
            begin: 0.98,
            duration: controller.duration,
            curve: Curves.easeIn,
          ),
    );
  }
}
