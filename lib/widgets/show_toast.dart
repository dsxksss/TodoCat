import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:TodoCat/core/notification_stack_manager.dart';
import 'package:TodoCat/core/notification_center_manager.dart';
import 'package:TodoCat/data/schemas/notification_history.dart';
import 'package:TodoCat/widgets/label_btn.dart';

/// Toast 样式类型枚举
enum TodoCatToastStyleType {
  info,
  success,
  error,
  warning,
}

/// Toast 显示位置类型枚举
enum TodoCatToastPosition {
  center, // 原有的中心弹出方式（重要信息）
  bottomLeft, // 左下角向上弹出（一般操作反馈）
}

/// 根据 Toast 样式类型获取图标和颜色
List _getIconData(TodoCatToastStyleType type) {
  switch (type) {
    case TodoCatToastStyleType.success:
      return [FontAwesomeIcons.circleCheck, Colors.greenAccent];
    case TodoCatToastStyleType.warning:
      return [FontAwesomeIcons.triangleExclamation, Colors.orangeAccent];
    case TodoCatToastStyleType.error:
      return [FontAwesomeIcons.circleExclamation, Colors.redAccent];
    default:
      return [FontAwesomeIcons.circleInfo, Colors.blueAccent];
  }
}

/// 获取 Toast 动画效果
List<Effect<dynamic>> _getToastAnimationEffect(
    AnimationController controller, TodoCatToastStyleType? toastStyleType) {
  return [
    MoveEffect(
      begin: Platform.isAndroid || Platform.isIOS
          ? const Offset(0, -150)
          : const Offset(0, 150),
      duration: controller.duration,
      curve: Curves.easeInOutBack,
    ),
    FadeEffect(
      duration: controller.duration,
      curve: Curves.easeInOutBack,
    ),
  ];
}

/// 获取左下角弹出动画效果（轻柔的上缓渐显）
List<Effect<dynamic>> _getBottomLeftAnimationEffect(
    AnimationController controller) {
  return [
    // 轻柔的向上移动效果
    MoveEffect(
      begin: const Offset(0, 30), // 从下方30像素开始
      end: Offset.zero,
      duration: controller.duration! * 0.8, // 动画持续时间80%
      curve: Curves.easeOutCubic, // 使用缓出三次贝塞尔曲线，更轻柔
    ),
    // 渐显效果
    FadeEffect(
      begin: 0.0,
      end: 1.0,
      duration: controller.duration! * 0.6, // 淡入效果持续时间60%
      curve: Curves.easeOut, // 轻柔的淡入
    ),
    // 轻微的缩放效果
    ScaleEffect(
      begin: const Offset(0.95, 0.95), // 从95%开始，更自然
      end: const Offset(1.0, 1.0),
      duration: controller.duration! * 0.7,
      curve: Curves.easeOutCubic, // 轻柔的缩放
    ),
  ];
}

