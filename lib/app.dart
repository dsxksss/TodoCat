import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/smart_dialog.dart';
import 'package:todo_cat/locales/locales.dart';
import 'package:todo_cat/manager/local_notification_manager.dart';
import 'package:todo_cat/pages/unknown.dart';
import 'package:todo_cat/routers/router_map.dart';
import 'package:todo_cat/themes/light_theme.dart';

class AppController extends GetxController {
  late final LocalNotificationManager localNotificationManager;

  @override
  void onInit() async {
    localNotificationManager = await LocalNotificationManager.getInstance();
    localNotificationManager.checkAllLocalNotification();
    initSmartDialogConfiguration();

    super.onInit();
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "TodoCat",
          translations: Locales(),
          // locale: const Locale("en", "US"),
          locale: const Locale("zh", "CN"),
          fallbackLocale: const Locale('en', 'US'),
          builder: FlutterSmartDialog.init(),
          navigatorObservers: [FlutterSmartDialog.observer],
          theme: lightTheme,
          // darkTheme: darkTheme,
          useInheritedMediaQuery: true,
          unknownRoute: GetPage(
            name: '/notfound',
            page: () => const UnknownPage(),
            transition: Transition.fadeIn,
          ),
          initialRoute: '/',
          getPages: routerMap,
        );
      },
    );
  }
}
