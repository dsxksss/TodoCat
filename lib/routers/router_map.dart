import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/settings/controller.dart';
import 'package:todo_cat/pages/start.dart';
import 'package:todo_cat/pages/home/view.dart';
import 'package:todo_cat/pages/settings/view.dart';

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
    transition: Transition.rightToLeft,
    transitionDuration: 100.ms,
  )
];
