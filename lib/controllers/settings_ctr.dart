import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/settings/settings_page.dart';

class SettingsController extends GetxController {
  final AppController appCtrl = Get.find();
  late final Rx<String> currentLanguage;
  var isAnimating = false.obs;

  @override
  void onInit() {
    currentLanguage = _getLanguageTitle(
      appCtrl.appConfig.value.locale.languageCode,
    ).obs;
    super.onInit();
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

  void changeLanguage(Locale local) {
    appCtrl.changeLanguage(local);
    currentLanguage.value = _getLanguageTitle(local.languageCode);
    SmartDialog.dismiss(tag: settingsDropDownMenuBtnTag);
  }

  void targetEmailReminder() {
    appCtrl.appConfig.value.emailReminderEnabled =
        !appCtrl.appConfig.value.emailReminderEnabled;
    appCtrl.appConfig.refresh();
  }

  void targetDebugMode() {
    appCtrl.appConfig.value.isDebugMode = !appCtrl.appConfig.value.isDebugMode;
    appCtrl.appConfig.refresh();
  }

  void resetConfig() {
    appCtrl.appConfig.value = defaultAppConfig.copyWith();
    changeLanguage(defaultAppConfig.locale);
  }
}
