import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/widgets/show_toast.dart';

class SettingsContent extends GetView<SettingsController> {
  const SettingsContent({super.key});

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
                color: Colors.black.withOpacity(0.05),
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
        showToast("设置已重置", toastStyleType: TodoCatToastStyleType.success);
      },
    );
  }
}
