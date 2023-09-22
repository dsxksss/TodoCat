import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:todo_cat/config/smart_dialog.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/services/repositorys/app_config.dart';
import 'package:todo_cat/locales/locales.dart';
import 'package:todo_cat/manager/local_notification_manager.dart';
import 'package:todo_cat/pages/unknown.dart';
import 'package:todo_cat/routers/router_map.dart';
import 'package:todo_cat/themes/dark_theme.dart';
import 'package:todo_cat/themes/light_theme.dart';
import 'package:todo_cat/themes/theme_mode.dart';

class AppController extends GetxController {
  late final LocalNotificationManager localNotificationManager;
  late final AppConfigRepository appConfigRepository;
  late final appConfig = Rx<AppConfig>(
    AppConfig(
      configName: "default",
      isDarkMode: true,
      locale: const Locale("zh", "CN"),
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

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      changeSystemOverlayUI();
    }

    ever(
      appConfig,
      (value) async => {appConfigRepository.update(value.configName, value)},
    );

    initSmartDialogConfiguration();
    super.onInit();
  }

  void changeThemeMode(TodoCatThemeMode mode) {
    appConfig.value.isDarkMode = mode == TodoCatThemeMode.dark ? true : false;
    appConfig.refresh();
  }

  void changeSystemOverlayUI() async {
    await FlutterStatusbarcolor.setStatusBarWhiteForeground(
        appConfig.value.isDarkMode ? true : false);
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
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppController controller;

  @override
  void initState() {
    Get.put(AppController());
    controller = Get.find();
    controller.changeSystemOverlayUI();
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      // 移除启动页面
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "TodoCat",
            translations: Locales(),
            locale: controller.appConfig.value.locale,
            fallbackLocale: const Locale('en', 'US'),
            builder: FlutterSmartDialog.init(),
            navigatorObservers: [FlutterSmartDialog.observer],
            themeMode: controller.appConfig.value.isDarkMode
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
            initialRoute: '/start',
            getPages: routerMap,
          ),
        );
      },
    );
  }
}
