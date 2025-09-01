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
                color: Colors.black.withValues(alpha: 0.05),
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
                style: Theme.of(context).textTheme.titleLarge,
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
      SettingsTile(
        onPressed: (_) => _showResetSettingsToast(),
        leading: const Icon(Icons.restart_alt_rounded),
        title: Text('resetSettings'.tr),
      ),
      SettingsTile(
        onPressed: (_) => _showResetTasksTemplateToast(),
        leading: const Icon(Icons.featured_play_list_outlined),
        title: Text('resetTasksTemplate'.tr),
      ),
      SettingsTile.switchTile(
        onToggle: (_) => controller.targetEmailReminder(),
        onPressed: (_) => controller.targetEmailReminder(),
        initialValue: controller.appCtrl.appConfig.value.emailReminderEnabled,
        leading: const Icon(Icons.mark_email_unread_outlined),
        title: Text('emailReminder'.tr),
      ),
      SettingsTile.switchTile(
        onToggle: (_) => controller.targetDebugMode(),
        onPressed: (_) => controller.targetDebugMode(),
        initialValue: controller.appCtrl.appConfig.value.isDebugMode,
        leading: const Icon(Icons.bug_report_outlined),
        title: Text('enbleDebugMode'.tr),
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

  void _showResetTasksTemplateToast() {
    showToast(
      "areYouSureResetTasksTemplate".tr,
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.warning,
      onYesCallback: () {
        controller.resetTasksTemplate();
        showSuccessNotification("tasksTemplateResetSuccess".tr);
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
            return Text('dataPreview'.trParams({
              'tasksCount': preview['tasksCount'].toString(),
              'todosCount': preview['todosCount'].toString(),
            }));
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
