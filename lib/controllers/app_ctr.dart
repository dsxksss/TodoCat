import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/pages/app_lifecycle_observer.dart';
import 'package:todo_cat/config/smart_dialog.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/services/repositorys/app_config.dart';
import 'package:todo_cat/core/local_notification_manager.dart';
import 'package:todo_cat/themes/theme_mode.dart';
import 'package:window_manager/window_manager.dart';
import 'package:logger/logger.dart';

class AppController extends GetxController {
  static final _logger = Logger();
  late final LocalNotificationManager localNotificationManager;
  late final AppConfigRepository appConfigRepository;
  final appConfig = Rx<AppConfig>(defaultAppConfig);
  final isMaximize = false.obs;
  final isFullScreen = false.obs;

  bool get _isMobilePlatform => Platform.isAndroid || Platform.isIOS;

  @override
  void onInit() async {
    _logger.i('Initializing AppController');
    await initConfig();
    await initLocalNotification();
    super.onInit();
  }

  Future<void> initLocalNotification() async {
    _logger.d('Initializing local notification service');
    localNotificationManager = await LocalNotificationManager.getInstance();
    localNotificationManager.checkAllLocalNotification();
  }

  Future<void> initConfig() async {
    _logger.d('Initializing app configuration');
    appConfigRepository = await AppConfigRepository.getInstance();
    final AppConfig? currentAppConfig = appConfigRepository.read(
      appConfig.value.configName,
    );

    if (currentAppConfig != null) {
      appConfig.value = currentAppConfig;
      await changeLanguage(appConfig.value.locale);
    } else {
      appConfigRepository.write(appConfig.value.configName, appConfig.value);
    }

    ever(
      appConfig,
      (value) {
        _logger.d('AppConfig changed, updating local storage');
        appConfigRepository.update(value.configName, value);
      },
    );
  }

  @override
  void onReady() {
    _logger.d('AppController is ready');
    changeSystemOverlayUI();
    initSmartDialogConfiguration();
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());
    super.onReady();
  }

  void changeThemeMode(TodoCatThemeMode mode) {
    _logger.d('Changing theme mode to: $mode');
    appConfig.value.isDarkMode = mode == TodoCatThemeMode.dark;
    appConfig.refresh();
  }

  Future<void> changeSystemOverlayUI() async {
    if (_isMobilePlatform) {
      _logger.d('Updating system overlay UI for mobile platform');
      await FlutterStatusbarcolor.setStatusBarWhiteForeground(
          appConfig.value.isDarkMode);
    }
  }

  void targetThemeMode() {
    _logger.d('Toggling theme mode');
    appConfig.value.isDarkMode = !appConfig.value.isDarkMode;
    appConfig.refresh();
    if (_isMobilePlatform) {
      changeSystemOverlayUI();
    }
  }

  Future<void> changeLanguage(Locale language) async {
    _logger.d('Changing language to: ${language.languageCode}');
    await Get.updateLocale(language);
    appConfig.value.locale = Get.locale!;
    appConfig.refresh();
  }

  @override
  void onClose() {
    _logger.d('Cleaning up AppController resources');
    localNotificationManager.destroyLocalNotification();
    super.onClose();
  }

  // Window management methods
  Future<void> minimizeWindow() async {
    _logger.d('Minimizing window');
    await windowManager.minimize();
  }

  Future<void> updateWindowStatus() async {
    isMaximize.value = await windowManager.isMaximized();
    isFullScreen.value = await windowManager.isFullScreen();
  }

  Future<void> targetMaximizeWindow() async {
    _logger.d('Toggling window maximize state');
    if (isMaximize.value) {
      await windowManager.unmaximize();
      return;
    }
    await windowManager.maximize();
  }

  Future<void> closeWindow() async {
    _logger.d('Closing window');
    await windowManager.close();
  }
}
