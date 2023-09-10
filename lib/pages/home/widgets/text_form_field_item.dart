import 'package:flutter/material.dart';
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            fieldTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: editingController,
          decoration: InputDecoration(
            filled: true, // 是否填充背景色
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            hintText: "${"enter".tr}${fieldTitle.tr}",
            hintStyle: const TextStyle(color: Colors.grey),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
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
