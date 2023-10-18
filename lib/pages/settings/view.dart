import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/widgets/nav_bar.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends GetView<HomeController> {
  const SettingsPage({super.key});

  @override
  Widget build(context) {
    final theme = SettingsThemeData(
      settingsSectionBackground: context.theme.scaffoldBackgroundColor,
      settingsListBackground: context.theme.scaffoldBackgroundColor,
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
          ),
          SizedBox(
            width: context.isPhone ? 10 : 20,
          ),
          NavBarBtn(
            onPressed: () => {
              controller.appCtrl.changeLanguage(
                Get.locale == const Locale("zh", "CN")
                    ? const Locale("en", "US")
                    : const Locale("zh", "CN"),
              )
            },
            child: const Icon(
              Icons.g_translate,
              size: 22,
            ),
          ),
        ],
        body: SettingsList(
          platform: DevicePlatform.windows,
          lightTheme: theme,
          darkTheme: theme,
          physics: const AlwaysScrollableScrollPhysics(
            //当内容不足时也可以启动反弹刷新
            parent: BouncingScrollPhysics(),
          ),
          sections: [
            SettingsSection(
              title: Text('Common'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  value: Text('English'),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {},
                  initialValue: true,
                  leading: Icon(Icons.format_paint),
                  title: Text('Enable custom theme'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
