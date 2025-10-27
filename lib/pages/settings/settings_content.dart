import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/controllers/data_export_import_ctr.dart';
import 'package:todo_cat/widgets/show_toast.dart';

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
        title: Text('resetTasksTemplate'.tr),
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
      "确定要重置设置吗?",
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.warning,
      onYesCallback: () {
        controller.resetConfig();
        showSuccessNotification("设置已重置");
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
            return Text('任务: ${preview['tasksCount']}, Todo: ${preview['todosCount']}');
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
}
