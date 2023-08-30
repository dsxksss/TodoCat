import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/locales/locales.dart';
import 'package:todo_cat/pages/unknown.dart';
import 'package:todo_cat/routers/router_map.dart';
import 'package:todo_cat/themes/light_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

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