/// 构建左下角通知组件
Widget _buildBottomLeftNotification(
  BuildContext context,
  String message,
  TodoCatToastStyleType toastStyleType,
  String notificationId,
) {
  final iconData = _getIconData(toastStyleType);
  final stackManager = NotificationStackManager.instance;
  final notification = stackManager.getNotification(notificationId);
  
  if (notification == null) {
    return const SizedBox.shrink();
  }
  
  return MouseRegion(
    onEnter: (_) {
      stackManager.handleNotificationHover(notificationId, true);
    },
    onExit: (_) {
      stackManager.handleNotificationHover(notificationId, false);
    },
    child: Container(
      constraints: const BoxConstraints(
        maxWidth: 340,
        minWidth: 260,
        minHeight: 60,
      ),
      margin: const EdgeInsets.only(left: 20, bottom: 10),
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        // 移除阴影效果
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha:0.08),
        //     blurRadius: 12,
        //     offset: const Offset(0, 4),
        //     spreadRadius: 0,
        //   ),
        //   BoxShadow(
        //     color: iconData[1].withValues(alpha:0.15),
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //     spreadRadius: 0,
        //   ),
        // ],
        border: Border.all(
          color: iconData[1].withValues(alpha:0.3), // 降低透明度，避免亮主题下的亮光高亮
          width: 1, // 保持固定宽度
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 图标
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconData[1].withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                iconData[0],
                color: iconData[1],
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            // 消息内容
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.theme.textTheme.bodyLarge?.color,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // 关闭按钮
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  stackManager.removeNotification(notificationId, 
                      withAnimation: true, isManualClose: true);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha:0.1), // 保持固定样式
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey.shade600, // 保持固定颜色
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 显示 Toast
void showToast(
  String message, {
  String prefix = "",
  double prefixGap = 0,
  String suffix = "",
  double suffixGap = 0,
  bool confirmMode = false,
  bool alwaysShow = false,
  Function? onYesCallback,
  Function? onNoCallback,
  Duration? displayTime,
  Duration? animationTime,
  Alignment? alignment,
  bool fadeAnimation = false,
  Widget Function(BuildContext)? builder,
  EdgeInsetsGeometry? margin,
  TodoCatToastStyleType? toastStyleType,
  TodoCatToastPosition position = TodoCatToastPosition.center, // 新增位置参数
  Widget Function(AnimationController, Widget, AnimationParam)?
      animationBuilder,
  String? tag,
  bool? keepSingle,
  bool? backDismiss,
}) {
  double getHeight() {
    double height = 80;
    height = confirmMode ? height + 50 : height;
    height = message.length > 30 ? height + 30 : height;
    return height;
  }

  // 根据位置类型设置不同的参数
  final isBottomLeft = position == TodoCatToastPosition.bottomLeft;
  
  SmartDialog.show(
    displayTime: isBottomLeft 
        ? (displayTime ?? 2500.ms) // 左下角通知显示时间稍短
        : (alwaysShow ? const Duration(days: 365) : displayTime ?? 3000.ms),
    animationTime: isBottomLeft 
        ? (animationTime ?? 400.ms) // 左下角动画更快
        : (animationTime ?? 600.ms),
    tag: tag,
    keepSingle: keepSingle ?? !isBottomLeft, // 左下角允许多个通知并存
    alignment: isBottomLeft 
        ? Alignment.bottomLeft 
        : (alignment ??
            (Platform.isAndroid || Platform.isIOS
                ? Alignment.topCenter
                : Alignment.bottomCenter)),
    maskColor: confirmMode ? Colors.black.withValues(alpha:0.3) : Colors.transparent,
    usePenetrate: !confirmMode,
    maskWidget: confirmMode ? null : Container(),
    clickMaskDismiss: false,
    backType: isBottomLeft 
        ? SmartBackType.normal // 左下角通知不阻塞返回
        : (backDismiss == null
            ? SmartBackType.normal
            : (backDismiss ? SmartBackType.normal : SmartBackType.block)),
    animationBuilder: isBottomLeft 
        ? (controller, child, _) => child.animate(
              controller: controller,
              effects: _getBottomLeftAnimationEffect(controller),
            )
        : (animationBuilder ??
            (controller, child, _) => child.animate(
                  controller: controller,
                  effects: _getToastAnimationEffect(controller, toastStyleType),
                )),
    builder: isBottomLeft 
        ? (context) => _buildBottomLeftNotification(
              context,
              message,
              toastStyleType ?? TodoCatToastStyleType.success,
              'legacy_notification', // 传统通知模式的临时ID
            )
        : (builder ??
        (context) {
          final iconData =
              _getIconData(toastStyleType ?? TodoCatToastStyleType.info);
          return Container(
            width: 300,
            height: getHeight(),
            margin: margin ??
                (Platform.isAndroid || Platform.isIOS
                    ? const EdgeInsets.only(top: 110)
                    : const EdgeInsets.only(bottom: 100)),
            decoration: BoxDecoration(
              color: context.theme.dialogTheme.backgroundColor,
              borderRadius: BorderRadius.circular(5),
              // 移除阴影效果，避免亮主题下的亮光高亮
              // boxShadow: [
              //   BoxShadow(
              //     color: context.theme.dividerColor,
              //     blurRadius: context.isDarkMode ? 1 : 5,
              //   )
              // ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize:
                        confirmMode ? MainAxisSize.min : MainAxisSize.max,
                    mainAxisAlignment: confirmMode
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      if (confirmMode) const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            iconData[0],
                            color: iconData[1],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (prefix.isNotEmpty)
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      prefix,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                SizedBox(
                                  width: prefixGap,
                                ),
                                Flexible(
                                  child: Text(
                                    message,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: suffixGap,
                                ),
                                if (suffix.isNotEmpty)
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      suffix,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (confirmMode)
                    Positioned(
                      bottom: 10,
                      right: 5,
                      child: Row(
                        children: [
                          LabelBtn(
                            label: Text("yes".tr),
                            onPressed: () {
                              if (onYesCallback != null) {
                                SmartDialog.dismiss(tag: tag);
                                onYesCallback();
                              } else {
                                SmartDialog.dismiss(tag: tag);
                              }
                            },
                          ),
                          const SizedBox(width: 20),
                          LabelBtn(
                            label: Text("no".tr),
                            ghostStyle: true,
                            onPressed: () {
                              if (onNoCallback != null) {
                                SmartDialog.dismiss(tag: tag);
                                onNoCallback();
                              } else {
                                SmartDialog.dismiss(tag: tag);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
  );
}

/// 显示带有栈管理的左下角通知
void _showStackedNotification(
  String message,
  TodoCatToastStyleType toastStyleType,
  Duration displayTime,
  String notificationId,
) {
  final stackManager = NotificationStackManager.instance;
  final notification = stackManager.getNotification(notificationId);
  
  if (notification == null) return;
  
  SmartDialog.show(
    displayTime: null, // 移除自动显示时间，通知不会自动消失
    animationTime: 400.ms,
    tag: 'notification_$notificationId',
    useSystem: false, // 确保显示在最高层
    keepSingle: false, // 允许多个通知并存
    alignment: Alignment.bottomLeft,
    maskColor: Colors.transparent,
    maskWidget: Container(),
    clickMaskDismiss: false,
    backType: SmartBackType.normal,
    animationBuilder: (controller, child, _) => child.animate(
      controller: controller,
      effects: _getBottomLeftAnimationEffect(controller),
    ),
    builder: (context) => Obx(() => Container(
      margin: EdgeInsets.only(bottom: notification.currentBottomOffset.value),
      child: _buildBottomLeftNotification(
        context,
        message,
        toastStyleType,
        notificationId,
      ),
    )),
  );
}

/// 显示左下角通知（便捷方法）
/// 用于一般操作反馈，不会阻塞用户操作
/// [saveToNotificationCenter] 是否保存到通知中心，默认true（编辑操作等成功通知设为false）
void showNotification(
  String message, {
  TodoCatToastStyleType type = TodoCatToastStyleType.success,
  Duration? displayTime,
  String? title,
  bool saveToNotificationCenter = true,
}) {
  final stackManager = NotificationStackManager.instance;
  
  // 只有需要保存到通知中心的通知才添加到通知中心
  // 成功类型的通知（如编辑成功）通常不需要保存到通知中心，只显示临时通知
  if (saveToNotificationCenter) {
    try {
      // 尝试获取通知中心管理器
      final notificationCenter = Get.find<NotificationCenterManager>();
      
      // 添加到通知中心（会自动去重）
      notificationCenter.addNotification(
        title: title ?? _getNotificationTitle(type),
        message: message,
        level: _mapToNotificationLevel(type),
      ).then((_) {}).catchError((e) {
        if (kDebugMode) {
          print('Failed to save notification: $e');
        }
      });
    } catch (e) {
      // 如果通知中心未初始化，忽略错误
      if (kDebugMode) {
        print('NotificationCenterManager not initialized: $e');
      }
    }
  }
  
  final duration = displayTime ?? const Duration(milliseconds: 2500);
  
  // 将通知添加到栈中
  final notificationId = stackManager.addNotification(
    message: message,
    type: _mapToNotificationType(type),
    displayDuration: duration,
  );
  
  // 显示通知（位置由NotificationStackManager管理）
  _showStackedNotification(
    message,
    type,
    duration,
    notificationId,
  );
}

/// 将TodoCatToastStyleType转换为NotificationType
NotificationType _mapToNotificationType(TodoCatToastStyleType type) {
  switch (type) {
    case TodoCatToastStyleType.success:
      return NotificationType.success;
    case TodoCatToastStyleType.error:
      return NotificationType.error;
    case TodoCatToastStyleType.warning:
      return NotificationType.warning;
    case TodoCatToastStyleType.info:
      return NotificationType.info;
  }
}

/// 将TodoCatToastStyleType转换为NotificationLevel
NotificationLevel _mapToNotificationLevel(TodoCatToastStyleType type) {
  switch (type) {
    case TodoCatToastStyleType.success:
      return NotificationLevel.success;
    case TodoCatToastStyleType.error:
      return NotificationLevel.error;
    case TodoCatToastStyleType.warning:
      return NotificationLevel.warning;
    case TodoCatToastStyleType.info:
      return NotificationLevel.info;
  }
}

/// 获取通知类型对应的默认标题
String _getNotificationTitle(TodoCatToastStyleType type) {
  switch (type) {
    case TodoCatToastStyleType.success:
      return 'success'.tr;
    case TodoCatToastStyleType.error:
      return 'error'.tr;
    case TodoCatToastStyleType.warning:
      return 'warning'.tr;
    case TodoCatToastStyleType.info:
      return 'info'.tr;
  }
}

/// 显示成功通知（左下角）
/// [saveToNotificationCenter] 是否保存到通知中心，默认false（编辑操作等成功通知不保存）
void showSuccessNotification(String message, {bool saveToNotificationCenter = false}) {
  showNotification(
    message, 
    type: TodoCatToastStyleType.success,
    saveToNotificationCenter: saveToNotificationCenter,
  );
}

/// 显示错误通知（左下角）
/// 错误通知默认保存到通知中心
void showErrorNotification(String message) {
  showNotification(message, type: TodoCatToastStyleType.error, saveToNotificationCenter: true);
}

/// 显示信息通知（左下角）
/// 信息通知默认保存到通知中心
void showInfoNotification(String message) {
  showNotification(message, type: TodoCatToastStyleType.info, saveToNotificationCenter: true);
}
