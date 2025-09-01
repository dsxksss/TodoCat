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
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    TextInputType? inputType = TextInputType.text,
    required void Function(String) onFieldSubmitted,
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
        _suffixIcon = suffixIcon,
        _focusNode = focusNode,
        _textInputAction = textInputAction,
        _inputType = inputType,
        _onFieldSubmitted = onFieldSubmitted;

  final String _fieldTitle;
  final Widget? _suffix;
  final Widget? _suffixIcon;
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
  final void Function(String) _onFieldSubmitted;

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
      onFieldSubmitted: _onFieldSubmitted,
      decoration: InputDecoration(
        suffix: _suffix,
        suffixIcon: _suffixIcon,
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
              return "${'pleaseCompleteItProperly'.tr}${_fieldTitle.tr}";
            }
            return null;
          },
    );
  }
}
