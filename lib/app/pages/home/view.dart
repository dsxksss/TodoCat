import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/pages/home/controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(context) {
    print(controller.tasks);
    return const Scaffold(body: Center(child: Text("Home Page")));
  }
}
