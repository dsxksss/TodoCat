import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/start.dart';
import 'package:todo_cat/pages/home/home_page.dart';

List<GetPage<dynamic>> routerMap = [
  GetPage(
    name: '/',
    page: () => const HomePage(),
    transition: Transition.fadeIn,
    transitionDuration: 200.ms,
  ),
  GetPage(
    name: '/start',
    page: () => const StartPage(),
    transition: Transition.fadeIn,
    transitionDuration: 200.ms,
  ),
];
