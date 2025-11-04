import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:TodoCat/utils/font_utils.dart';
import 'package:TodoCat/widgets/label_btn.dart';

/// 颜色选择器对话框
class ColorPickerDialog extends StatelessWidget {
  final Color? initialColor;
  final Function(Color) onColorSelected;

  const ColorPickerDialog({
    super.key,
    this.initialColor,
    required this.onColorSelected,
  });

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
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 0.9.sw : 320,
      decoration: BoxDecoration(
        color: context.theme.dialogBackgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : BorderRadius.circular(10),
        // 移除阴影效果，避免亮主题下的亮光高亮
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: context.theme.dividerColor,
        //     blurRadius: context.isDarkMode ? 1 : 2,
        //   ),
        // ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  'selectTagColor'.tr,
                  style: FontUtils.getBoldStyle(fontSize: 18),
                ),
                LabelBtn(
                  ghostStyle: true,
                  label: Text('cancel'.tr),
                  onPressed: () => SmartDialog.dismiss(tag: 'color_picker'),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 颜色网格
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: predefinedColors.length,
                  itemBuilder: (context, index) {
                    final color = predefinedColors[index];
                    // 使用color.value比较颜色值，而不是对象引用
                    final isSelected = initialColor?.value == color.value;
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onColorSelected(color);
                          SmartDialog.dismiss(tag: 'color_picker');
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.white 
                                  : context.theme.dividerColor.withOpacity(0.3),
                              width: isSelected ? 2 : 0.5,
                            ),
                            // 移除阴影效果，避免亮主题下的亮光高亮
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: color.withOpacity(0.2),
                            //     blurRadius: 2,
                            //     offset: const Offset(0, 1),
                            //   ),
                            // ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示颜色选择器对话框
void showColorPickerDialog({
  Color? initialColor,
  required Function(Color) onColorSelected,
}) {
  SmartDialog.show(
    tag: 'color_picker',
    alignment: Alignment.center,
    maskColor: Colors.black.withOpacity(0.5),
    clickMaskDismiss: true,
    useAnimation: true,
    animationTime: const Duration(milliseconds: 200),
    builder: (_) => ColorPickerDialog(
      initialColor: initialColor,
      onColorSelected: onColorSelected,
    ),
    animationBuilder: (controller, child, animationParam) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: controller,
          child: child,
        ),
      );
    },
  );
}
