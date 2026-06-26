import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/pages/app_lifecycle_observer.dart';
import 'package:todo_cat/config/smart_dialog.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/services/repositorys/app_config.dart';
import 'package:todo_cat/core/local_notification_manager.dart';
import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/platform.dart';
import 'package:todo_cat/themes/theme_mode.dart';
import 'package:todo_cat/services/auto_update_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/services/sync_manager.dart';

part 'app_ctr.g.dart';

/// 全局应用控制器（原 GetxController -> Riverpod Notifier）。
/// state 即当前 [AppConfig]；外部通过 [updateConfig] 更新并持久化。
@Riverpod(keepAlive: true)
class AppController extends _$AppController {
  static final _logger = Logger();
  LocalNotificationManager? _localNotificationManager;
  AppConfigRepository? _appConfigRepository;
  final _autoUpdateService = AutoUpdateService();

  LocalNotificationManager? get localNotificationManager =>
      _localNotificationManager;
  AutoUpdateService get autoUpdateService => _autoUpdateService;

  bool get _isMobilePlatform => AppPlatform.isMobile;

  @override
  AppConfig build() {
    // 启动时确保全局 l10n 为默认配置语言。
    updateGlobalLocalizations(defaultAppConfig.locale);
    _init();
    return defaultAppConfig.copyWith();
  }

  Future<void> _init() async {
    _logger.i('Initializing AppController');
    try {
      await initConfig();
    } catch (e, stack) {
      _logger.e('Failed to initialize config: $e', error: e, stackTrace: stack);
    }
    try {
      await initLocalNotification();
    } catch (e, stack) {
      _logger.e('Failed to initialize local notification: $e',
          error: e, stackTrace: stack);
    }
    try {
      await initAutoUpdate();
    } catch (e, stack) {
      _logger.e('Failed to initialize auto update: $e',
          error: e, stackTrace: stack);
    }
    try {
      _logger.d('Initializing Sync Manager');
      await SyncManager().init();
    } catch (e) {
      _logger.e('Failed to initialize Sync Manager: $e');
    }

    // 原 onReady 的逻辑
    changeSystemOverlayUI();
    initSmartDialogConfiguration();
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  }

  Future<void> initConfig() async {
    _logger.d('Initializing app configuration');
    _appConfigRepository = await AppConfigRepository.getInstance();
    final AppConfig? currentAppConfig =
        await _appConfigRepository!.read(state.configName);

    if (currentAppConfig != null) {
      state = currentAppConfig;
      await changeLanguage(state.locale);
    } else {
      await _appConfigRepository!.write(state.configName, state);
      updateGlobalLocalizations(state.locale);
    }
  }

  Future<void> _persist() async {
    try {
      _logger.d('AppConfig changed, updating local storage');
      await _appConfigRepository?.update(state.configName, state);
    } catch (e) {
      _logger.e('Error updating app config: $e');
    }
  }

  /// 通用配置更新（替代原 `appConfig.value = x; appConfig.refresh()`）。
  Future<void> updateConfig(AppConfig config) async {
    state = config;
    await _persist();
  }

  Future<void> initLocalNotification() async {
    _logger.d('Initializing local notification service');
    _localNotificationManager = await LocalNotificationManager.getInstance();
    _localNotificationManager?.checkAllLocalNotification();
  }

  Future<void> initAutoUpdate() async {
    if (!AppPlatform.isWindows &&
        !AppPlatform.isMacOS &&
        !AppPlatform.isLinux) {
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

  Future<void> checkForUpdates({bool silent = false}) async {
    await _autoUpdateService.checkForUpdates(silent: silent);
  }

  void changeThemeMode(TodoCatThemeMode mode) {
    _logger.d('Changing theme mode to: $mode');
    state = state.copyWith(isDarkMode: mode == TodoCatThemeMode.dark);
    _persist();
  }

  Future<void> changeSystemOverlayUI() async {
    if (_isMobilePlatform) {
      _logger.d('Updating system overlay UI for mobile platform');
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              state.isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              state.isDarkMode ? Brightness.light : Brightness.dark,
        ),
      );
    }
  }

  void targetThemeMode() {
    _logger.d('Toggling theme mode');
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    if (_isMobilePlatform) {
      changeSystemOverlayUI();
    }
    _persist();
  }

  Future<void> changeLanguage(Locale language) async {
    _logger.d('Changing language to: ${language.languageCode}');
    // 同步全局 l10n 与 currentLocale（替代 GetX 的 Get.updateLocale）。
    updateGlobalLocalizations(language);
    state = state.copyWith(locale: language);
    await _persist();
  }
}

/// 窗口状态（桌面端最大化/全屏），原 AppController 的 isMaximize/isFullScreen。
@immutable
class WindowState {
  final bool isMaximize;
  final bool isFullScreen;
  const WindowState({this.isMaximize = false, this.isFullScreen = false});

  WindowState copyWith({bool? isMaximize, bool? isFullScreen}) => WindowState(
        isMaximize: isMaximize ?? this.isMaximize,
        isFullScreen: isFullScreen ?? this.isFullScreen,
      );
}

/// 窗口控制器（桌面端窗口管理）。
@Riverpod(keepAlive: true)
class WindowController extends _$WindowController {
  static final _logger = Logger();

  @override
  WindowState build() => const WindowState();

  Future<void> minimizeWindow() async {
    _logger.d('Minimizing window');
    await windowManager.minimize();
  }

  Future<void> updateWindowStatus() async {
    state = state.copyWith(
      isMaximize: await windowManager.isMaximized(),
      isFullScreen: await windowManager.isFullScreen(),
    );
  }

  Future<void> targetMaximizeWindow() async {
    _logger.d('Toggling window maximize state');
    if (state.isMaximize) {
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
