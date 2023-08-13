import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddTodoCardBtn extends StatelessWidget {
  const AddTodoCardBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {print("addTodo".tr)},
      child: Container(
        width: 1.sw,
        margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(238, 238, 240, 1),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 36.w,
                color: Colors.grey[600],
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                "addTodo".tr,
                style: TextStyle(
                  fontSize: 22.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
