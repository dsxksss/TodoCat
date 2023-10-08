import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_cat/widgets/nav_bar.dart';

class TodoCatScaffold extends StatelessWidget {
  const TodoCatScaffold({super.key, required Widget body}) : _body = body;
  final Widget _body;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: Platform.isMacOS ? 30 : 0,
          ),
          const NavBar(),
          const SizedBox(height: 10),
          Expanded(child: _body),
        ],
      ),
    );
  }
}
