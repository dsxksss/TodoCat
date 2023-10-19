import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/settings/controller.dart';
import 'package:todo_cat/utils/dialog_keys.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:todo_cat/widgets/nav_bar.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(context) {
    final theme = SettingsThemeData(
      settingsSectionBackground: context.theme.scaffoldBackgroundColor,
      settingsListBackground: context.theme.scaffoldBackgroundColor,
      dividerColor: context.theme.dividerColor,
    );
    return Scaffold(
      body: TodoCatScaffold(
          title: "settings".tr,
          rightWidgets: [
            NavBarBtn(
              onPressed: () => controller.appCtrl.targetThemeMode(),
              child: const Icon(
                Icons.nights_stay,
                size: 25,
              )
                  .animate(
                      target:
                          controller.appCtrl.appConfig.value.isDarkMode ? 1 : 0)
                  .fadeOut(duration: 200.ms)
                  .rotate(end: 0.1, duration: 200.ms)
                  .swap(
                    builder: (_, __) => const Icon(
                      Icons.light_mode,
                      size: 25,
                    )
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .rotate(end: 0.1, duration: 200.ms),
                  ),
            )
          ],
          body: Obx(
            () => SettingsList(
              lightTheme: theme,
              darkTheme: theme,
              physics: const AlwaysScrollableScrollPhysics(
                //当内容不足时也可以启动反弹刷新
                parent: BouncingScrollPhysics(),
              ),
              sections: [
                SettingsSection(
                  title: Text('common'.tr),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.g_translate_rounded),
                      title: Text('language'.tr),
                      trailing: Row(
                        children: [
                          Obx(() => Text(controller.currentLanguage.value)),
                          const Icon(Icons.arrow_drop_down_rounded)
                        ],
                      ),
                      onPressed: (context) {
                        showDpdMenu(
                          tag: settingsDropDownMenuBtnTag,
                          targetContext: context,
                          menuItems: [
                            MenuItem(
                              title: "English",
                              callback: () {
                                controller
                                    .changeLanguage(const Locale("en", "US"));
                              },
                            ),
                            MenuItem(
                              title: "中文简体",
                              callback: () {
                                controller
                                    .changeLanguage(const Locale("zh", "CN"));
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) => controller.targetEmailReminder(),
                      onPressed: (context) => controller.targetEmailReminder(),
                      initialValue: controller
                          .appCtrl.appConfig.value.emailReminderEnabled,
                      leading: const Icon(Icons.mark_email_unread_outlined),
                      title: Text('emailReminder'.tr),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
