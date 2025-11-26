import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:todo_cat/widgets/dropdown_menu_btn.dart';
import 'package:todo_cat/widgets/create_workspace_dialog.dart';
import 'package:todo_cat/widgets/rename_workspace_dialog.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/nav_bar.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:todo_cat/widgets/notification_center_dialog.dart';
import 'package:todo_cat/core/notification_center_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_cat/widgets/task_dialog.dart';
import 'package:badges/badges.dart' as badges;
import 'dart:io';
import 'dart:ui';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/config/default_backgrounds.dart';
import 'package:todo_cat/widgets/appflowy_board_adapter.dart';
import 'package:todo_cat/controllers/trash_ctr.dart';
import 'package:todo_cat/widgets/trash_dialog.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/video_background.dart';
import 'package:todo_cat/services/video_download_service.dart';
import 'package:todo_cat/widgets/platform_dialog_wrapper.dart';

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
      final isDefaultTemplate = backgroundImagePath != null &&
          backgroundImagePath.startsWith('default_template:');
      final isCustomImage = backgroundImagePath != null &&
          !isDefaultTemplate &&
          backgroundImagePath.isNotEmpty &&
          GetPlatform.isDesktop &&
          File(backgroundImagePath).existsSync();
      final hasBackground = isDefaultTemplate || isCustomImage;
      final affectsNavBar = hasBackground
          ? appCtrl.appConfig.value.backgroundAffectsNavBar
          : false;
      final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
      final blur = appCtrl.appConfig.value.backgroundImageBlur;

      return Scaffold(
        floatingActionButton: _buildFloatingActionButton(context),
        body: hasBackground && affectsNavBar
            ? _buildWithBackground(backgroundImagePath, opacity, blur)
            : hasBackground && !affectsNavBar
                ? _buildWithBackgroundNavOnly(
                    backgroundImagePath, opacity, blur)
                : TodoCatScaffold(
                    title: _buildTitle(context),
                    leftWidgets: _buildLeftWidgets(),
                    rightWidgets: _buildRightWidgets(context),
                    body: context.isPhone
                        ? Obx(
                            () {
                              final isSwitching =
                                  controller.isSwitchingWorkspace.value;
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchOutCurve: Curves.easeIn,
                                switchInCurve: Curves.easeOut,
                                transitionBuilder: (child, animation) {
                                  final fadeAnimation = animation.status ==
                                          AnimationStatus.reverse
                                      ? animation
                                      : animation;
                                  return FadeTransition(
                                    opacity: fadeAnimation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: fadeAnimation,
                                        curve: fadeAnimation.status ==
                                                AnimationStatus.reverse
                                            ? Curves.easeIn
                                            : Curves.easeOut,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: isSwitching
                                    ? const SizedBox.shrink(
                                        key: ValueKey('switching'))
                                    : _TaskHorizontalListMobile(
                                        tasks: controller.reactiveTasks,
                                        key: const ValueKey('mobile_task_list'),
                                      ),
                              );
                            },
                          )
                        : Obx(
                            () {
                              // 强制建立对 RxList 的依赖，避免 GetX 提示未使用可观察对象
                              final _ = controller.reactiveTasks.length;
                              final isSwitching =
                                  controller.isSwitchingWorkspace.value;
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchOutCurve: Curves.easeIn,
                                switchInCurve: Curves.easeOut,
                                transitionBuilder: (child, animation) {
                                  // 使用 reverseAnimation 来控制淡出，animation 来控制淡入
                                  final fadeAnimation = animation.status ==
                                          AnimationStatus.reverse
                                      ? animation
                                      : animation;
                                  return FadeTransition(
                                    opacity: fadeAnimation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: fadeAnimation,
                                        curve: fadeAnimation.status ==
                                                AnimationStatus.reverse
                                            ? Curves.easeIn
                                            : Curves.easeOut,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: isSwitching
                                    ? const SizedBox.shrink(
                                        key: ValueKey('switching'))
                                    : _TaskHorizontalList(
                                        tasks: controller.reactiveTasks,
                                      ),
                              );
                            },
                          ),
                  ),
      );
    });
  }

  /// 获取背景装饰
  Widget _getBackgroundWidget(String? backgroundPath) {
    // 如果没有背景路径，返回空容器
    if (backgroundPath == null || backgroundPath.isEmpty) {
      return Container();
    }

    // 获取背景设置
    final appCtrl = Get.find<AppController>();
    final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
    final blur = appCtrl.appConfig.value.backgroundImageBlur;

    // 检查是否是默认模板
    if (backgroundPath.startsWith('default_template:')) {
      final templateId = backgroundPath.split(':').last;
      final template = DefaultBackgrounds.getById(templateId);

      if (template != null) {
        // 移动端不支持视频背景，如果是视频模板，返回空容器
        if (template.isVideo && GetPlatform.isMobile) {
          return Container(color: Colors.transparent);
        }
        // 检查是否为视频模板
        if (template.isVideo) {
          // 如果有downloadUrl，尝试使用缓存的视频路径
          if (template.downloadUrl != null) {
            // 使用稳定的 key 确保 Widget 不会被频繁重建
            return FutureBuilder<String?>(
              key: ValueKey('video_bg_future_$templateId'),
              future: VideoDownloadService()
                  .getCachedVideoPath(template.downloadUrl!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(color: Colors.black);
                }
                // 如果已缓存，使用缓存路径；否则使用原路径（可能不存在，但VideoBackground会处理）
                final videoPath = snapshot.data ?? template.imageUrl;
                // 使用 ExcludeSemantics 和稳定的 key 减少可访问性树更新
                return ExcludeSemantics(
                  child: VideoBackground(
                    key: ValueKey('video_bg_$templateId'),
                    videoPath: videoPath,
                    opacity: opacity,
                    blur: blur,
                  ),
                );
              },
            );
          } else {
            // 对于 assets 中的视频，直接使用 assets 路径
            // VideoBackground 会处理 assets 路径
            // 使用 ExcludeSemantics 和稳定的 key 减少可访问性树更新
            return ExcludeSemantics(
              child: VideoBackground(
                key: ValueKey('video_bg_$templateId'),
                videoPath: template.imageUrl,
                opacity: opacity,
                blur: blur,
              ),
            );
          }
        } else {
          // 使用本地图片
          return Opacity(
            opacity: opacity,
            child: ClipRect(
              child: blur > 0
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                      ),
                      child: Image.asset(
                        template.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // 回退到渐变占位符
                          final colors = _getGradientColors(templateId);
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: colors,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      template.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 回退到渐变占位符
                        final colors = _getGradientColors(templateId);
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        }
      } else {
        // 回退到渐变
        final colors = _getGradientColors(templateId);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        );
      }
    } else {
      // 自定义图片或视频
      // 检查文件是否存在
      if (GetPlatform.isDesktop && File(backgroundPath).existsSync()) {
        // 检查是否是视频文件
        final isVideo = backgroundPath.toLowerCase().endsWith('.mp4') ||
            backgroundPath.toLowerCase().endsWith('.mov') ||
            backgroundPath.toLowerCase().endsWith('.avi') ||
            backgroundPath.toLowerCase().endsWith('.mkv') ||
            backgroundPath.toLowerCase().endsWith('.webm');

        // 移动端不支持视频背景
        if (isVideo && GetPlatform.isMobile) {
          return Container(color: Colors.transparent);
        }

        if (isVideo) {
          // 使用视频背景
          // 使用 ExcludeSemantics 和稳定的 key 减少可访问性树更新
          return ExcludeSemantics(
            child: VideoBackground(
              key: ValueKey('video_bg_custom_$backgroundPath'),
              videoPath: backgroundPath,
              opacity: opacity,
              blur: blur,
            ),
          );
        } else {
          // 使用图片背景
          return Opacity(
            opacity: opacity,
            child: ClipRect(
              child: blur > 0
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(backgroundPath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(File(backgroundPath)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
          );
        }
      } else {
        // 文件不存在，返回空容器
        return Container();
      }
    }
  }

  /// 获取渐变颜色（用作占位符）
  List<Color> _getGradientColors(String templateId) {
    // 简单的灰色渐变占位符
    return [Colors.grey.shade300, Colors.grey.shade400];
  }

  /// 构建带背景的页面（影响导航栏）
  Widget _buildWithBackground(String imagePath, double opacity, double blur) {
    // 检查是否是视频
    final isVideo = !imagePath.startsWith('default_template:') &&
            (imagePath.toLowerCase().endsWith('.mp4') ||
                imagePath.toLowerCase().endsWith('.mov') ||
                imagePath.toLowerCase().endsWith('.avi') ||
                imagePath.toLowerCase().endsWith('.mkv') ||
                imagePath.toLowerCase().endsWith('.webm')) ||
        (imagePath.startsWith('default_template:') &&
            DefaultBackgrounds.getById(imagePath.split(':').last)?.isVideo ==
                true);

    return Stack(
      children: [
        // 背景图片/渐变层
        // 注意：VideoBackground 内部已经处理了 opacity，但图片背景需要外层 opacity
        Positioned.fill(
          child: isVideo
              ? _getBackgroundWidget(imagePath)
              : Opacity(
                  opacity: opacity,
                  child: _getBackgroundWidget(imagePath),
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
              child: Container(color: Colors.white.withValues(alpha: 0.0)),
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
  Widget _buildWithBackgroundNavOnly(
      String? imagePath, double opacity, double blur) {
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
                    // 背景图片/渐变层
                    Positioned.fill(
                      child: Opacity(
                        opacity: opacity,
                        child: _getBackgroundWidget(imagePath),
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
                          child: Container(
                              color: Colors.white.withValues(alpha: 0.0)),
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
        ? Obx(
            () {
              final isSwitching = controller.isSwitchingWorkspace.value;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchOutCurve: Curves.easeIn,
                switchInCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  final fadeAnimation =
                      animation.status == AnimationStatus.reverse
                          ? animation
                          : animation;
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: fadeAnimation,
                        curve: fadeAnimation.status == AnimationStatus.reverse
                            ? Curves.easeIn
                            : Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: isSwitching
                    ? const SizedBox.shrink(key: ValueKey('switching'))
                    : _TaskHorizontalListMobile(
                        tasks: controller.reactiveTasks,
                        key: const ValueKey('mobile_task_list'),
                      ),
              );
            },
          )
        : Obx(
            () {
              final isSwitching = controller.isSwitchingWorkspace.value;
              return Animate(
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchOutCurve: Curves.easeIn,
                  switchInCurve: Curves.easeOut,
                  transitionBuilder: (child, animation) {
                    // 使用 reverseAnimation 来控制淡出，animation 来控制淡入
                    final fadeAnimation =
                        animation.status == AnimationStatus.reverse
                            ? animation
                            : animation;
                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: fadeAnimation,
                          curve: fadeAnimation.status == AnimationStatus.reverse
                              ? Curves.easeIn
                              : Curves.easeOut,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: isSwitching
                      ? const SizedBox.shrink(key: ValueKey('switching'))
                      : _TaskHorizontalList(
                          tasks: controller.reactiveTasks,
                        ),
                ),
              );
            },
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
  String? _buildTitle(BuildContext context) {
    // 移动端不显示title，只显示logo
    return context.isPhone ? null : "todoCat".tr;
  }

  /// 构建左侧控件列表
  List<Widget> _buildLeftWidgets() {
    final widgets = <Widget>[];

    // 始终显示logo
    widgets.addAll([
      Image.asset(
        'assets/imgs/logo-light-rounded.png',
        width: 34,
        height: 34,
        filterQuality: FilterQuality.medium,
      ),
      const SizedBox(
        width: 20,
      ),
    ]);

    // 工作空间选择器
    widgets.add(_buildWorkspaceSelector());
    widgets.add(const SizedBox(width: 20));

    return widgets;
  }

  /// 构建工作空间选择器
  Widget _buildWorkspaceSelector() {
    if (!Get.isRegistered<WorkspaceController>()) {
      return const SizedBox.shrink();
    }

    final workspaceCtrl = Get.find<WorkspaceController>();

    return Obx(() {
      final workspaces = workspaceCtrl.workspaces;

      if (workspaces.isEmpty) {
        return const SizedBox.shrink();
      }

      return Builder(
        builder: (context) {
          // 使用 Obx 确保菜单项能够响应 currentWorkspaceId 的变化
          return Obx(() {
            final menuItems = <MenuItem>[];
            final currentWorkspaceId = workspaceCtrl.currentWorkspaceId.value;

            // 添加工作空间选项
            for (var workspace in workspaces) {
              final isCurrent = workspace.uuid == currentWorkspaceId;

              // 如果不是默认工作空间，构建包含重命名和删除按钮的 trailingWidget
              Widget? trailingWidget;
              if (workspace.uuid != 'default') {
                trailingWidget = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 重命名按钮
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          SmartDialog.dismiss(tag: 'workspace_selector');
                          showRenameWorkspaceDialog(workspace);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: context.theme.iconTheme.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // 删除按钮
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          SmartDialog.dismiss(tag: 'workspace_selector');
                          showToast(
                            '${'sureDeleteWorkspace'.tr}「${workspace.name}」',
                            alwaysShow: true,
                            confirmMode: true,
                            toastStyleType: TodoCatToastStyleType.error,
                            onYesCallback: () async {
                              final deleted = await workspaceCtrl
                                  .deleteWorkspace(workspace.uuid);
                              if (deleted) {
                                // 刷新回收站数据
                                if (Get.isRegistered<TrashController>()) {
                                  final trashCtrl = Get.find<TrashController>();
                                  await trashCtrl.refresh();
                                }
                                // 显示撤销通知
                                showUndoToast(
                                  '${'workspaceDeleted'.tr}「${workspace.name}」',
                                  () async {
                                    await workspaceCtrl
                                        .restoreWorkspace(workspace.uuid);
                                    // 刷新回收站数据
                                    if (Get.isRegistered<TrashController>()) {
                                      final trashCtrl =
                                          Get.find<TrashController>();
                                      await trashCtrl.refresh();
                                    }
                                  },
                                );
                              }
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.redAccent.shade200,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              menuItems.add(
                MenuItem(
                  title: workspace.name,
                  iconData: isCurrent ? Icons.check : null,
                  callback: () {
                    workspaceCtrl.switchWorkspace(workspace.uuid);
                  },
                  trailingWidget: trailingWidget,
                ),
              );
            }

            // 构建管理选项
            final createWorkspaceItem = MenuItem(
              title: 'createWorkspace',
              iconData: Icons.add,
              callback: () {
                showCreateWorkspaceDialog();
              },
            );

            return DropdownManuBtn(
              id: 'workspace_selector',
              content: DPDMenuContent(
                menuItems: menuItems,
                tag: 'workspace_selector',
                width: 195, // 仅为工作空间选择器设置固定宽度
                additionalWidgets: [
                  // 在工作空间列表和管理选项之间添加分割线
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: context.theme.dividerColor,
                    ),
                  ),
                  // 添加管理选项
                  DPDMenuContent.buildMenuItem(
                      context, createWorkspaceItem, 'workspace_selector'),
                ],
              ),
              alignment: Alignment.bottomRight,
              attachAlignmentType: SmartAttachAlignmentType.outside,
              child: Padding(
                // 添加内边距以扩大可点击区域，特别是左右边缘
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Obx(() {
                  final currentWorkspace = workspaceCtrl.currentWorkspace;
                  final displayName = currentWorkspace?.uuid == 'default'
                      ? 'defaultWorkspace'.tr
                      : (currentWorkspace?.name ?? 'defaultWorkspace'.tr);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.theme.textTheme.bodyLarge?.color,
                          ),
                          overflow: TextOverflow.ellipsis, // 防止文字换行，超长时显示省略号
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: context.theme.iconTheme.color,
                      ),
                    ],
                  );
                }),
              ),
            );
          });
        },
      );
    });
  }

  /// 构建右侧控件列表
  List<Widget> _buildRightWidgets(BuildContext context) {
    return [
      // 回收站按钮
      _buildTrashButton(),
      const SizedBox(width: 8),
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

  /// 构建回收站按钮
  Widget _buildTrashButton() {
    return GetBuilder<TrashController>(
      init: Get.isRegistered<TrashController>()
          ? Get.find<TrashController>()
          : TrashController(),
      builder: (trashCtrl) {
        return Obx(() {
          final deletedCount = trashCtrl.deletedTasks.length +
              trashCtrl.deletedWorkspaces.length;
          return badges.Badge(
            showBadge: deletedCount > 0,
            badgeContent: Text(
              deletedCount > 99 ? '99+' : deletedCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.orange,
              padding: EdgeInsets.all(4),
              elevation: 0,
            ),
            position: badges.BadgePosition.topEnd(top: -4, end: -4),
            child: NavBarBtn(
              onPressed: () {
                _showTrashDialog(Get.context!);
              },
              child: Builder(
                builder: (context) => Icon(
                  Icons.delete_outline,
                  size: 24,
                  color: context.theme.iconTheme.color,
                ),
              ),
            ),
          );
        });
      },
    );
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

  /// 显示回收站对话框
  void _showTrashDialog(BuildContext context) {
    PlatformDialogWrapper.show(
      tag: 'trash_dialog',
      content: const TrashDialog(),
      useSystem: false,
      debounce: true,
      keepSingle: true,
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 200),
      clickMaskDismiss: true,
    );
  }

  /// 显示通知中心对话框
  void _showNotificationCenter() {
    PlatformDialogWrapper.show(
      tag: 'notification_center_dialog',
      content: const NotificationCenterDialog(),
      useSystem: false,
      debounce: true,
      keepSingle: true,
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 200),
      clickMaskDismiss: true,
    );
  }

  /// 添加显示对话框的方法
  void _showTaskDialog(BuildContext context) {
    PlatformDialogWrapper.show(
      tag: addTaskDialogTag,
      content: const TaskDialog(dialogTag: addTaskDialogTag),
      useSystem: false,
      debounce: true,
      keepSingle: true,
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 150),
      clickMaskDismiss: false,
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

class _TaskHorizontalListState extends State<_TaskHorizontalList> {
  late final ScrollController _scrollController;
  Timer? _scrollTimer;
  final bool _isDragging = false;
  final Map<String, GlobalKey> _listKeys = {}; // 每列区域的 GlobalKey

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _syncListKeys();
  }

  @override
  void didUpdateWidget(_TaskHorizontalList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncListKeys();
  }

  void _syncListKeys() {
    // 为每个 task.uuid 维护一个 GlobalKey，用于命中检测
    final ids = widget.tasks.map((t) => t.uuid).toSet();
    // 添加缺失
    for (final id in ids) {
      _listKeys.putIfAbsent(id, () => GlobalKey());
    }
    // 移除已不存在的
    _listKeys.removeWhere((id, _) => !ids.contains(id));
  }

  bool _isPointerOverTaskCard(Offset globalPosition) {
    for (final key in _listKeys.values) {
      final renderObject = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderObject == null || !renderObject.attached) continue;
      final local = renderObject.globalToLocal(globalPosition);
      final size = renderObject.size;
      if (local.dx >= 0 &&
          local.dx <= size.width &&
          local.dy >= 0 &&
          local.dy <= size.height) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startEdgeScroll(double dx, double screenWidth) {
    _scrollTimer?.cancel();

    const scrollThreshold = 150;
    const scrollSpeed = 20.0;

    if (dx < scrollThreshold &&
        _scrollController.hasClients &&
        _scrollController.offset > 0) {
      // 接近左边缘，向左滚动
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (!mounted || !_isDragging) {
          _scrollTimer?.cancel();
          return;
        }
        final offset = _scrollController.offset - scrollSpeed;
        if (offset > 0) {
          _scrollController.jumpTo(offset);
        } else {
          _scrollController.jumpTo(0);
          _scrollTimer?.cancel();
        }
      });
    } else if (dx > screenWidth - scrollThreshold &&
        _scrollController.hasClients &&
        _scrollController.offset < _scrollController.position.maxScrollExtent) {
      // 接近右边缘，向右滚动
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (!mounted || !_isDragging) {
          _scrollTimer?.cancel();
          return;
        }
        final maxOffset = _scrollController.position.maxScrollExtent;
        final offset = _scrollController.offset + scrollSpeed;
        if (offset < maxOffset) {
          _scrollController.jumpTo(offset);
        } else {
          _scrollController.jumpTo(maxOffset);
          _scrollTimer?.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      // 处理鼠标滚轮事件
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final scrollDeltaX = pointerSignal.scrollDelta.dx;
          final scrollDeltaY = pointerSignal.scrollDelta.dy;

          // 检查鼠标是否在某个TaskCard上
          final isOverTaskCard = _isPointerOverTaskCard(pointerSignal.position);

          if (_scrollController.hasClients) {
            // 如果指针位于 TaskCard 内部，且垂直滚动占主导（|dy| >= |dx|），
            // 直接交给内部 todolist 处理，外层不消费该滚轮事件
            if (isOverTaskCard && scrollDeltaY.abs() >= scrollDeltaX.abs()) {
              return;
            }
            // 如果有横向滚动增量，优先处理横向滚动
            if (scrollDeltaX.abs() > 0) {
              final newOffset = _scrollController.offset + scrollDeltaX;
              _scrollController.animateTo(
                newOffset.clamp(
                  0.0,
                  _scrollController.position.maxScrollExtent,
                ),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
            }
            // 如果只有纵向滚动：
            // - 鼠标在 TaskCard 上：交给内部 todolist 处理（外层不处理）
            // - 鼠标不在 TaskCard 上：将纵向滚动转换为横向滚动，保证页面可横向浏览
            else if (scrollDeltaY != 0) {
              if (!isOverTaskCard) {
                final newOffset = _scrollController.offset + scrollDeltaY;
                _scrollController.animateTo(
                  newOffset.clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  ),
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
              } // 在 TaskCard 上由上面的早退逻辑处理
            }
          }
        }
      },
      onPointerMove: (event) {
        if (_isDragging) {
          final screenWidth = MediaQuery.of(context).size.width;
          _startEdgeScroll(event.position.dx, screenWidth);
        }
      },
      onPointerUp: (_) {
        _scrollTimer?.cancel();
      },
      child: Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 20, bottom: 20, right: 20),
        child: Align(
          alignment: Alignment.topLeft, // 使用 start-start 对齐（左上角）
          child: Obx(() {
            // 强制建立对 RxList 的依赖，避免 GetX 提示未使用可观察对象
            final _ = widget.tasks.length;
            // 使用 AppFlowyBoard 的拖拽逻辑，保持原 Task/Todo UI
            return AppFlowyTodosBoard(
              tasks: widget.tasks,
              listWidth: context.isPhone ? 0.9.sw : 270.0,
            );
          }),
        ),
      ),
    );
  }
}

/// 移动端Task横向列表组件，使用AppFlowyBoard布局，支持锚点吸附
class _TaskHorizontalListMobile extends StatefulWidget {
  final RxList<Task> tasks;

  const _TaskHorizontalListMobile({required this.tasks, super.key});

  @override
  State<_TaskHorizontalListMobile> createState() =>
      _TaskHorizontalListMobileState();
}

class _TaskHorizontalListMobileState extends State<_TaskHorizontalListMobile> {
  late final ScrollController _scrollController;
  Timer? _snapTimer;
  final Map<String, GlobalKey> _taskKeys = {};
  bool _isUserScrolling = false; // 标记用户是否正在主动滚动
  double _lastScrollOffset = 0.0; // 上次滚动位置
  DateTime _lastScrollTime = DateTime.now(); // 上次滚动时间

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // 为每个task创建GlobalKey
    for (final task in widget.tasks) {
      _taskKeys[task.uuid] = GlobalKey();
    }
    // 等待ScrollController attach后再添加滚动状态监听
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.position.isScrollingNotifier
            .addListener(_onScrollingStateChanged);
      }
    });
  }

  void _onScrollingStateChanged() {
    if (!_scrollController.hasClients) return;

    final isScrolling = _scrollController.position.isScrollingNotifier.value;
    if (isScrolling) {
      // 用户开始滚动
      _isUserScrolling = true;
      _snapTimer?.cancel(); // 取消锚点吸附
    } else {
      // 滚动停止，延迟执行锚点吸附
      _isUserScrolling = false;
      _snapTimer?.cancel();
      _snapTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted || !_scrollController.hasClients) return;
        if (!_isUserScrolling) {
          _snapToNearestTask();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_TaskHorizontalListMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 更新task keys
    final currentTaskIds = widget.tasks.map((t) => t.uuid).toSet();

    // 移除不存在的task keys
    _taskKeys.removeWhere((id, _) => !currentTaskIds.contains(id));

    // 添加新的task keys
    for (final task in widget.tasks) {
      if (!_taskKeys.containsKey(task.uuid)) {
        _taskKeys[task.uuid] = GlobalKey();
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // 检测滚动速度
    final now = DateTime.now();
    final timeDelta = now.difference(_lastScrollTime).inMilliseconds;
    final offsetDelta = (_scrollController.offset - _lastScrollOffset).abs();

    _lastScrollOffset = _scrollController.offset;
    _lastScrollTime = now;

    // 如果用户正在主动滚动（滚动速度较快），不执行锚点吸附
    if (timeDelta > 0 && offsetDelta / timeDelta > 0.5) {
      // 滚动速度较快，说明用户正在主动滚动
      _isUserScrolling = true;
      _snapTimer?.cancel();
      return;
    }

    // 如果用户没有主动滚动，才考虑执行锚点吸附
    // 但这里不立即执行，而是等待滚动停止（由_isScrollingNotifier处理）
  }

  /// 吸附到最近的task中心（使用GlobalKey实际测量位置）
  void _snapToNearestTask() {
    if (!_scrollController.hasClients || widget.tasks.isEmpty) return;
    
    // 安全检查：确保 maxScrollExtent 已经正确计算
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (maxScrollExtent <= 0) return; // 如果还没有正确计算，跳过吸附
    
    final scrollOffset = _scrollController.offset;
    
    // 边界检查：如果已经在边界附近，不进行吸附（避免回跳）
    const edgeThreshold = 20.0;
    if (scrollOffset <= edgeThreshold || 
        scrollOffset >= maxScrollExtent - edgeThreshold) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenCenterX = screenWidth / 2;

    // 找到最近的task索引（通过实际测量位置）
    double minDistance = double.infinity;
    int nearestIndex = 0;

    for (int i = 0; i < widget.tasks.length; i++) {
      final task = widget.tasks[i];
      final key = _taskKeys[task.uuid];

      if (key?.currentContext != null) {
        // 获取task的实际位置
        final RenderBox? renderBox =
            key?.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          // 获取task在屏幕上的全局位置
          final globalPosition = renderBox.localToGlobal(Offset.zero);
          // task中心在屏幕上的x坐标
          final taskCenterOnScreen =
              globalPosition.dx + renderBox.size.width / 2;

          // 计算距离屏幕中心的距离
          final distance = (taskCenterOnScreen - screenCenterX).abs();

          if (distance < minDistance) {
            minDistance = distance;
            nearestIndex = i;
          }
        }
      }
    }

    // 如果无法通过GlobalKey获取位置，回退到计算方式
    if (minDistance == double.infinity) {
      // 使用计算方式作为后备
      final listWidth = 0.9.sw;
      const groupMargin = 8.0;
      const outerPadding = 20.0;
      const firstTaskStart = outerPadding + groupMargin;
      final firstTaskCenter = firstTaskStart + listWidth / 2;
      final taskSpacing = listWidth + groupMargin * 2;
      // 在内容坐标系中，屏幕中心的绝对位置
      final screenCenterAbsolute = scrollOffset + screenCenterX;

      for (int i = 0; i < widget.tasks.length; i++) {
        final taskCenter = firstTaskCenter + i * taskSpacing;
        final distance = (screenCenterAbsolute - taskCenter).abs();

        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }

      // 计算目标滚动位置
      final targetTaskCenter = firstTaskCenter + nearestIndex * taskSpacing;
      final targetScrollOffset = targetTaskCenter - screenWidth / 2;

      _scrollController.animateTo(
        targetScrollOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    // 使用实际测量的位置来计算目标滚动位置
    final targetTask = widget.tasks[nearestIndex];
    final targetKey = _taskKeys[targetTask.uuid];

    if (targetKey?.currentContext != null) {
      final RenderBox? renderBox =
          targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        // 获取task在屏幕上的全局位置
        final globalPosition = renderBox.localToGlobal(Offset.zero);
        // task中心在屏幕上的x坐标
        final taskCenterOnScreen = globalPosition.dx + renderBox.size.width / 2;
        // 屏幕中心的x坐标
        final screenCenterX = screenWidth / 2;

        // 计算需要调整的滚动量：
        // 如果task在屏幕中心右边，需要向右滚动（增加offset）
        // 如果task在屏幕中心左边，需要向左滚动（减少offset）
        final adjustDelta = taskCenterOnScreen - screenCenterX;
        final targetScrollOffset = scrollOffset + adjustDelta;

        // 平滑滚动到目标位置
        _scrollController.animateTo(
          targetScrollOffset.clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _snapTimer?.cancel();
    if (_scrollController.hasClients) {
      _scrollController.position.isScrollingNotifier
          .removeListener(_onScrollingStateChanged);
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 强制建立对 RxList 的依赖
      final _ = widget.tasks.length;

      if (widget.tasks.isEmpty) {
        return Center(
          child: Text(
            "Do It Now !",
            style: GoogleFonts.getFont(
              'Ubuntu',
              textStyle: const TextStyle(
                fontSize: 60,
              ),
            ),
          ),
        );
      }

      // 使用和桌面端一样的AppFlowyTodosBoard，但传入自定义的ScrollController和task keys
      return Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 20, bottom: 20, right: 20),
        child: Align(
          alignment: Alignment.topLeft,
          child: _AppFlowyBoardWithSnap(
            tasks: widget.tasks,
            listWidth: 0.9.sw,
            scrollController: _scrollController,
            taskKeys: _taskKeys,
          ),
        ),
      );
    });
  }
}

/// 带吸附功能的AppFlowyBoard包装器
class _AppFlowyBoardWithSnap extends StatelessWidget {
  final RxList<Task> tasks;
  final double listWidth;
  final ScrollController scrollController;
  final Map<String, GlobalKey> taskKeys;

  const _AppFlowyBoardWithSnap({
    required this.tasks,
    required this.listWidth,
    required this.scrollController,
    required this.taskKeys,
  });

  @override
  Widget build(BuildContext context) {
    return AppFlowyTodosBoard(
      tasks: tasks,
      listWidth: listWidth,
      scrollController: scrollController,
      taskKeys: taskKeys,
    );
  }
}
