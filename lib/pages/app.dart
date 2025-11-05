import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:io';
import 'package:TodoCat/controllers/timepicker_ctr.dart';
import 'package:TodoCat/locales/locales.dart';
import 'package:TodoCat/pages/binding.dart';
import 'package:TodoCat/controllers/app_ctr.dart';
import 'package:TodoCat/pages/unknown_page.dart';
import 'package:TodoCat/routers/router_map.dart';
import 'package:TodoCat/themes/dark_theme.dart';
import 'package:TodoCat/themes/light_theme.dart';
import 'package:desktop_updater/desktop_updater.dart';

/// 键盘事件过滤器，用于防止重复的键盘事件
class KeyboardEventFilter {
  static final Map<LogicalKeyboardKey, DateTime> _lastKeyEvents = {};
  static const Duration _duplicateThreshold = Duration(milliseconds: 50);
  static DateTime _lastCleanup = DateTime.now();
  static const Duration _cleanupInterval = Duration(minutes: 5);

  static bool shouldProcessKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return true;
    
    final now = DateTime.now();
    
    // 定期清理旧记录防止内存泄漏
    if (now.difference(_lastCleanup) > _cleanupInterval) {
      _cleanup(now);
      _lastCleanup = now;
    }
    
    final lastTime = _lastKeyEvents[event.logicalKey];
    
    if (lastTime != null && now.difference(lastTime) < _duplicateThreshold) {
      // 过滤掉重复事件
      return false;
    }
    
    _lastKeyEvents[event.logicalKey] = now;
    return true;
  }
  
  static void _cleanup(DateTime now) {
    _lastKeyEvents.removeWhere((key, time) => 
        now.difference(time) > const Duration(minutes: 1));
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppController _appController;

  @override
  void initState() {
    Get.put(AppController());
    Get.put(TimePickerController());
    _appController = Get.find();

    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      // 支持高帧率
      setHighRefreshRate();
      // 移除启动页面
      FlutterNativeSplash.remove();
    }
  }

  void setHighRefreshRate() async {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Focus(
            // 添加键盘事件过滤器
            onKeyEvent: (node, event) {
              if (!KeyboardEventFilter.shouldProcessKeyEvent(event)) {
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Stack(
              children: [
                Obx(
                  () => GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: "TodoCat",
                  translations: Locales(),
                  locale: _appController.appConfig.value.locale,
                  fallbackLocale: const Locale('en', 'US'),
                  builder: (context, widget) {
                    // 添加全局异常捕获
                    FlutterError.onError = (FlutterErrorDetails details) {
                      // 过滤掉JSON解析错误和键盘事件错误的日志输出
                      final errorMessage = details.exception.toString();
                      if (!errorMessage.contains('Unable to parse JSON') &&
                          !errorMessage.contains('KeyDownEvent is dispatched')) {
                        FlutterError.presentError(details);
                      }
                    };
                    
                    return FlutterSmartDialog.init()(
                      context,
                      widget ?? const SizedBox.shrink(),
                    );
                  },
                  navigatorObservers: [FlutterSmartDialog.observer],
                  themeMode: _appController.appConfig.value.isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  useInheritedMediaQuery: true,
                  unknownRoute: GetPage(
                    name: '/notfound',
                    page: () => const UnknownPage(),
                    transition: Transition.fadeIn,
                  ),
                  initialRoute: context.isPhone ? '/start' : '/',
                  getPages: routerMap,
                  initialBinding: AppBinding(),
                ),
              ),
              // 在桌面平台添加更新对话框监听器
              Obx(() {
                if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                  if (_appController.updateControllerReady.value) {
                    final updateController = _appController.updateController;
                    if (updateController != null) {
                      return UpdateDialogListener(controller: updateController);
                    }
                  }
                }
                return const SizedBox.shrink();
              }),
              ],
            ),
          ),
        );
      },
    );
  }
}
