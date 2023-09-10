import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/date_panel.dart';
import 'package:todo_cat/widgets/time_panel.dart';

class TodoCatDatePickerDialog extends StatelessWidget {
  const TodoCatDatePickerDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 0.6.sw,
          height: 0.4.sw,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: context.theme.primaryColor,
            border: Border.all(color: context.theme.dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DatePanel(),
              TimePanel(),
            ],
          ),
        ),
      ),
    );
  }
}
