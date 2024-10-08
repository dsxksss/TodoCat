import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    bool? autofocus,
    FocusNode? focusNode,
    Color? fillColor,
    Widget? suffix,
    TextInputAction? textInputAction,
    TextInputType? inputType = TextInputType.text,
  })  : _fillColor = fillColor,
        _ghostStyle = ghostStyle ?? false,
        _validator = validator,
        _autofocus = autofocus ?? false,
        _editingController = editingController,
        _contentPadding = contentPadding,
        _maxLines = maxLines,
        _maxLength = maxLength,
        _fieldTitle = fieldTitle,
        _obscureText = obscureText,
        _radius = radius,
        _suffix = suffix,
        _focusNode = focusNode,
        _textInputAction = textInputAction,
        _inputType = inputType;

  final String _fieldTitle;
  final Widget? _suffix;
  final Color? _fillColor;
  final FocusNode? _focusNode;
  final int _maxLength;
  final int? _maxLines;
  final double _radius;
  final bool _ghostStyle;
  final EdgeInsets _contentPadding;
  final bool _obscureText;
  final bool _autofocus;
  final TextInputAction? _textInputAction;
  final TextEditingController _editingController;
  final String? Function(String?)? _validator;
  final TextInputType? _inputType;

  @override
  Widget build(BuildContext context) {
    final InputBorder inputBorder = _ghostStyle
        ? InputBorder.none
        : OutlineInputBorder(
            borderSide:
                BorderSide(color: context.theme.dividerColor, width: 0.5),
            borderRadius: BorderRadius.circular(_radius),
          );

    return TextFormField(
      textInputAction: _textInputAction,
      obscureText: _obscureText,
      controller: _editingController,
      maxLength: _maxLength,
      maxLines: _maxLines,
      autofocus: _autofocus,
      focusNode: _focusNode,
      keyboardType: _inputType,
      cursorColor: Colors.blueGrey.shade400,
      buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) =>
          const Text(
        "这个地方有点问题喔.",
        style: TextStyle(color: Colors.red),
      ),
      decoration: InputDecoration(
        suffix: _suffix,
        isCollapsed: false,
        counterText: "",
        filled: true,
        fillColor: _fillColor ?? context.theme.inputDecorationTheme.fillColor,
        contentPadding: _contentPadding,
        hintText: _fieldTitle.tr,
        hoverColor: Colors.transparent,
        hintStyle: const TextStyle(color: Colors.grey),
        border: inputBorder,
        focusedBorder: _ghostStyle
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade800, width: 1.5),
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
              return "${"pleaseCompleteItProperly".tr}${_fieldTitle.tr}";
            }
            return null;
          },
    );
  }
}
