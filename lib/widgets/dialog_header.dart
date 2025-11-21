import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/label_btn.dart';

/// 统一的Dialog头部组件
/// 所有dialog和底部页都使用这个组件，确保一致的UI和交互
class DialogHeader extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String? confirmText;
  final String? cancelText;
  final bool showConfirm;
  final bool showCancel;

  const DialogHeader({
    super.key,
    this.title = '',
    this.titleWidget,
    this.onCancel,
    this.onConfirm,
    this.confirmText,
    this.cancelText,
    this.showConfirm = true,
    this.showCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.3,
            color: context.theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          titleWidget ?? Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (showCancel && onCancel != null)
                LabelBtn(
                  ghostStyle: true,
                  label: Text(
                    cancelText ?? "cancel".tr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  onPressed: onCancel!,
                ),
              if (showCancel && showConfirm && onCancel != null && onConfirm != null) const SizedBox(width: 8),
              if (showConfirm && onConfirm != null)
                LabelBtn(
                  label: Text(
                    confirmText ?? "confirm".tr,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  onPressed: onConfirm!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

