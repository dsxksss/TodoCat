import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/locales/locales.dart';
import 'package:todo_cat/app/pages/unknown.dart';
import 'package:todo_cat/app/routers/router_map.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "TodoCat",
      translations: Locales(),
      locale: const Locale("zh", "CN"),
      fallbackLocale: const Locale('en', 'US'),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      useInheritedMediaQuery: true,
      unknownRoute: GetPage(
          name: '/notfound',
          page: () => const UnknownPage(),
          transition: Transition.fadeIn),
      initialRoute: '/',
      getPages: routerMap,
    );
  }
}
