import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:todo_cat/locales/locales.dart';
import 'package:todo_cat/pages/binding.dart';
import 'package:todo_cat/pages/app_ctr.dart';
import 'package:todo_cat/pages/unknown.dart';
import 'package:todo_cat/routers/router_map.dart';
import 'package:todo_cat/themes/dark_theme.dart';
import 'package:todo_cat/themes/light_theme.dart';

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
        return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "TodoCat",
            translations: Locales(),
            locale: _appController.appConfig.value.locale,
            fallbackLocale: const Locale('en', 'US'),
            builder: FlutterSmartDialog.init(),
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
            initialRoute: '/start',
            getPages: routerMap,
            initialBinding: AppBinding(),
          ),
        );
      },
    );
  }
}
