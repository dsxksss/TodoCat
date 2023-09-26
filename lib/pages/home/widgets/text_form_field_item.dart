import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/show_toast.dart';

class TextFormFieldItem extends StatelessWidget {
  const TextFormFieldItem({
    super.key,
    int? maxLines,
    double radius = 10,
    bool obscureText = false,
    required int maxLength,
    required String fieldTitle,
    String? Function(String?)? validator,
    required TextEditingController editingController,
    EdgeInsets contentPadding = const EdgeInsets.symmetric(horizontal: 5),
  })  : _validator = validator,
        _editingController = editingController,
        _contentPadding = contentPadding,
        _maxLines = maxLines,
        _maxLength = maxLength,
        _fieldTitle = fieldTitle,
        _obscureText = obscureText,
        _radius = radius;

  final String _fieldTitle;
  final int _maxLength;
  final int? _maxLines;
  final double _radius;
  final EdgeInsets _contentPadding;
  final bool _obscureText;
  final TextEditingController _editingController;
  final String? Function(String?)? _validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          obscureText: _obscureText,
          controller: _editingController,
          maxLength: _maxLength,
          maxLines: _maxLines,
          decoration: InputDecoration(
            counter: const Text(""),
            filled: true,
            border: InputBorder.none,
            contentPadding: _contentPadding,
            hintText: _fieldTitle.tr,
            hintStyle: const TextStyle(color: Colors.grey),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(_radius),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(_radius),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(_radius),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(_radius),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(_radius),
            ),
          ),
          validator: _validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  showToast(
                    "${"pleaseCompleteItProperly".tr}${_fieldTitle.tr}",
                    toastStyleType: TodoCatToastStyleType.warning,
                  );
                  return '';
                }
                return null;
              },
        ),
      ],
    );
  }
}
