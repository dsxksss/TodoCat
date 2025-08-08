import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/task_manager.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/settings/settings_page.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';

class SettingsController extends GetxController {
  final AppController appCtrl = Get.find();
  final HomeController homeCtrl = Get.find();
  late final Rx<String> currentLanguage;
  var isAnimating = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 监听语言变化
    ever(appCtrl.appConfig, (_) {
      currentLanguage.value = _getLanguageTitle(
        appCtrl.appConfig.value.locale.languageCode,
      );
    });

    currentLanguage = _getLanguageTitle(
      appCtrl.appConfig.value.locale.languageCode,
    ).obs;
  }

  String _getLanguageTitle(String locale) {
    switch (locale) {
      case "en":
        return "English";
      case "zh":
        return "中文";
      default:
        return "unknown";
    }
  }

  void showSettings() {
    if (Get.context!.isPhone) {
      SmartDialog.show(
        tag: 'settings',
        alignment: Alignment.bottomCenter,
        maskColor: Colors.black38,
        clickMaskDismiss: true,
        useAnimation: true,
        animationTime: const Duration(milliseconds: 200),
        builder: (_) => Container(
          width: Get.width,
          height: Get.height * 0.6,
          margin: EdgeInsets.only(
            top: MediaQuery.of(Get.context!).padding.top + 20,
          ),
          decoration: BoxDecoration(
            color: Get.theme.dialogBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: SettingsPage(),
          ),
        ),
        animationBuilder: (controller, child, animationParam) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      );
    } else {
      // 桌面端保持原来的右侧滑入
      SmartDialog.show(
        tag: 'settings',
        alignment: Alignment.centerRight,
        builder: (_) => const SettingsPage(),
        maskColor: Colors.black38,
        clickMaskDismiss: true,
        animationBuilder: (controller, child, animationParam) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      );
    }
  }

  void showLanguageMenu(BuildContext context) {
    final currentLocale = appCtrl.appConfig.value.locale.languageCode;

    showDpdMenu(
      tag: settingsDropDownMenuBtnTag,
      targetContext: context,
      menuItems: [
        MenuItem(
          title: "English",
          callback: () => changeLanguage(const Locale("en", "US")),
          isDisabled: currentLocale == "en",
        ),
        MenuItem(
          title: "中文简体",
          callback: () => changeLanguage(const Locale("zh", "CN")),
          isDisabled: currentLocale == "zh",
        ),
      ],
    );
  }

  Future<void> changeLanguage(Locale local) async {
    // 先更新系统语言
    await Get.updateLocale(local);
    // 更新配置
    appCtrl.appConfig.value = appCtrl.appConfig.value.copyWith(locale: local);
    appCtrl.appConfig.refresh();

    // 关闭语言选择菜单
    SmartDialog.dismiss(tag: settingsDropDownMenuBtnTag);
  }

  void targetEmailReminder() {
    final newConfig = appCtrl.appConfig.value.copyWith(
      emailReminderEnabled: !appCtrl.appConfig.value.emailReminderEnabled,
    );
    appCtrl.appConfig.value = newConfig;
    appCtrl.appConfig.refresh();
  }

  void targetDebugMode() {
    final newConfig = appCtrl.appConfig.value.copyWith(
      isDebugMode: !appCtrl.appConfig.value.isDebugMode,
    );
    appCtrl.appConfig.value = newConfig;
    appCtrl.appConfig.refresh();
  }

  void resetConfig() {
    appCtrl.appConfig.value = defaultAppConfig.copyWith();
    changeLanguage(defaultAppConfig.locale);
  }

  void resetTasksTemplate() {
    homeCtrl.resetTasksTemplate();
  }
}
