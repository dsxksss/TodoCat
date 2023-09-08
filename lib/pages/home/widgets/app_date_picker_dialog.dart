import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView(
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
