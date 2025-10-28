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
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';

/// 首页类，继承自 GetView<HomeController>
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 在构建页面时就初始化 SettingsController
    Get.put(SettingsController(), permanent: true);
    
    // 获取 AppController 以读取背景图片设置
    final appCtrl = Get.find<AppController>();
    
    return Obx(() {
      final backgroundImagePath = appCtrl.appConfig.value.backgroundImagePath;
      final hasBackground = backgroundImagePath != null && 
                            backgroundImagePath.isNotEmpty && 
                            File(backgroundImagePath).existsSync();
      final affectsNavBar = hasBackground ? appCtrl.appConfig.value.backgroundAffectsNavBar : false;
      final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
      final blur = appCtrl.appConfig.value.backgroundImageBlur;
      
      return Scaffold(
        floatingActionButton: _buildFloatingActionButton(context),
        body: hasBackground && affectsNavBar
            ? _buildWithBackground(backgroundImagePath, opacity, blur)
            : hasBackground && !affectsNavBar
                ? _buildWithBackgroundNavOnly(backgroundImagePath, opacity, blur)
                : TodoCatScaffold(
        title: _buildTitle(context),
        leftWidgets: _buildLeftWidgets(),
        rightWidgets: _buildRightWidgets(context),
        body: context.isPhone
            ? ListView(
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
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ReorderableColumn(
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
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Obx(
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
                  child: _TaskHorizontalList(tasks: controller.reactiveTasks),
                ),
              ),
      ),
    );
    });
  }

  /// 构建带背景的页面（影响导航栏）
  Widget _buildWithBackground(String imagePath, double opacity, double blur) {
    return Stack(
      children: [
        // 背景图片层
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
                opacity: opacity,
              ),
            ),
          ),
        ),
        // 模糊层（毛玻璃效果）
        if (blur > 0)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blur,
                sigmaY: blur,
              ),
              child: Container(color: Colors.white.withOpacity(0.0)),
            ),
          ),
        // 内容层（完全透明）
        TodoCatScaffold(
          title: _buildTitle(Get.context!),
          leftWidgets: _buildLeftWidgets(),
          rightWidgets: _buildRightWidgets(Get.context!),
          body: _buildBody(),
        ),
      ],
    );
  }

  /// 构建带背景的页面（仅内容区域，不影响导航栏）
  Widget _buildWithBackgroundNavOnly(String imagePath, double opacity, double blur) {
    // 直接构建，不包裹在TodoCatScaffold中，手动处理导航栏和内容区域
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFloatingActionButton(Get.context!),
      body: SafeArea(
        minimum: EdgeInsets.zero,
        bottom: false,
        child: Column(
          children: [
            if (Platform.isMacOS) 15.verticalSpace,
            // 导航栏（无背景，保持清晰）
            NavBar(
              title: _buildTitle(Get.context!),
              leftWidgets: _buildLeftWidgets(),
              rightWidgets: _buildRightWidgets(Get.context!),
            ),
            5.verticalSpace,
            // 内容区域（有背景和模糊）- 使用ClipRect限制模糊范围
            Expanded(
              child: ClipRect(
                child: Stack(
                  children: [
                    // 背景图片层
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                            opacity: opacity,
                          ),
                        ),
                      ),
                    ),
                    // 模糊层（毛玻璃效果）
                    if (blur > 0)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: blur,
                            sigmaY: blur,
                          ),
                          child: Container(color: Colors.white.withOpacity(0.0)),
                        ),
                      ),
                    // 内容层（完全透明）
                    Container(
                      color: Colors.transparent,
                      child: _buildBody(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    return Get.context!.isPhone
        ? ListView(
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
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ReorderableColumn(
                      needsLongPressDraggable: true,
                      onReorder: (oldIndex, int newIndex) {
                        controller.reorderTask(oldIndex, newIndex).then((_) {
                          controller.endDragging();
                        });
                      },
                      onNoReorder: (index) {
                        controller.endDragging();
                      },
                      onReorderStarted: (index) {
                        controller.startDragging();
                      },
                      buildDraggableFeedback: (context, constraints, child) {
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
                    ),
                  ),
                ),
              ),
            ],
          )
        : Obx(
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
              child: Column(
                children: [
                  SizedBox(
                    height: 0.8.sh,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(left: 20),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: controller.tasks
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final task = entry.value;
                            return Padding(
                              key: ValueKey(task.uuid),
                              padding: EdgeInsets.only(
                                right: index == controller.tasks.length - 1 ? 0 : 30,
                              ),
                              child: TaskCard(task: task),
                            );
                          }).toList(),
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
      // Badge 放在 NavBarBtn 外面，这样 hover 不会影响 badge 的颜色
      return badges.Badge(
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
        child: NavBarBtn(
          onPressed: _showNotificationCenter,
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

/// Task横向列表组件，支持拖拽排序和边缘自动滚动
class _TaskHorizontalList extends StatefulWidget {
  final RxList<Task> tasks;
  
  const _TaskHorizontalList({required this.tasks});

  @override
  State<_TaskHorizontalList> createState() => _TaskHorizontalListState();
}

class _TaskHorizontalListState extends State<_TaskHorizontalList> with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  final HomeController _controller = Get.find();
  Timer? _scrollTimer;
  late AnimationController _scrollAnimationController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _scrollAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (event) {
        if (!_controller.shouldAnimate.value) return;
        
        const scrollThreshold = 150;
        final screenWidth = MediaQuery.of(context).size.width;
        final position = event.position;
        const scrollSpeed = 20.0;
        
        _scrollTimer?.cancel();
        
        if (position.dx < scrollThreshold && _scrollController.offset > 0) {
          // 接近左边缘，向左滚动
          _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
            if (!mounted || !_controller.shouldAnimate.value) {
              _scrollTimer?.cancel();
              return;
            }
            final offset = _scrollController.offset - scrollSpeed;
            if (offset > 0) {
              _scrollController.jumpTo(offset);
            }
          });
        } else if (position.dx > screenWidth - scrollThreshold &&
            _scrollController.offset < _scrollController.position.maxScrollExtent) {
          // 接近右边缘，向右滚动
          _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
            if (!mounted || !_controller.shouldAnimate.value) {
              _scrollTimer?.cancel();
              return;
            }
            final maxOffset = _scrollController.position.maxScrollExtent;
            final offset = _scrollController.offset + scrollSpeed;
            if (offset < maxOffset) {
              _scrollController.jumpTo(offset);
            }
          });
        }
      },
      onPointerUp: (_) {
        _scrollTimer?.cancel();
      },
      child: SizedBox(
          height: 0.8.sh,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(left: 20),
            child: IntrinsicHeight(
              child: ReorderableRow(
                needsLongPressDraggable: true,
                scrollAnimationDuration: const Duration(milliseconds: 300),
                reorderAnimationDuration: const Duration(milliseconds: 200),
                padding: EdgeInsets.zero,
                onReorder: (oldIndex, int newIndex) {
                  _controller
                      .reorderTask(oldIndex, newIndex)
                      .then((_) {
                    _controller.endDragging();
                  });
                },
                onNoReorder: (index) {
                  _controller.endDragging();
                },
                onReorderStarted: (index) {
                  _controller.startDragging();
                },
                buildDraggableFeedback: (context, constraints, child) {
                  return child.animate().scaleXY(
                        begin: 1.0,
                        end: 1.1,
                        duration: 60.ms,
                        curve: Curves.easeOut,
                      );
                },
                children: widget.tasks
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  return Padding(
                    key: ValueKey(task.uuid),
                    padding: EdgeInsets.only(
                      right: index == widget.tasks.length - 1 ? 0 : 30,
                    ),
                    child: TaskCard(task: task),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
  }
}
