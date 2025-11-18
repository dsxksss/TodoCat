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
import 'package:todo_cat/services/auto_update_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:logger/logger.dart';

class AppController extends GetxController {
  static final _logger = Logger();
  LocalNotificationManager? _localNotificationManager;
  late final AppConfigRepository appConfigRepository;
  final _autoUpdateService = AutoUpdateService();
  
  /// 获取本地通知管理器（可能为null如果初始化失败）
  LocalNotificationManager? get localNotificationManager => _localNotificationManager;
  
  /// 获取自动更新服务（供外部访问）
  AutoUpdateService get autoUpdateService => _autoUpdateService;
  final appConfig = Rx<AppConfig>(defaultAppConfig);
  final isMaximize = false.obs;
  final isFullScreen = false.obs;

  bool get _isMobilePlatform => Platform.isAndroid || Platform.isIOS;

  @override
  void onInit() async {
    _logger.i('Initializing AppController');
    try {
    await initConfig();
    } catch (e, stack) {
      _logger.e('Failed to initialize config: $e', error: e, stackTrace: stack);
      // 配置初始化失败不应该阻止应用启动，使用默认配置
    }
    
    try {
    await initLocalNotification();
    } catch (e, stack) {
      _logger.e('Failed to initialize local notification: $e', error: e, stackTrace: stack);
      // 通知服务初始化失败不应该阻止应用启动
      // _localNotificationManager 保持为 null，后续访问时需要检查
    }
    
    try {
    await initAutoUpdate();
    } catch (e, stack) {
      _logger.e('Failed to initialize auto update: $e', error: e, stackTrace: stack);
      // 更新服务初始化失败不应该阻止应用启动
    }
    
    super.onInit();
  }

  Future<void> initLocalNotification() async {
    _logger.d('Initializing local notification service');
    _localNotificationManager = await LocalNotificationManager.getInstance();
    _localNotificationManager?.checkAllLocalNotification();
  }

  /// 初始化自动更新服务
  Future<void> initAutoUpdate() async {
    // 仅在桌面平台初始化
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return;
    }
    
    try {
      _logger.d('Initializing auto update service');
      await _autoUpdateService.initialize();
      _logger.d('Auto update service initialized');
    } catch (e) {
      _logger.e('Failed to initialize auto update: $e');
    }
  }

  /// 手动检查更新
  Future<void> checkForUpdates({bool silent = false}) async {
    await _autoUpdateService.checkForUpdates(silent: silent);
  }

  Future<void> initConfig() async {
    _logger.d('Initializing app configuration');
    appConfigRepository = await AppConfigRepository.getInstance();
    final AppConfig? currentAppConfig = await appConfigRepository.read(
      appConfig.value.configName,
    );

    if (currentAppConfig != null) {
      appConfig.value = currentAppConfig;
      await changeLanguage(appConfig.value.locale);
    } else {
      await appConfigRepository.write(
          appConfig.value.configName, appConfig.value);
    }

    ever(
      appConfig,
      (value) async {
        try {
        _logger.d('AppConfig changed, updating local storage');
        await appConfigRepository.update(value.configName, value);
        } catch (e) {
          _logger.e('Error updating app config: $e');
          // 配置更新失败不应该导致应用崩溃
        }
      },
    );
  }

  @override
  void onReady() {
    _logger.d('AppController is ready');
    changeSystemOverlayUI();
    initSmartDialogConfiguration();
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());
    
    // 不再自动检查更新，用户可以在设置页面手动检查更新
    // 这样可以避免应用启动时自动触发更新检查，提升启动体验
    // 如果需要自动检查更新，可以在设置页面添加相关选项
    
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
    appConfig.value.updateLocale(Get.locale!);
    appConfig.refresh();
  }

  @override
  void onClose() {
    _logger.d('Cleaning up AppController resources');
    try {
      _localNotificationManager?.destroyLocalNotification();
    } catch (e) {
      _logger.e('Error cleaning up AppController: $e');
      // 清理失败不应该阻止应用关闭
    }
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
