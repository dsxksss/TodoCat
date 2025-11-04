import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:TodoCat/controllers/settings_ctr.dart';
import 'package:TodoCat/controllers/data_export_import_ctr.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:TodoCat/widgets/background_setting_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class SettingsContent extends GetView<SettingsController> {
  const SettingsContent({super.key});

  // 获取数据导出导入控制器
  DataExportImportController get dataController => Get.find<DataExportImportController>();

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
                color: Colors.black.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings'.tr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'SourceHanSans',
                ),
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
          onPressed: (_) => controller.checkForUpdates(),
          leading: const Icon(Icons.system_update),
          title: Text('checkForUpdates'.tr),
          description: Text('checkForUpdatesDescription'.tr),
        ),
      SettingsTile(
        onPressed: (_) => _showResetSettingsToast(),
        leading: const Icon(Icons.restart_alt_rounded),
        title: Text('resetSettings'.tr),
      ),
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
      // 背景图片设置
      SettingsTile(
        onPressed: (_) => _showBackgroundImageDialog(),
        leading: const Icon(Icons.image_outlined),
        title: Text('backgroundImage'.tr),
        description: Obx(() {
          final hasBackground = controller.appCtrl.appConfig.value.backgroundImagePath != null &&
              GetPlatform.isDesktop &&
              controller.appCtrl.appConfig.value.backgroundImagePath!.isNotEmpty;
          return Text(hasBackground ? 'backgroundImageSet'.tr : 'backgroundImageNotSet'.tr);
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
      // 开机自启动开关（仅桌面端）
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
      // 导出数据
      SettingsTile(
        leading: const Icon(Icons.upload_rounded),
        title: Text('exportData'.tr),
        description: Obx(() {
          final preview = dataController.exportPreview.value;
          if (preview != null) {
            return Text('${'tasks'.tr}: ${preview['tasksCount']}, Todo: ${preview['todosCount']}');
          }
          return Text('exportDataDescription'.tr);
        }),
        trailing: Obx(() {
          if (dataController.isExporting.value) {
            return const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          return const Icon(Icons.chevron_right);
        }),
        onPressed: (_) => _handleExportData(),
      ),
      // 导入数据
      SettingsTile(
        leading: const Icon(Icons.download_rounded),
        title: Text('importData'.tr),
        description: Text('importDataDescription'.tr),
        trailing: Obx(() {
          if (dataController.isImporting.value) {
            return const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          return const Icon(Icons.chevron_right);
        }),
        onPressed: (_) => _handleImportData(),
      ),
      // 清除所有数据
      SettingsTile(
        leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
        title: Text('clearAllData'.tr, style: const TextStyle(color: Colors.red)),
        description: Text('clearAllDataDescription'.tr),
        onPressed: (_) => _showClearAllDataDialog(),
      ),
    ];
  }

  /// 处理导出数据
  void _handleExportData() async {
    if (!dataController.isExporting.value) {
      await dataController.exportData();
    }
  }

  /// 处理导入数据
  void _handleImportData() async {
    if (!dataController.isImporting.value) {
      await dataController.importData();
    }
  }

  /// 显示背景图片对话框
  void _showBackgroundImageDialog() {
    if (!GetPlatform.isDesktop) {
      showToast('desktopOnlyFeature'.tr);
      return;
    }
    
    SmartDialog.show(
      tag: 'background_setting_dialog',
      alignment: Alignment.center,
      maskColor: Colors.black.withOpacity(0.3),
      clickMaskDismiss: true,
      useAnimation: true,
      animationTime: const Duration(milliseconds: 200),
      builder: (_) => const BackgroundSettingDialog(),
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
