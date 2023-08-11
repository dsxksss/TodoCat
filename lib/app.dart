import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/locales/locales.dart';
import 'package:todo_cat/pages/home.dart';
import 'package:todo_cat/pages/other.dart';
import 'package:todo_cat/pages/unknown.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Locales(),
      locale: const Locale("zh", "CN"),
      fallbackLocale: const Locale('en', 'US'),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      useInheritedMediaQuery: true,
      unknownRoute: GetPage(
          name: '/notfound',
          page: () => const Unknown(),
          transition: Transition.fadeIn),
      initialRoute: '/',
      getPages: [
        GetPage(
            name: '/', page: () => const Home(), transition: Transition.fadeIn),
        GetPage(
            name: '/other', page: () => Other(), transition: Transition.fadeIn),
      ],
    );
  }
}
