import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_cat/widgets/nav_bar.dart';

class TodoCatScaffold extends StatelessWidget {
  const TodoCatScaffold({
    super.key,
    required Widget body,
    String? title,
    List<Widget>? leftWidgets,
    List<Widget>? rightWidgets,
  })  : _body = body,
        _leftWidgets = leftWidgets,
        _rightWidgets = rightWidgets,
        _title = title;

  final Widget _body;
  final String? _title;
  final List<Widget>? _leftWidgets;
  final List<Widget>? _rightWidgets;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: Platform.isMacOS ? 30 : 0,
          ),
          NavBar(
            title: _title,
            leftWidgets: _leftWidgets,
            rightWidgets: _rightWidgets,
          ),
          const SizedBox(height: 10),
          Expanded(child: _body),
        ],
      ),
    );
  }
}
