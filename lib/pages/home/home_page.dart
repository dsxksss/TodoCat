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
import 'package:todo_cat/widgets/notification_center_dialog.dart';
import 'package:todo_cat/core/notification_center_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reorderables/reorderables.dart';
import 'package:todo_cat/widgets/task_dialog.dart';
import 'package:badges/badges.dart' as badges;

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
    return "myTasks".tr;
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
      // 通知中心按钮
      _buildNotificationCenterButton(),
      const SizedBox(width: 8),
      // 设置按钮
      NavBarBtn(
        onPressed: () {
          // 获取已初始化的控制器
          final settingsController = Get.find<SettingsController>();
          settingsController.showSettings();
        },
        child: Builder(
          builder: (context) => Icon(
            Icons.settings,
            size: 24,
            color: context.theme.iconTheme.color,
          ),
        ),
      ),
    ];
  }

  /// 构建通知中心按钮
  Widget _buildNotificationCenterButton() {
    final notificationCenter = Get.find<NotificationCenterManager>();
    return Obx(() {
      final unreadCount = notificationCenter.unreadCount;
      return NavBarBtn(
        onPressed: _showNotificationCenter,
        child: badges.Badge(
          showBadge: unreadCount > 0,
          badgeContent: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.all(4),
            elevation: 0,
          ),
          position: badges.BadgePosition.topEnd(top: -4, end: -4),
          child: Builder(
            builder: (context) => Icon(
              Icons.mail_outline,
              size: 24,
              color: context.theme.iconTheme.color,
            ),
          ),
        ),
      );
    });
  }

  /// 显示通知中心对话框
  void _showNotificationCenter() {
    SmartDialog.show(
      useSystem: false,
      debounce: true,
      keepSingle: true,
      tag: 'notification_center_dialog',
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 200),
      alignment: Alignment.center,
      builder: (_) => const NotificationCenterDialog(),
      clickMaskDismiss: true,
      animationBuilder: (controller, child, _) {
        return child
            .animate(controller: controller)
            .fade(duration: controller.duration)
            .scaleXY(
              begin: 0.95,
              duration: controller.duration,
              curve: Curves.easeOut,
            );
      },
    );
  }

  /// 添加显示对话框的方法
  void _showTaskDialog(BuildContext context) {
    SmartDialog.show(
      useSystem: false,
      debounce: true,
      keepSingle: true,
      tag: addTaskDialogTag,
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 150),
      alignment: context.isPhone ? Alignment.bottomCenter : Alignment.center,
      builder: (_) => context.isPhone
          ? const Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: TaskDialog(),
              ),
            )
          : const TaskDialog(),
      clickMaskDismiss: false,
      animationBuilder: (controller, child, _) {
        final animation = child
            .animate(controller: controller)
            .fade(duration: controller.duration);

        return context.isPhone
            ? animation
                .scaleXY(
                  begin: 0.97,
                  duration: controller.duration,
                  curve: Curves.easeIn,
                )
                .moveY(
                  begin: 0.6.sh,
                  duration: controller.duration,
                  curve: Curves.easeOutCirc,
                )
            : animation.scaleXY(
                begin: 0.98,
                duration: controller.duration,
                curve: Curves.easeIn,
              );
      },
    );
  }
}
