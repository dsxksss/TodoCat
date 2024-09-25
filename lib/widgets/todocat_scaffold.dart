import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_cat/widgets/nav_bar.dart';

/// 自定义 Scaffold 组件，包含导航栏和主体内容
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

  final Widget _body; // 主体内容组件
  final String? _title; // 导航栏的标题
  final List<Widget>? _leftWidgets; // 导航栏左侧的组件列表
  final List<Widget>? _rightWidgets; // 导航栏右侧的组件列表

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: Platform.isMacOS ? 30 : 0, // MacOS 系统上增加顶部间距
          ),
          NavBar(
            title: _title, // 导航栏的标题
            leftWidgets: _leftWidgets, // 导航栏左侧的组件列表
            rightWidgets: _rightWidgets, // 导航栏右侧的组件列表
          ),
          const SizedBox(height: 10), // 导航栏与主体内容之间的间距
          Expanded(child: _body), // 主体内容组件，填充剩余空间
        ],
      ),
    );
  }
}
