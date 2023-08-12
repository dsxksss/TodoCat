import 'package:get/get.dart';
import 'package:todo_cat/app/pages/home/binding.dart';
import 'package:todo_cat/app/pages/home/view.dart';

List<GetPage<dynamic>> routerMap = [
  GetPage(
    name: '/',
    page: () => const HomePage(),
    transition: Transition.fadeIn,
    binding: HomeBinding(),
  ),
];
