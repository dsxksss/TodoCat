import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

/// 平台适配的Dialog包装器
/// 根据平台自动选择显示底部页（移动端）或dialog（桌面端）
class PlatformDialogWrapper {
  /// 显示dialog或底部页
  ///
  /// [tag] dialog的唯一标识
  /// [content] 要显示的内容widget
  /// [width] 桌面端dialog的宽度，移动端忽略
  /// [height] dialog的高度（移动端为屏幕高度的百分比，桌面端为固定高度）
  /// [useSystem] 是否使用系统dialog
  /// [debounce] 是否防抖
  /// [keepSingle] 是否保持单一实例
  /// [backType] 返回键处理类型
  /// [animationTime] 动画时长
  /// [clickMaskDismiss] 点击遮罩是否关闭
  static void show({
    required String tag,
    required Widget content,
    double? width,
    double? height,
    bool useSystem = false,
    bool debounce = true,
    bool keepSingle = true,
    SmartBackType backType = SmartBackType.normal,
    Duration animationTime = const Duration(milliseconds: 150),
    bool clickMaskDismiss = false,
    Color? maskColor,
    VoidCallback? onDismiss,
  }) {
    final context = Get.context!;
    final isPhone = context.isPhone;

    // 移动端使用屏幕高度的百分比，桌面端使用固定高度
    final dialogHeight =
        isPhone ? (height ?? 0.75) * Get.height : (height ?? 540.0);

    // 桌面端使用指定宽度，移动端占满宽度
    final dialogWidth = isPhone ? Get.width : (width ?? 430.0);

    SmartDialog.show(
      tag: tag,
      useSystem: useSystem,
      debounce: debounce,
      keepSingle: keepSingle,
      backType: backType,
      animationTime: animationTime,
      alignment: isPhone ? Alignment.bottomCenter : Alignment.center,
      builder: (_) => isPhone
          ? Scaffold(
              backgroundColor: Colors.transparent,
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (clickMaskDismiss) {
                    SmartDialog.dismiss(tag: tag);
                    onDismiss?.call();
                  }
                },
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap:
                        () {}, // Prevent tap from propagating to the background
                    child: SizedBox(
                      width: dialogWidth,
                      height: dialogHeight,
                      child: content,
                    ),
                  ),
                ),
              ),
            )
          : SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: content,
            ),
      clickMaskDismiss: clickMaskDismiss,
      maskColor: maskColor ?? Colors.black.withValues(alpha: 0.3),
      onDismiss: onDismiss,
      animationBuilder: (controller, child, _) {
        if (isPhone) {
          // 移动端：从底部滑入
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: controller,
              child: child,
            ),
          );
        } else {
          // 桌面端：缩放和淡入
          final animation = child
              .animate(controller: controller)
              .fade(duration: controller.duration);
          return animation.scaleXY(
            begin: 0.98,
            duration: controller.duration,
            curve: Curves.easeIn,
          );
        }
      },
    );
  }

  /// 关闭dialog或底部页
  static void dismiss(String tag) {
    SmartDialog.dismiss(tag: tag);
  }
}
