import 'dart:io';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:todo_cat/pages/start.dart';
import 'package:todo_cat/pages/home/home_page.dart';
import 'package:todo_cat/pages/settings/settings_page.dart';

List<GetPage<dynamic>> routerMap = [
  GetPage(
    name: '/',
    page: () => const HomePage(),
    transition: Transition.fade,
  ),
  GetPage(
    name: '/start',
    page: () => const StartPage(),
    transition: Transition.fade,
  ),
  GetPage(
    name: '/settings',
    page: () => const SettingsPage(),
    binding: BindingsBuilder.put(() => SettingsController()),
    transition: Platform.isAndroid || Platform.isIOS
        ? Transition.rightToLeft
        : Transition.downToUp,
    transitionDuration: 170.ms,
  )
];
