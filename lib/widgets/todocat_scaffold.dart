import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_cat/widgets/nav_bar.dart';

class TodoCatScaffold extends StatelessWidget {
  const TodoCatScaffold({super.key, required Widget body}) : _body = body;
  final Widget _body;

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
                  child: _body,
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
