import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TextFormFieldItem extends StatelessWidget {
  const TextFormFieldItem({
    super.key,
    required this.editingController,
    required this.fieldTitle,
    this.validator,
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
              color: const Color.fromRGBO(17, 10, 76, 1),
            ),
          ),
        ),
        TextFormField(
          controller: editingController,
          decoration: InputDecoration(
            filled: true, // 是否填充背景色
            fillColor: const Color.fromRGBO(248, 250, 251, 1),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            hintText: "${"enter".tr}${fieldTitle.tr}",
            hintStyle: const TextStyle(color: Colors.grey),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.w),
            ),
            enabledBorder: OutlineInputBorder(
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
      ],
    );
  }
}
