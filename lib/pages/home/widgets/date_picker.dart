import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/widgets/app_date_picker_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    super.key,
    required this.editingController,
    this.validator,
    required this.fieldTitle,
  });

  final String fieldTitle;
  final TextEditingController editingController;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.w),
          child: Text(
            fieldTitle,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                enabled: false,
                controller: editingController,
                decoration: InputDecoration(
                  filled: true, // 是否填充背景色
                  fillColor: const Color.fromRGBO(248, 250, 251, 1),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                  hintText: "YY--MM-DD",
                  hintStyle: const TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                ),
                validator: validator ??
                    (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "请填写完整内容";
                      }
                      return null;
                    },
              ),
            ),
            SizedBox(
              width: 20.w,
            ),
            AnimationBtn(
              onPressed: () => showDatePickerDialog(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.w),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Text(
                      "selectReminderTime".tr,
                      style: TextStyle(color: Colors.white, fontSize: 22.sp),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    const Icon(
                      Icons.timer_sharp,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void showDatePickerDialog() {
  Get.generalDialog(
    barrierLabel: "showAddTodoDialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: 250.ms,
    pageBuilder: (_, __, ___) {
      return GestureDetector(child: const AppDatePickerDialog());
    },
  );
}
