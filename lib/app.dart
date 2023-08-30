import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/locales/locales.dart';
import 'package:todo_cat/manager/local_notification_manager.dart';
import 'package:todo_cat/pages/unknown.dart';
import 'package:todo_cat/routers/router_map.dart';
import 'package:todo_cat/themes/light_theme.dart';
import 'package:uuid/uuid.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final LocalNotificationManager localNotificationManager;

  void initNotification() async {
    localNotificationManager = await LocalNotificationManager.getInstance();
    localNotificationManager.checkAllLocalNotification();
    final LocalNotice notice = LocalNotice(
        id: const Uuid().v4(),
        title: "任务已经失效",
        description: "您有一个任务已经失效:修bug",
        createdAt: DateTime.now().millisecondsSinceEpoch,
        remindersAt:
            DateTime.now().add(Duration(seconds: 10)).millisecondsSinceEpoch);
    localNotificationManager.saveNotification(notice.id, notice);
  }

  @override
  void initState() {
    initNotification();
    super.initState();
  }

  @override
  void dispose() {
    localNotificationManager.destroyLocalNotification();
    super.dispose();
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
          locale: const Locale("zh", "CN"),
          fallbackLocale: const Locale('en', 'US'),
          builder: DevicePreview.appBuilder,
          theme: lightTheme,
          // darkTheme: darkTheme,
          useInheritedMediaQuery: true,
          unknownRoute: GetPage(
              name: '/notfound',
              page: () => const UnknownPage(),
              transition: Transition.fadeIn),
          initialRoute: '/',
          getPages: routerMap,
        );
      },
    );
  }
}
