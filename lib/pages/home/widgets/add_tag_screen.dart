import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/home_ctr.dart';
import 'package:todo_cat/pages/home/widgets/text_form_field_item.dart';

class AddTagScreen extends StatelessWidget {
  AddTagScreen({
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
    Widget? suffix,
    TextInputAction? textInputAction,
  })  : _fillColor = fillColor,
        _ghostStyle = ghostStyle ?? false,
        _validator = validator,
        _editingController = editingController,
        _contentPadding = contentPadding,
        _maxLines = maxLines,
        _maxLength = maxLength,
        _fieldTitle = fieldTitle,
        _obscureText = obscureText,
        _radius = radius,
        _textInputAction = textInputAction;

  final AddTodoDialogController _ctrl = Get.find();

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
  final TextInputAction? _textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormFieldItem(
      textInputAction: _textInputAction,
      maxLength: _maxLength,
      maxLines: _maxLines,
      fillColor: _fillColor,
      contentPadding: _contentPadding,
      obscureText: _obscureText,
      fieldTitle: _fieldTitle,
      editingController: _editingController,
      ghostStyle: _ghostStyle,
      radius: _radius,
      validator: _validator,
      suffix: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => {_ctrl.addTag()},
          child: Text(
            "addTag".tr,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
