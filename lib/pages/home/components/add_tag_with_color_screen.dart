import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_cat/core/utils/responsive.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/tag_dialog_btn.dart';
import 'package:todo_cat/widgets/color_picker_dialog.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:todo_cat/widgets/tag_edit_dialog.dart';

class AddTagWithColorScreen extends ConsumerWidget {
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
  final List<TagWithColor> selectedTags;
  final Function(int) onDeleteTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        Wrap(
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
        ),
      ],
    );
  }
}

/// 带颜色选择的标签添加组件
class AddTagWithColorPicker extends ConsumerStatefulWidget {
  final TextInputAction? textInputAction;
  final int maxLength;
  final int maxLines;
  final double radius;
  final String fieldTitle;
  final String? Function(String?)? validator;
  final EdgeInsets contentPadding;
  final TextEditingController editingController;
  final bool ghostStyle;
  final List<TagWithColor> selectedTags;
  final Function(int) onDeleteTag;
  final Function(Color) onAddTagWithColor;

  /// 编辑某个已选标签时回调（替代原先直接修改 RxList）。
  final void Function(int index, TagWithColor newTag)? onEditTag;

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
    this.onEditTag,
  });

  @override
  ConsumerState<AddTagWithColorPicker> createState() =>
      _AddTagWithColorPickerState();
}

class _AddTagWithColorPickerState extends ConsumerState<AddTagWithColorPicker> {
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
        // 只有当有标签时才显示间距和标签列表
        if (widget.selectedTags.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Wrap(
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
                    onTap: () {
                      showTagEditDialog(
                        initialName: widget.selectedTags[index].name,
                        initialColor: widget.selectedTags[index].color,
                        onSave: (newName, newColor) {
                          widget.onEditTag?.call(
                            index,
                            widget.selectedTags[index].copyWith(
                              name: newName,
                              color: newColor,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
