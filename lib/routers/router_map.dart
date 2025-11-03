import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/start.dart';
import 'package:todo_cat/pages/home/home_page.dart';
import 'package:todo_cat/pages/todo_detail_page.dart';
import 'package:todo_cat/pages/trash/trash_page.dart';
import 'package:todo_cat/controllers/trash_ctr.dart';

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
  GetPage(
    name: '/todo-detail',
    page: () {
      final args = Get.arguments as Map<String, dynamic>;
      return TodoDetailPage(
        todoId: args['todoId'] as String,
        taskId: args['taskId'] as String,
      );
    },
    transition: Transition.rightToLeft,
    transitionDuration: 250.ms,
  ),
  GetPage(
    name: '/trash',
    page: () => const TrashPage(),
    transition: Transition.rightToLeft,
    transitionDuration: 250.ms,
    binding: BindingsBuilder(() {
      Get.put(TrashController());
    }),
  ),
];
