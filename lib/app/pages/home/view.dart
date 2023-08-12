import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/pages/home/controller.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});
  final Task task = Task(title: "Task1", icon: 1, color: '#000000');
  @override
  Widget build(context) {
    return Scaffold(
        body: Center(
            child: Obx(
      () => Column(
        children: [
          ElevatedButton(
            onPressed: () async => {
              controller.addTask(task),
            },
            child: const Text("Add Task"),
          ),
          ElevatedButton(
            onPressed: () async => {
              controller.deleteTask(task.title),
            },
            child: const Text("Delete Task"),
          ),
          const Text("Home Page"),
          ...controller.tasks.map((element) => Text(element.title))
        ],
      ),
    )));
  }
}
