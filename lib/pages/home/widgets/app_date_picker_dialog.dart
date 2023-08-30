import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDatePickerDialog extends StatelessWidget {
  const AppDatePickerDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 0.6.sw,
        height: 0.4.sw,
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: SizedBox.expand(
          child: Material(
            type: MaterialType.transparency,
            child: ListView(children: [Text("Date")]),
          ),
        ),
      ),
    );
  }
}
