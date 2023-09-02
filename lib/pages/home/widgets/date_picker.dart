import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/widgets/app_date_picker_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DatePickerBtn extends StatelessWidget {
  const DatePickerBtn({
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
          padding: const EdgeInsets.only(bottom: 5),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    hintText: "Y-M-D - h:m:s",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  validator: validator),
            ),
            const SizedBox(
              width: 10,
            ),
            AnimationBtn(
              onPressed: () => showDatePickerDialog(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Text(
                      "selectReminderTime".tr,
                      style: TextStyle(color: Colors.white, fontSize: 22.sp),
                    ),
                    const SizedBox(
                      width: 5,
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
      return GestureDetector(child: const TodoCatDatePickerDialog());
    },
  );
}
