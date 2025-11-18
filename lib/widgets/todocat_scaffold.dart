import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent, // 使用透明背景以支持自定义背景图片
      body: SafeArea(
        minimum: EdgeInsets.zero, // 不添加任何额外的边距
        bottom: false, // 底部不需要安全区域
        child: Column(
          children: [
            if (Platform.isMacOS) 15.verticalSpace,
            NavBar(
              title: _title, // 导航栏的标题
              leftWidgets: _leftWidgets, // 导航栏左侧的组件列表
              rightWidgets: _rightWidgets, // 导航栏右侧的组件列表
            ),
            5.verticalSpace, // 导航栏与主体内容之间的间距
            Expanded(child: _body), // 主体内容组件，填充剩余空间
          ],
        ),
      ),
    );
  }
}
