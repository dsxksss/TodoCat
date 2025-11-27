import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/utils/font_utils.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/widgets/platform_dialog_wrapper.dart';

/// 标签编辑对话框
class TagEditDialog extends StatefulWidget {
  final String initialName;
  final Color initialColor;
  final Function(String name, Color color) onSave;

  const TagEditDialog({
    super.key,
    required this.initialName,
    required this.initialColor,
    required this.onSave,
  });

  @override
  State<TagEditDialog> createState() => _TagEditDialogState();
}

class _TagEditDialogState extends State<TagEditDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;

  // 预定义的颜色列表 - 符合app风格的颜色
  static const List<Color> predefinedColors = [
    Color(0xFFEF4444), // 红色
    Color(0xFFEC4899), // 粉色
    Color(0xFFA855F7), // 紫色
    Color(0xFF8B5CF6), // 深紫色
    Color(0xFF6366F1), // 靛蓝色
    Color(0xFF3B82F6), // 蓝色
    Color(0xFF0EA5E9), // 浅蓝色
    Color(0xFF06B6D4), // 青色
    Color(0xFF10B981), // 绿色
    Color(0xFF84CC16), // 浅绿色
    Color(0xFFEAB308), // 黄色
    Color(0xFFF59E0B), // 琥珀色
    Color(0xFFF97316), // 橙色
    Color(0xFFDC2626), // 深橙色
    Color(0xFF78716C), // 棕色
    Color(0xFF6B7280), // 灰色
    Color(0xFF64748B), // 蓝灰色
    Color(0xFF1F2937), // 深灰色
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 0.9.sw : 350,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.theme.dividerColor,
                  width: 0.3,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'editTag'.tr, // 需要在翻译文件中添加 editTag
                  style: FontUtils.getBoldStyle(fontSize: 18),
                ),
                LabelBtn(
                  ghostStyle: true,
                  label: Text('cancel'.tr),
                  onPressed: () => SmartDialog.dismiss(tag: 'tag_edit_dialog'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标签名称输入框
                Text(
                  'tagName'.tr, // 需要在翻译文件中添加 tagName
                  style: TextStyle(
                    fontSize: 14,
                    color: context.theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'enterTagName'.tr, // 需要在翻译文件中添加 enterTagName
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.dividerColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 颜色选择
                Text(
                  'tagColor'.tr, // 需要在翻译文件中添加 tagColor
                  style: TextStyle(
                    fontSize: 14,
                    color: context.theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: predefinedColors.length,
                  itemBuilder: (context, index) {
                    final color = predefinedColors[index];
                    final isSelected =
                        _selectedColor.toARGB32() == color.toARGB32();

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : context.theme.dividerColor
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2 : 0.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.trim().isEmpty) {
                        return;
                      }
                      widget.onSave(
                          _nameController.text.trim(), _selectedColor);
                      SmartDialog.dismiss(tag: 'tag_edit_dialog');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'save'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示标签编辑对话框
void showTagEditDialog({
  required String initialName,
  required Color initialColor,
  required Function(String name, Color color) onSave,
}) {
  PlatformDialogWrapper.show(
    tag: 'tag_edit_dialog',
    content: TagEditDialog(
      initialName: initialName,
      initialColor: initialColor,
      onSave: onSave,
    ),
    maskColor: Colors.black.withValues(alpha: 0.5),
    clickMaskDismiss: true,
    animationTime: const Duration(milliseconds: 200),
  );
}
