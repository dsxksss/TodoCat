import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/widgets/nav_bar.dart';

class TodoCatScaffold extends StatelessWidget {
  const TodoCatScaffold({super.key, required this.body});
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            child: Column(
              children: [
                SizedBox(
                  height: 100.w,
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
