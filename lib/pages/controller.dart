import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/app_lifecycle_observer.dart';
import 'package:todo_cat/config/smart_dialog.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/services/repositorys/app_config.dart';
import 'package:todo_cat/manager/local_notification_manager.dart';
import 'package:todo_cat/themes/theme_mode.dart';
import 'package:window_manager/window_manager.dart';

class AppController extends GetxController {
  late final LocalNotificationManager localNotificationManager;
  late final AppConfigRepository appConfigRepository;
  late final appConfig = Rx<AppConfig>(
    AppConfig(
      configName: "default",
      isDarkMode: true,
      locale: const Locale("zh", "CN"),
      emailReminderEnabled: false,
    ),
  );
  final isMaximize = false.obs;
  final isFullScreen = false.obs;

  @override
  void onInit() async {
    localNotificationManager = await LocalNotificationManager.getInstance();
    localNotificationManager.checkAllLocalNotification();
    appConfigRepository = await AppConfigRepository.getInstance();
    final AppConfig? currentAppConfig = appConfigRepository.read(
      appConfig.value.configName,
    );
    if (currentAppConfig != null) {
      appConfig.value = currentAppConfig;
      changeLanguage(appConfig.value.locale);
    } else {
      appConfigRepository.write(appConfig.value.configName, appConfig.value);
    }

    ever(
      appConfig,
      (value) async => {appConfigRepository.update(value.configName, value)},
    );

    super.onInit();
  }

  @override
  void onReady() {
    // 改变移动端顶部状态栏、底部导航栏样式
    changeSystemOverlayUI();
    // 初始化SmartDialogConfiguration
    initSmartDialogConfiguration();
    // 添加生命周期监听事件
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());
    super.onReady();
  }

  void changeThemeMode(TodoCatThemeMode mode) {
    appConfig.value.isDarkMode = mode == TodoCatThemeMode.dark ? true : false;
    appConfig.refresh();
  }

  void changeSystemOverlayUI() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await FlutterStatusbarcolor.setStatusBarWhiteForeground(
          appConfig.value.isDarkMode ? true : false);
    }
  }

  void targetThemeMode() {
    appConfig.value.isDarkMode = !appConfig.value.isDarkMode;
    appConfig.refresh();
    if (Platform.isAndroid || Platform.isIOS) {
      changeSystemOverlayUI();
    }
  }

  void changeLanguage(Locale language) async {
    await Get.updateLocale(language);
    appConfig.value.locale = Get.locale!;
    appConfig.refresh();
  }

  @override
  void onClose() {
    localNotificationManager.destroyLocalNotification();
    super.onClose();
  }

  void minimizeWindow() async {
    await windowManager.minimize();
  }

  void updateWindowStatus() async {
    final maximized = await windowManager.isMaximized();
    isMaximize.value = maximized;
    final fullScreen = await windowManager.isFullScreen();
    isFullScreen.value = fullScreen;
  }

  void targetMaximizeWindow() async {
    if (isMaximize.value) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    updateWindowStatus();
  }

  void closeWindow() async {
    await windowManager.close();
  }
}
