import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/background_setting_dialog.dart';
import 'package:todo_cat/widgets/data_import_export_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/platform_dialog_wrapper.dart';
import 'package:todo_cat/widgets/sync_config_dialog.dart';
import 'package:todo_cat/widgets/ai_config_dialog.dart';
import 'package:todo_cat/services/ai_settings_service.dart';

import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/platform.dart';
import 'package:todo_cat/core/utils/responsive.dart';

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = _buildSettingsTheme(context);
    final appVersion = ref.watch(
        settingsControllerProvider.select((s) => s.appVersion));

    return Column(
      children: [
        // 标题栏
        GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onTapCancel: () {
            if (AppPlatform.isDesktop) {
              windowManager.startDragging();
            }
          },
          child: Container(
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
                      l10n.settings,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'SourceHanSans',
                          ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'v$appVersion',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Consumer(builder: (context, ref, _) {
                    final isDarkMode =
                        ref.watch(appControllerProvider).isDarkMode;
                    return Icon(
                      isDarkMode ? Icons.nights_stay : Icons.light_mode,
                      size: 24,
                      color: Theme.of(context).iconTheme.color,
                    );
                  }),
                  onPressed: () {
                    ref.read(appControllerProvider.notifier).targetThemeMode();
                  },
                ),
              ],
            ),
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
            child: SettingsList(
              lightTheme: theme,
              darkTheme: theme,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              sections: [
                SettingsSection(
                  title: Text(l10n.common),
                  tiles: _buildSettingsTiles(context, ref),
                ),
                SettingsSection(
                  title: Text(l10n.dataManagement),
                  tiles: _buildDataManagementTiles(context, ref),
                ),
              ],
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

  List<SettingsTile> _buildSettingsTiles(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return [
      SettingsTile.navigation(
        leading: const Icon(Icons.g_translate_rounded),
        title: Text(l10n.language),
        trailing: Row(
          children: [
            Text(settings.currentLanguage),
            const Icon(Icons.arrow_drop_down_rounded)
          ],
        ),
        onPressed: (context) => controller.showLanguageMenu(context),
      ),
      // 检查更新（仅桌面端显示）
      if (AppPlatform.isDesktop)
        SettingsTile(
          onPressed: (_) {
            // 下载中时禁用点击，只能通过关闭按钮取消
            if (settings.isDownloading) {
              return; // 下载中时，点击无效
            }
            controller.checkForUpdates(); // 未下载时，点击为检查更新
          },
          leading: const Icon(Icons.system_update), // 下载中时图标保持不变
          title: Text(
            settings.isDownloading
                ? l10n.downloadingUpdate
                : l10n.checkForUpdates,
          ),
          description: Builder(builder: (context) {
            final status = settings.updateStatus;
            if (status.isNotEmpty) {
              return Text(status);
            }
            if (settings.isDownloading) {
              return Text(l10n.downloadingUpdate);
            }
            return Text(l10n.checkForUpdatesDescription);
          }),
          trailing: Builder(builder: (context) {
            final progress = settings.updateProgress;
            final isDownloading = settings.isDownloading;

            // 正在下载时，显示取消按钮或进度（参考 undo 的倒计时样式）
            if (isDownloading && progress > 0.0 && progress < 1.0) {
              final theme = context.theme;
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
                    tooltip: l10n.cancelUpdate,
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
        title: Text(l10n.tasksTemplate),
      ),
      // 保存当前任务为模板
      SettingsTile(
        onPressed: (_) {
          ref.read(homeControllerProvider.notifier).saveAsTemplate();
        },
        leading: const Icon(Icons.save_alt),
        title: Text(l10n.saveCurrentAsTemplate),
        description: Text(l10n.saveCurrentAsTemplateDescription),
      ),
      // AI 配置（DeepSeek API Key 等）
      SettingsTile(
        onPressed: (_) => _showAiConfigDialog(),
        leading: const Icon(Icons.smart_toy_outlined),
        title: Text(l10n.aiConfiguration),
        description: Text(l10n.aiConfigurationDescription),
        trailing: Builder(builder: (context) {
          final configured = AiSettingsService.to.isConfigured;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                configured ? l10n.aiConfigured : l10n.aiNotConfigured,
                style: TextStyle(
                  fontSize: 12,
                  color: configured ? Colors.green : Colors.orange,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          );
        }),
      ),
      // 背景设置
      SettingsTile(
        onPressed: (_) => _showBackgroundImageDialog(),
        leading: const Icon(Icons.image_outlined),
        title: Text(l10n.backgroundSetting),
        description: Consumer(builder: (context, ref, _) {
          final backgroundImagePath =
              ref.watch(appControllerProvider).backgroundImagePath;
          final hasBackground = backgroundImagePath != null &&
              AppPlatform.isDesktop &&
              backgroundImagePath.isNotEmpty;
          return Text(hasBackground
              ? l10n.backgroundImageSet
              : l10n.backgroundImageNotSet);
        }),
      ),
      SettingsTile.switchTile(
        onToggle: (_) {
          // 禁用功能，显示开发中提示
          showToast(
            l10n.featureInDevelopment,
            toastStyleType: TodoCatToastStyleType.warning,
          );
        },
        onPressed: (_) {
          // 禁用功能，显示开发中提示
          showToast(
            l10n.featureInDevelopment,
            toastStyleType: TodoCatToastStyleType.warning,
          );
        },
        initialValue: false, // 强制设为false，禁用状态
        leading: Tooltip(
          message: l10n.featureInDevelopment,
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: Colors.grey, // 灰色表示禁用状态
          ),
        ),
        title: Tooltip(
          message: l10n.featureInDevelopment,
          child: Text(
            l10n.emailReminder,
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
        initialValue: settings.showTodoImageEnabled,
        leading: const Icon(Icons.image_outlined),
        title: Text(l10n.showTodoImage),
        description: Text(l10n.showTodoImageDescription),
      ),
      // 开机自启动开关（仅桌面端）
      if (AppPlatform.isDesktop)
        SettingsTile.switchTile(
          onToggle: (_) => controller.toggleLaunchAtStartup(),
          onPressed: (_) => controller.toggleLaunchAtStartup(),
          initialValue: settings.launchAtStartupEnabled,
          leading: const Icon(Icons.power_settings_new),
          title: Text(l10n.launchAtStartup),
          description: Text(l10n.launchAtStartupDescription),
        ),
    ];
  }

  void _showResetSettingsToast(WidgetRef ref) {
    showToast(
      l10n.confirmResetSettings,
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.warning,
      onYesCallback: () {
        ref.read(settingsControllerProvider.notifier).resetConfig();
        showSuccessNotification(l10n.settingsResetSuccess);
      },
    );
  }

  /// 构建数据管理的设置项
  List<SettingsTile> _buildDataManagementTiles(
      BuildContext context, WidgetRef ref) {
    return [
      // 数据导入导出（合并为一个选项）
      SettingsTile(
        leading: const Icon(Icons.cloud_sync_outlined),
        title: Text(l10n.syncConfiguration),
        description: Text(l10n.syncConfigurationDescription),
        trailing: const Icon(Icons.chevron_right),
        onPressed: (_) => _showSyncConfigDialog(),
      ),
      // 数据导入导出（合并为一个选项）
      SettingsTile(
        leading: const Icon(Icons.import_export),
        title: Text(l10n.dataImportExport),
        description: Text(l10n.dataImportExportDescription),
        trailing: const Icon(Icons.chevron_right),
        onPressed: (_) => _showDataImportExportDialog(),
      ),
      // 重置设置（红色，放在清除所有数据上面）
      SettingsTile(
        leading: const Icon(Icons.restart_alt_rounded, color: Colors.red),
        title:
            Text(l10n.resetSettings, style: const TextStyle(color: Colors.red)),
        description: Text(l10n.resetSettingsDescription),
        onPressed: (_) => _showResetSettingsToast(ref),
      ),
      // 清除所有数据
      SettingsTile(
        leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
        title:
            Text(l10n.clearAllData, style: const TextStyle(color: Colors.red)),
        description: Text(l10n.clearAllDataDescription),
        onPressed: (_) => _showClearAllDataDialog(ref),
      ),
    ];
  }

  /// 显示同步配置对话框
  void _showSyncConfigDialog() {
    PlatformDialogWrapper.show(
      tag: 'sync_config_dialog',
      content: const SyncConfigDialog(),
      width: 500,
      height: 600,
      clickMaskDismiss: true,
    );
  }

  /// 显示 AI 配置对话框
  void _showAiConfigDialog() {
    PlatformDialogWrapper.show(
      tag: AiConfigDialog.tag,
      content: const AiConfigDialog(),
      width: 500,
      height: 620,
      clickMaskDismiss: true,
    );
  }

  /// 显示数据导入导出对话框
  void _showDataImportExportDialog() {
    PlatformDialogWrapper.show(
      tag: 'data_import_export_dialog',
      content: const DataImportExportDialog(),
      width: 400,
      height: 300, // 适应内容高度
      clickMaskDismiss: true,
      useFixedSize: false, // 让内容自适应大小
    );
  }

  /// 显示背景图片对话框
  void _showBackgroundImageDialog() {
    PlatformDialogWrapper.show(
      tag: 'background_setting_dialog',
      content: const BackgroundSettingDialog(),
      width: 500,
      height: 700,
      clickMaskDismiss: true,
    );
  }

  /// 显示清除所有数据确认对话框
  void _showClearAllDataDialog(WidgetRef ref) {
    showToast(
      l10n.confirmClearAllData,
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        // 显示加载提示
        SmartDialog.showLoading(msg: l10n.clearingData);

        try {
          final success =
              await ref.read(settingsControllerProvider.notifier).clearAllData();
          SmartDialog.dismiss();

          if (success) {
            showSuccessNotification(l10n.clearAllDataSuccess);
            // 关闭设置页面
            SmartDialog.dismiss(tag: 'settings');
          } else {
            showErrorNotification(l10n.clearAllDataFailed);
          }
        } catch (e) {
          SmartDialog.dismiss();
          showErrorNotification(l10n.clearAllDataFailed);
        }
      },
    );
  }
}
