import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controller/couter.dart';

class Other extends StatelessWidget {
  Other({super.key});
  final CountController c = Get.find();

  @override
  Widget build(context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Other Page")),
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
              child: const Text("Go Back"),
              onPressed: () => Get.back(),
            ),
            Text("${c.count}"),
          ],
        )));
  }
}
