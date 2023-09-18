import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFormFieldItem extends StatelessWidget {
  const TextFormFieldItem({
    super.key,
    required this.editingController,
    required this.fieldTitle,
    required this.maxLength,
    this.maxLines = 1,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 5),
    this.validator,
  });

  final String fieldTitle;
  final int maxLength;
  final int maxLines;
  final EdgeInsets contentPadding;
  final TextEditingController editingController;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(fieldTitle),
        ),
        TextFormField(
          controller: editingController,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            counter: const Text(""),
            filled: true, // 是否填充背景色
            border: InputBorder.none,
            contentPadding: contentPadding,
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
                  return "pleaseCompleteItProperly".tr;
                }
                return null;
              },
        ),
      ],
    );
  }
}
