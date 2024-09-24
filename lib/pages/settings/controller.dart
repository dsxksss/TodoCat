import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
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

  void targetDebugMode() {
    appCtrl.appConfig.value.isDebugMode = !appCtrl.appConfig.value.isDebugMode;
    appCtrl.appConfig.refresh();
  }

  // 重置配置
  void resetConfig() {
    // appCtrl.appConfig.value = defaultAppConfig 这种做法只会触发一次更新
    // 因为如果向上面这种方法赋值的话，内存地址也是不会发生改变的
    // 这里因为是浅拷贝所以不会触发更新，需要进行值传递而非引用传递
    // 并且不需要手动refresh，因为是整体对象发生了变动，ever监听是可以被触发的
    appCtrl.appConfig.value = defaultAppConfig.copyWith();
    changeLanguage(defaultAppConfig.locale);
  }
}
