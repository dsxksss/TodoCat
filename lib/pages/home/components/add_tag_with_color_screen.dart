import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:TodoCat/pages/home/components/text_form_field_item.dart';
import 'package:TodoCat/widgets/tag_dialog_btn.dart';
import 'package:TodoCat/widgets/color_picker_dialog.dart';
import 'package:TodoCat/data/schemas/tag_with_color.dart';

class AddTagWithColorScreen extends StatelessWidget {
  const AddTagWithColorScreen({
    super.key,
    this.textInputAction,
    required this.maxLength,
    this.maxLines = 1,
    this.radius = 0,
    required this.fieldTitle,
    this.validator,
    required this.contentPadding,
    required this.editingController,
    this.ghostStyle = false,
    required this.onSubmitted,
    required this.selectedTags,
    required this.onDeleteTag,
  });

  final TextInputAction? textInputAction;
  final int maxLength;
  final int maxLines;
  final double radius;
  final String fieldTitle;
  final String? Function(String?)? validator;
  final EdgeInsets contentPadding;
  final TextEditingController editingController;
  final bool ghostStyle;
  final void Function(String) onSubmitted;
  final RxList<TagWithColor> selectedTags;
  final Function(int) onDeleteTag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormFieldItem(
          textInputAction: textInputAction,
          maxLength: maxLength,
          maxLines: maxLines,
          radius: radius,
          fieldTitle: fieldTitle,
          validator: validator,
          contentPadding: contentPadding,
          editingController: editingController,
          ghostStyle: ghostStyle,
          onFieldSubmitted: (value) => onSubmitted(value),
          suffixIcon: Builder(
            builder: (context) => MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onSubmitted(editingController.text),
                child: Icon(
                  Icons.add_box_rounded, 
                  size: 20,
                  color: context.theme.iconTheme.color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                selectedTags.length,
                (index) => TagDialogBtn(
                  tag: selectedTags[index].name,
                  tagColor: selectedTags[index].color,
                  dialogTag: 'tag_${selectedTags[index].name}',
                  showDelete: true,
                  onDelete: () => onDeleteTag(index),
                  openDialog: const SizedBox.shrink(),
                  onDialogClose: () {
                    // 处理对话框关闭事件
                  },
                ),
              ),
            )),
      ],
    );
  }
}

/// 带颜色选择的标签添加组件
class AddTagWithColorPicker extends StatefulWidget {
  final TextInputAction? textInputAction;
  final int maxLength;
  final int maxLines;
  final double radius;
  final String fieldTitle;
  final String? Function(String?)? validator;
  final EdgeInsets contentPadding;
  final TextEditingController editingController;
  final bool ghostStyle;
  final RxList<TagWithColor> selectedTags;
  final Function(int) onDeleteTag;
  final Function(Color) onAddTagWithColor;

  const AddTagWithColorPicker({
    super.key,
    this.textInputAction,
    required this.maxLength,
    this.maxLines = 1,
    this.radius = 0,
    required this.fieldTitle,
    this.validator,
    required this.contentPadding,
    required this.editingController,
    this.ghostStyle = false,
    required this.selectedTags,
    required this.onDeleteTag,
    required this.onAddTagWithColor,
  });

  @override
  State<AddTagWithColorPicker> createState() => _AddTagWithColorPickerState();
}

class _AddTagWithColorPickerState extends State<AddTagWithColorPicker> {
  Color _selectedColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    // 如果有现有标签，使用最后一个标签的颜色作为默认颜色
    if (widget.selectedTags.isNotEmpty) {
      _selectedColor = widget.selectedTags.last.color;
    }
  }

  void _addTagWithColor() {
    widget.onAddTagWithColor(_selectedColor);
  }

  void _showColorPicker() {
    showColorPickerDialog(
      initialColor: _selectedColor,
      onColorSelected: (color) {
        setState(() {
          _selectedColor = color;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormFieldItem(
                textInputAction: widget.textInputAction,
                maxLength: widget.maxLength,
                maxLines: widget.maxLines,
                radius: widget.radius,
                fieldTitle: widget.fieldTitle,
                validator: widget.validator,
                contentPadding: widget.contentPadding,
                editingController: widget.editingController,
                ghostStyle: widget.ghostStyle,
                onFieldSubmitted: (value) => _addTagWithColor(),
                suffixIcon: Builder(
                  builder: (context) => MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _addTagWithColor(),
                      child: Icon(
                        Icons.add_box_rounded, 
                        size: 20,
                        color: context.theme.iconTheme.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 颜色选择按钮
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: context.theme.dividerColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedColor.withValues(alpha: 0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              widget.selectedTags.length,
              (index) => TagDialogBtn(
                tag: widget.selectedTags[index].name,
                tagColor: widget.selectedTags[index].color,
                dialogTag: 'tag_${widget.selectedTags[index].name}',
                showDelete: true,
                onDelete: () => widget.onDeleteTag(index),
                openDialog: const SizedBox.shrink(),
                onDialogClose: () {
                  // 处理对话框关闭事件
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}
