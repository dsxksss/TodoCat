import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/controllers/data_export_import_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/background_setting_dialog.dart';
import 'package:todo_cat/widgets/data_import_export_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/keys/dialog_keys.dart';

class SettingsContent extends GetView<SettingsController> {
  const SettingsContent({super.key});

  // 获取数据导出导入控制器
  DataExportImportController get dataController =>
      Get.find<DataExportImportController>();

  @override
  Widget build(BuildContext context) {
    final theme = _buildSettingsTheme(context);

    return Column(
      children: [
        // 标题栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'settings'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'SourceHanSans',
                        ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'v${controller.appVersion.value}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ],
              ),
              IconButton(
                icon: Obx(() {
                  final isDarkMode =
                      controller.appCtrl.appConfig.value.isDarkMode;
                  return Icon(
                    isDarkMode ? Icons.nights_stay : Icons.light_mode,
                    size: 24,
                    color: Theme.of(context).iconTheme.color,
                  );
                }),
                onPressed: () {
                  controller.appCtrl.targetThemeMode();
                  controller.isAnimating.value = true;
                  0.4.delay(() => controller.isAnimating.value = false);
                },
              ),
            ],
          ),
        ),
        // 设置列表
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // 当检测到任何滚动事件时，关闭所有下拉菜单
              if (notification is ScrollUpdateNotification ||
                  notification is ScrollStartNotification) {
                // 关闭所有可能的下拉菜单
                SmartDialog.dismiss(tag: dropDownMenuBtnTag);
                SmartDialog.dismiss(tag: settingsDropDownMenuBtnTag);
              }
              return false; // 允许通知继续传播
            },
            child: Obx(
              () => SettingsList(
                lightTheme: theme,
                darkTheme: theme,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                sections: [
                  SettingsSection(
                    title: Text('common'.tr),
                    tiles: _buildSettingsTiles(context),
                  ),
                  SettingsSection(
                    title: Text('dataManagement'.tr),
                    tiles: _buildDataManagementTiles(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  SettingsThemeData _buildSettingsTheme(BuildContext context) {
    return SettingsThemeData(
      settingsSectionBackground: context.theme.scaffoldBackgroundColor,
      settingsListBackground: context.theme.scaffoldBackgroundColor,
      dividerColor: context.theme.dividerColor,
      tileHighlightColor: context.theme.hoverColor,
    );
  }

  List<SettingsTile> _buildSettingsTiles(BuildContext context) {
    return [
      SettingsTile.navigation(
        leading: const Icon(Icons.g_translate_rounded),
        title: Text('language'.tr),
        trailing: Row(
          children: [
            Obx(() => Text(controller.currentLanguage.value)),
            const Icon(Icons.arrow_drop_down_rounded)
          ],
        ),
        onPressed: (context) => controller.showLanguageMenu(context),
      ),
      // 检查更新（仅桌面端显示）
      if (GetPlatform.isDesktop)
        SettingsTile(
          onPressed: (_) {
            // 下载中时禁用点击，只能通过关闭按钮取消
            if (controller.isDownloading.value) {
              return; // 下载中时，点击无效
            }
            controller.checkForUpdates(); // 未下载时，点击为检查更新
          },
          leading: const Icon(Icons.system_update), // 下载中时图标保持不变
          title: Obx(() => Text(
                controller.isDownloading.value
                    ? 'downloadingUpdate'.tr
                    : 'checkForUpdates'.tr,
              )),
          description: Obx(() {
            final status = controller.updateStatus.value;
            if (status.isNotEmpty) {
              return Text(status);
            }
            if (controller.isDownloading.value) {
              return Text('downloadingUpdate'.tr);
            }
            return Text('checkForUpdatesDescription'.tr);
          }),
          trailing: Obx(() {
            final progress = controller.updateProgress.value;
            final isDownloading = controller.isDownloading.value;

            // 正在下载时，显示取消按钮或进度（参考 undo 的倒计时样式）
            if (isDownloading && progress > 0.0 && progress < 1.0) {
              final theme = Get.theme;
              final isDark = theme.brightness == Brightness.dark;
              const progressColor = Colors.blueAccent;
              final backgroundColor =
                  isDark ? Colors.grey.shade800 : Colors.grey.shade200;
              final progressBgColor =
                  isDark ? Colors.grey.shade700 : Colors.grey.shade300;
              final percentage = (progress * 100).toInt();

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 圆形进度条，中间显示百分比（参考 CountdownCircleProgress 样式）
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundColor,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 圆圈进度条
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: progress,
                            ),
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                            builder: (context, animatedProgress, child) {
                              return CircularProgressIndicator(
                                value: animatedProgress,
                                strokeWidth: 2.5,
                                backgroundColor: progressBgColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    progressColor),
                              );
                            },
                          ),
                        ),
                        // 百分比数字显示在中心
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => controller.cancelUpdate(),
                    tooltip: 'cancelUpdate'.tr,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              );
            }

            // 未开始或已完成/错误（已重置）
            if (progress == 0.0) {
              return const Icon(Icons.chevron_right);
            }

            // 完成（progress == 1.0）
            if (progress == 1.0) {
              return const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              );
            }

            // 错误（progress == -1.0）
            if (progress == -1.0) {
              return const Icon(
                Icons.error,
                color: Colors.red,
                size: 20,
              );
            }

            return const Icon(Icons.chevron_right);
          }),
        ),
      // 重置设置选项移到数据管理部分
      SettingsTile(
        onPressed: (_) => controller.resetTasksTemplate(),
        leading: const Icon(Icons.featured_play_list_outlined),
        title: Text('tasksTemplate'.tr),
      ),
      // 保存当前任务为模板
      SettingsTile(
        onPressed: (_) {
          final homeController = Get.find<HomeController>();
          homeController.saveAsTemplate();
        },
        leading: const Icon(Icons.save_alt),
        title: Text('saveCurrentAsTemplate'.tr),
        description: Text('saveCurrentAsTemplateDescription'.tr),
      ),
      // 背景设置
      SettingsTile(
        onPressed: (_) => _showBackgroundImageDialog(),
        leading: const Icon(Icons.image_outlined),
        title: Text('backgroundSetting'.tr),
        description: Obx(() {
          final hasBackground =
              controller.appCtrl.appConfig.value.backgroundImagePath != null &&
                  GetPlatform.isDesktop &&
                  controller
                      .appCtrl.appConfig.value.backgroundImagePath!.isNotEmpty;
          return Text(hasBackground
              ? 'backgroundImageSet'.tr
              : 'backgroundImageNotSet'.tr);
        }),
      ),
      SettingsTile.switchTile(
        onToggle: (_) {
          // 禁用功能，显示开发中提示
          showToast(
            "featureInDevelopment".tr,
            toastStyleType: TodoCatToastStyleType.warning,
          );
        },
        onPressed: (_) {
          // 禁用功能，显示开发中提示
          showToast(
            "featureInDevelopment".tr,
            toastStyleType: TodoCatToastStyleType.warning,
          );
        },
        initialValue: false, // 强制设为false，禁用状态
        leading: Tooltip(
          message: "featureInDevelopment".tr,
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: Colors.grey, // 灰色表示禁用状态
          ),
        ),
        title: Tooltip(
          message: "featureInDevelopment".tr,
          child: Text(
            'emailReminder'.tr,
            style: const TextStyle(
              color: Colors.grey, // 灰色表示禁用状态
            ),
          ),
        ),
      ),
      // 显示 Todo 图片封面开关
      SettingsTile.switchTile(
        onToggle: (_) => controller.toggleShowTodoImage(),
        onPressed: (_) => controller.toggleShowTodoImage(),
        initialValue: controller.showTodoImageEnabled.value,
        leading: const Icon(Icons.image_outlined),
        title: Text('showTodoImage'.tr),
        description: Text('showTodoImageDescription'.tr),
      ),
      // 开机自启动开关（仅桌面端）
      if (GetPlatform.isDesktop)
        SettingsTile.switchTile(
          onToggle: (_) => controller.toggleLaunchAtStartup(),
          onPressed: (_) => controller.toggleLaunchAtStartup(),
          initialValue: controller.launchAtStartupEnabled.value,
          leading: const Icon(Icons.power_settings_new),
          title: Text('launchAtStartup'.tr),
          description: Text('launchAtStartupDescription'.tr),
        ),
    ];
  }

  void _showResetSettingsToast() {
    showToast(
      'confirmResetSettings'.tr,
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.warning,
      onYesCallback: () {
        controller.resetConfig();
        showSuccessNotification('settingsResetSuccess'.tr);
      },
    );
  }

  /// 构建数据管理的设置项
  List<SettingsTile> _buildDataManagementTiles(BuildContext context) {
    return [
      // 数据导入导出（合并为一个选项）
      SettingsTile(
        leading: const Icon(Icons.import_export),
        title: Text('dataImportExport'.tr),
        description: Text('dataImportExportDescription'.tr),
        trailing: const Icon(Icons.chevron_right),
        onPressed: (_) => _showDataImportExportDialog(),
      ),
      // 重置设置（红色，放在清除所有数据上面）
      SettingsTile(
        leading: const Icon(Icons.restart_alt_rounded, color: Colors.red),
        title:
            Text('resetSettings'.tr, style: const TextStyle(color: Colors.red)),
        description: Text('resetSettingsDescription'.tr),
        onPressed: (_) => _showResetSettingsToast(),
      ),
      // 清除所有数据
      SettingsTile(
        leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
        title:
            Text('clearAllData'.tr, style: const TextStyle(color: Colors.red)),
        description: Text('clearAllDataDescription'.tr),
        onPressed: (_) => _showClearAllDataDialog(),
      ),
    ];
  }

  /// 显示数据导入导出对话框
  void _showDataImportExportDialog() {
    SmartDialog.show(
      tag: 'data_import_export_dialog',
      alignment: Alignment.center,
      maskColor: Colors.black.withValues(alpha: 0.3),
      clickMaskDismiss: true,
      useAnimation: true,
      animationTime: const Duration(milliseconds: 200),
      builder: (_) => const DataImportExportDialog(),
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

  /// 显示背景图片对话框
  void _showBackgroundImageDialog() {
    final context = Get.context!;

    SmartDialog.show(
      tag: 'background_setting_dialog',
      alignment: context.isPhone ? Alignment.bottomCenter : Alignment.center,
      maskColor: Colors.black.withValues(alpha: 0.3),
      clickMaskDismiss: true,
      useAnimation: true,
      animationTime: const Duration(milliseconds: 200),
      builder: (_) => context.isPhone
          ? const Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: BackgroundSettingDialog(),
              ),
            )
          : const BackgroundSettingDialog(),
      animationBuilder: (controller, child, _) {
        if (context.isPhone) {
          // 移动端：从底部滑入
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: controller,
              child: child,
            ),
          );
        } else {
          // 桌面端：缩放和淡入
          return child
              .animate(controller: controller)
              .fade(duration: controller.duration)
              .scaleXY(
                begin: 0.95,
                duration: controller.duration,
                curve: Curves.easeOut,
              );
        }
      },
    );
  }

  /// 显示清除所有数据确认对话框
  void _showClearAllDataDialog() {
    showToast(
      'confirmClearAllData'.tr,
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        // 显示加载提示
        SmartDialog.showLoading(msg: 'clearingData'.tr);

        try {
          final success = await controller.clearAllData();
          SmartDialog.dismiss();

          if (success) {
            showSuccessNotification('clearAllDataSuccess'.tr);
            // 关闭设置页面
            SmartDialog.dismiss(tag: 'settings');
          } else {
            showErrorNotification('clearAllDataFailed'.tr);
          }
        } catch (e) {
          SmartDialog.dismiss();
          showErrorNotification('clearAllDataFailed'.tr);
        }
      },
    );
  }
}
