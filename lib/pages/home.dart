import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/couter.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(context) {
    final CountController c = Get.put(CountController());

    return Scaffold(
        appBar: AppBar(title: Text('hello'.tr)),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text('couter: ${c.count}')),
            ElevatedButton(
                child: const Text("Go to Other"),
                onPressed: () => Get.toNamed("/other")),
            ElevatedButton(
                child: const Text("Go to Unknown"),
                onPressed: () => Get.toNamed("adaw")),
            ElevatedButton(
                child: const Text("Change Language"),
                onPressed: () => Get.updateLocale(
                    Get.locale == const Locale("zh", "CN")
                        ? const Locale('en', 'US')
                        : const Locale("zh", "CN"))),
          ],
        )),
        floatingActionButton: FloatingActionButton(
            onPressed: c.increment, child: const Icon(Icons.add)));
  }
}
