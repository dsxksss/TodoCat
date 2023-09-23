import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app.dart';
import 'package:todo_cat/widgets/nav_bar.dart';

class TodoCatScaffold extends StatelessWidget {
  TodoCatScaffold({super.key, required this.body});
  final Widget body;
  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            child: Column(
              children: [
                SizedBox(
                  height: Platform.isMacOS ? 110 : 85,
                ),
                Expanded(
                  child: body,
                ),
              ],
            ),
          ),
          const Positioned(top: 0, child: NavBar()),
        ],
      ),
    );
  }
}
