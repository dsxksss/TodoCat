import 'package:get/get.dart';
import 'package:todo_cat/pages/home/view.dart';
import 'package:todo_cat/pages/start.dart';

List<GetPage<dynamic>> routerMap = [
  GetPage(
    name: '/start',
    page: () => const StartPage(),
    transition: Transition.fade,
  ),
  GetPage(
    name: '/',
    page: () => const HomePage(),
    transition: Transition.fade,
  ),
];
