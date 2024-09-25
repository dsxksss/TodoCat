import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/settings/settings_ctr.dart';
import 'package:todo_cat/utils/dialog_keys.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:todo_cat/widgets/nav_bar.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:settings_ui/settings_ui.dart';

/// 设置页面类，继承自 GetView<SettingsController>
class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = _buildSettingsTheme(context);

    return Scaffold(
      body: TodoCatScaffold(
        title: "settings".tr,
        rightWidgets: [_buildThemeToggleButton(context)],
        body: _buildSettingsList(context, theme),
      ),
    );
  }

  /// 构建设置主题
  SettingsThemeData _buildSettingsTheme(BuildContext context) {
    return SettingsThemeData(
      settingsSectionBackground: context.theme.scaffoldBackgroundColor,
      settingsListBackground: context.theme.scaffoldBackgroundColor,
      dividerColor: context.theme.dividerColor,
    );
  }

  /// 构建主题切换按钮
  Widget _buildThemeToggleButton(BuildContext context) {
    return NavBarBtn(
      onPressed: () {
        controller.appCtrl.targetThemeMode();
        controller.isAnimating.value = true; // 启动动画
        // 动画结束后将 isAnimating 设为 false
        Future.delayed(const Duration(milliseconds: 400), () {
          controller.isAnimating.value = false;
        });
      },
      child: Obx(() {
        final isDarkMode = controller.appCtrl.appConfig.value.isDarkMode;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final fadeAnimation =
                Tween(begin: 0.0, end: 1.0).animate(animation);
            final rotationAnimation = Tween(begin: 0.0, end: 3 / 36).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
              ),
            );
            return FadeTransition(
              opacity: fadeAnimation,
              child: RotationTransition(
                turns: rotationAnimation,
                child: child,
              ),
            );
          },
          child: isDarkMode
              ? const Icon(Icons.nights_stay, key: ValueKey('moon'), size: 25)
              : const Icon(Icons.light_mode, key: ValueKey('sun'), size: 25),
        );
      }),
    );
  }

  /// 构建设置列表
  Widget _buildSettingsList(BuildContext context, SettingsThemeData theme) {
    return Obx(
      () => SettingsList(
        lightTheme: theme,
        darkTheme: theme,
        physics: const AlwaysScrollableScrollPhysics(
          // 当内容不足时也可以启动反弹刷新
          parent: BouncingScrollPhysics(),
        ),
        sections: [
          SettingsSection(
            title: Text('common'.tr),
            tiles: _buildSettingsTiles(context),
          ),
        ],
      ),
    );
  }

  /// 构建设置项
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
        onPressed: (context) => _showLanguageMenu(context),
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

  /// 显示语言选择菜单
  void _showLanguageMenu(BuildContext context) {
    showDpdMenu(
      tag: settingsDropDownMenuBtnTag,
      targetContext: context,
      menuItems: [
        MenuItem(
          title: "English",
          callback: () {
            controller.changeLanguage(const Locale("en", "US"));
          },
        ),
        MenuItem(
          title: "中文简体",
          callback: () {
            controller.changeLanguage(const Locale("zh", "CN"));
          },
        ),
      ],
    );
  }

  /// 显示重置设置的提示
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
