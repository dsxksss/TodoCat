import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({super.key, required this.todo});
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 200.w,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(todo.title),
    );
  }
}
