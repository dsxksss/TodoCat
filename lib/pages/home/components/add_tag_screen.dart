import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/widgets/tag_dialog_btn.dart';

class AddTagScreen extends StatelessWidget {
  const AddTagScreen({
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
  final RxList<String> selectedTags;
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
                  tag: selectedTags[index],
                  tagColor: Colors.blueAccent,
                  dialogTag: 'tag_${selectedTags[index]}',
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
