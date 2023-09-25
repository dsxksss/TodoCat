import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unknown Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Unknown Page Please Enter Go Back Button!"),
            ElevatedButton(
              child: const Text("Go Back"),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
