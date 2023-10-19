import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/controller.dart';
import 'package:todo_cat/utils/dialog_keys.dart';

class SettingsController extends GetxController {
  final AppController appCtrl = Get.find();
  late final Rx<String> currentLanguage;

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
}
