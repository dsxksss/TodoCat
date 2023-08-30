import 'package:get/get.dart';
import 'package:todo_cat/pages/home/binding.dart';
import 'package:todo_cat/pages/home/view.dart';

List<GetPage<dynamic>> routerMap = [
  GetPage(
    name: '/',
    page: () => const HomePage(),
    transition: Transition.fadeIn,
    binding: HomeBinding(),
  ),
];
