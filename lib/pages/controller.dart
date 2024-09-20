import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
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
  final appConfig = Rx<AppConfig>(defaultAppConfig);
  final isMaximize = false.obs;
  final isFullScreen = false.obs;

  @override
  void onInit() async {
    // 初始化APP应用配置
    initConfig();
    // 初始化应用本地通知服务
    initLocalNotification();

    super.onInit();
  }

  void initLocalNotification() async {
    // 单例模式，获取通知管理类实例
    localNotificationManager = await LocalNotificationManager.getInstance();
    // 检查是否存在未通知消息，如果存在则重新唤醒准备通知
    localNotificationManager.checkAllLocalNotification();
  }

  void initConfig() async {
    // 单例模式，获取配置类实例
    appConfigRepository = await AppConfigRepository.getInstance();
    final AppConfig? currentAppConfig = appConfigRepository.read(
      appConfig.value.configName,
    );

    // 如果存在配置文件，则导入加载至运行时配置
    if (currentAppConfig != null) {
      appConfig.value = currentAppConfig;
      changeLanguage(appConfig.value.locale);
    } else {
      // 如果不存在配置文件，则使用初始默认配置
      appConfigRepository.write(appConfig.value.configName, appConfig.value);
    }

    // 监听后续appConfig数据，如果发生变化则将新状态更新至本地数据文件中
    ever(
      appConfig,
      (value) {
        print("AppConfig changed");
        appConfigRepository.update(value.configName, value);
      },
    );
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

  // 改变主题模式
  void changeThemeMode(TodoCatThemeMode mode) {
    appConfig.value.isDarkMode = mode == TodoCatThemeMode.dark ? true : false;
    appConfig.refresh();
  }

  // 改变移动端状态栏样式
  void changeSystemOverlayUI() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await FlutterStatusbarcolor.setStatusBarWhiteForeground(
          appConfig.value.isDarkMode ? true : false);
    }
  }

  // 切换主题模式
  void targetThemeMode() {
    appConfig.value.isDarkMode = !appConfig.value.isDarkMode;
    appConfig.refresh();
    if (Platform.isAndroid || Platform.isIOS) {
      changeSystemOverlayUI();
    }
  }

  // 切换语言
  void changeLanguage(Locale language) async {
    await Get.updateLocale(language);
    appConfig.value.locale = Get.locale!;
    appConfig.refresh();
  }

  @override
  void onClose() {
    // 清理本地通知类对象服务池
    localNotificationManager.destroyLocalNotification();
    super.onClose();
  }

  // 窗口最小化
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
