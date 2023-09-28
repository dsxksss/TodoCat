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
    bool? ghostStyle,
    Color? fillColor,
  })  : _fillColor = fillColor,
        _ghostStyle = ghostStyle ?? false,
        _validator = validator,
        _editingController = editingController,
        _contentPadding = contentPadding,
        _maxLines = maxLines,
        _maxLength = maxLength,
        _fieldTitle = fieldTitle,
        _obscureText = obscureText,
        _radius = radius;

  final String _fieldTitle;
  final Color? _fillColor;
  final int _maxLength;
  final int? _maxLines;
  final double _radius;
  final bool _ghostStyle;
  final EdgeInsets _contentPadding;
  final bool _obscureText;
  final TextEditingController _editingController;
  final String? Function(String?)? _validator;

  @override
  Widget build(BuildContext context) {
    final InputBorder inputBorder = _ghostStyle
        ? InputBorder.none
        : OutlineInputBorder(
            borderSide:
                BorderSide(color: context.theme.dividerColor, width: 0.5),
            borderRadius: BorderRadius.circular(_radius),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          obscureText: _obscureText,
          controller: _editingController,
          maxLength: _maxLength,
          maxLines: _maxLines,
          cursorColor: Colors.blueGrey.shade400,
          decoration: InputDecoration(
            counter: const Text(""),
            filled: true,
            fillColor:
                _fillColor ?? context.theme.inputDecorationTheme.fillColor,
            contentPadding: _contentPadding,
            hintText: _fieldTitle.tr,
            hoverColor: Colors.transparent,
            hintStyle: const TextStyle(color: Colors.grey),
            border: inputBorder,
            focusedBorder: _ghostStyle
                ? InputBorder.none
                : OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade800, width: 1.5),
                    borderRadius: BorderRadius.circular(_radius),
                  ),
            enabledBorder: inputBorder,
            errorBorder: inputBorder,
            focusedErrorBorder: inputBorder,
            disabledBorder: inputBorder,
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
