import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/tag_dialog_btn.dart';

class AddTagScreen extends StatelessWidget {
  const AddTagScreen({
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
    Function(String)? onSubmitted,
    required RxList<String> selectedTags,
    required Function(int) onDeleteTag,
  })  : _fillColor = fillColor,
        _validator = validator,
        _editingController = editingController,
        _contentPadding = contentPadding,
        _maxLines = maxLines,
        _maxLength = maxLength,
        _fieldTitle = fieldTitle,
        _obscureText = obscureText,
        _radius = radius,
        _textInputAction = textInputAction,
        _onSubmitted = onSubmitted,
        _selectedTags = selectedTags,
        _onDeleteTag = onDeleteTag;

  final String _fieldTitle;
  final Color? _fillColor;
  final int _maxLength;
  final int? _maxLines;
  final double _radius;
  final EdgeInsets _contentPadding;
  final bool _obscureText;
  final TextEditingController _editingController;
  final String? Function(String?)? _validator;
  final TextInputAction? _textInputAction;
  final Function(String)? _onSubmitted;
  final RxList<String> _selectedTags;
  final Function(int) _onDeleteTag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormFieldItem(
          textInputAction: _textInputAction,
          maxLength: _maxLength,
          maxLines: _maxLines,
          fillColor: _fillColor,
          contentPadding: _contentPadding,
          obscureText: _obscureText,
          fieldTitle: _fieldTitle,
          editingController: _editingController,
          ghostStyle: false,
          radius: _radius,
          validator: _validator,
          suffix: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _onSubmitted?.call(_editingController.text),
              child: Text(
                "addTag".tr,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ),
          onFieldSubmitted: (_) {},
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _selectedTags.length,
              (index) => TagDialogBtn(
                tag: _selectedTags[index],
                tagColor: Colors.lightBlue,
                dialogTag: 'tag_${_selectedTags[index]}',
                showDelete: true,
                onDelete: () => _onDeleteTag(index),
                openDialog: Container(
                    // 这里可以添加你的对话框内容
                    // 比如编辑标签的表单等
                    ),
                onDialogClose: () {
                  // 处理对话框关闭事件
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
