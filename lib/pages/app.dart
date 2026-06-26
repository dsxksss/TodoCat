import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/platform.dart';
import 'package:todo_cat/routers/app_router.dart';
import 'package:todo_cat/themes/dark_theme.dart';
import 'package:todo_cat/themes/light_theme.dart';
import 'package:todo_cat/keys/dialog_keys.dart';

/// 额外的全局异常过滤器是否已安装（仅安装一次，避免 builder 每帧重置/覆盖）。
bool _extraErrorFilterInstalled = false;

/// 键盘事件过滤器，用于防止重复的键盘事件
class KeyboardEventFilter {
  static final Map<LogicalKeyboardKey, DateTime> _lastKeyEvents = {};
  static const Duration _duplicateThreshold = Duration(milliseconds: 50);
  static DateTime _lastCleanup = DateTime.now();
  static const Duration _cleanupInterval = Duration(minutes: 5);

  static bool shouldProcessKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return true;

    final now = DateTime.now();
    if (now.difference(_lastCleanup) > _cleanupInterval) {
      _cleanup(now);
      _lastCleanup = now;
    }

    final lastTime = _lastKeyEvents[event.logicalKey];
    if (lastTime != null && now.difference(lastTime) < _duplicateThreshold) {
      return false;
    }

    _lastKeyEvents[event.logicalKey] = now;
    return true;
  }

  static void _cleanup(DateTime now) {
    _lastKeyEvents.removeWhere(
        (key, time) => now.difference(time) > const Duration(minutes: 1));
  }
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    if (AppPlatform.isMobile) {
      setHighRefreshRate();
      FlutterNativeSplash.remove();
    }
  }

  void setHighRefreshRate() async {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  @override
  Widget build(BuildContext context) {
    // 监听 AppConfig 中的主题与语言（首次读取会触发 AppController 初始化）。
    final isDarkMode =
        ref.watch(appControllerProvider.select((c) => c.isDarkMode));
    final locale = ref.watch(appControllerProvider.select((c) => c.locale));

    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Focus(
            onKeyEvent: (node, event) {
              if (!KeyboardEventFilter.shouldProcessKeyEvent(event)) {
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: "TodoCat",
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              theme: lightTheme,
              darkTheme: darkTheme,
              routerConfig: appRouter,
              builder: FlutterSmartDialog.init(
                builder: (context, child) {
                  // 全局异常过滤：只安装一次，并链接到已有处理器（main.dart 安装的，
                  // 含 appflowy/Windows 退出等过滤），而不是每帧覆盖、丢掉它的逻辑。
                  if (!_extraErrorFilterInstalled) {
                    _extraErrorFilterInstalled = true;
                    final previousOnError = FlutterError.onError;
                    FlutterError.onError = (FlutterErrorDetails details) {
                      final errorMessage = details.exception.toString();
                      if (errorMessage.contains('Unable to parse JSON') ||
                          errorMessage.contains('KeyDownEvent is dispatched')) {
                        return; // 已知噪音，静默
                      }
                      if (previousOnError != null) {
                        previousOnError(details);
                      } else {
                        FlutterError.presentError(details);
                      }
                    };
                  }

                  // 全局滚动监听，关闭下拉菜单
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification ||
                          notification is ScrollStartNotification) {
                        SmartDialog.dismiss(tag: dropDownMenuBtnTag);
                        SmartDialog.dismiss(tag: settingsDropDownMenuBtnTag);
                      }
                      return false;
                    },
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
