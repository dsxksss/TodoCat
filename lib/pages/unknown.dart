import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Unknown extends StatelessWidget {
  const Unknown({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Unknown Page")),
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
              child: const Text("Go Back"),
              onPressed: () => Get.back(),
            ),
          ],
        )));
  }
}
