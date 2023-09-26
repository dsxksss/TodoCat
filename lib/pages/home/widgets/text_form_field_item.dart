import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFormFieldItem extends StatelessWidget {
  const TextFormFieldItem({
    super.key,
    required TextEditingController editingController,
    required String fieldTitle,
    required int maxLength,
    int maxLines = 1,
    EdgeInsets contentPadding = const EdgeInsets.symmetric(horizontal: 5),
    String? Function(String?)? validator,
  })  : _validator = validator,
        _editingController = editingController,
        _contentPadding = contentPadding,
        _maxLines = maxLines,
        _maxLength = maxLength,
        _fieldTitle = fieldTitle;

  final String _fieldTitle;
  final int _maxLength;
  final int _maxLines;
  final EdgeInsets _contentPadding;
  final TextEditingController _editingController;
  final String? Function(String?)? _validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _editingController,
          maxLength: _maxLength,
          maxLines: _maxLines,
          decoration: InputDecoration(
            counter: const Text(""),
            filled: true, // 是否填充背景色
            border: InputBorder.none,
            contentPadding: _contentPadding,
            hintText: "${"enter".tr}${_fieldTitle.tr}",
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
          validator: _validator ??
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
