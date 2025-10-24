import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

/// 通知项模型
class NotificationItem {
  final String id;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final Duration displayDuration;
  
  // 定时器相关
  Timer? _dismissTimer;
  DateTime? _timerStartTime;
  Duration? _remainingDuration;
  VoidCallback? _onDismissCallback;
  bool _isPaused = false;
  
  // 暴露回调设置方法
  set onDismissCallback(VoidCallback? callback) {
    _onDismissCallback = callback;
  }
  
  // 位置相关属性
  RxDouble currentBottomOffset = 0.0.obs;
  RxDouble targetBottomOffset = 0.0.obs;
  
  // 悬停状态
  RxBool isHovered = false.obs;

  NotificationItem({
    required this.id,
    required this.message,
    required this.type,
    required this.displayDuration,
  }) : createdAt = DateTime.now() {
    _remainingDuration = displayDuration;
  }

  void startDismissTimer(VoidCallback onDismiss) {
    _onDismissCallback = onDismiss;
    _isPaused = false;
    _timerStartTime = DateTime.now();
    _remainingDuration = displayDuration;
    
    _dismissTimer = Timer(_remainingDuration!, () {
      if (!_isPaused) {
        _onDismissCallback?.call();
      }
    });
  }
  
  /// 暂停定时器（悬停时调用）
  void pauseDismissTimer() {
    if (_dismissTimer != null && _dismissTimer!.isActive && !_isPaused) {
      // 计算已经过去的时间
      final elapsed = DateTime.now().difference(_timerStartTime!);
      _remainingDuration = displayDuration - elapsed;
      
      // 确保剩余时间不为负数
      if (_remainingDuration!.isNegative) {
        _remainingDuration = Duration.zero;
      }
      
      // 取消当前定时器
      _dismissTimer!.cancel();
      _isPaused = true;
    }
  }
  
  /// 恢复定时器（离开悬停时调用）
  void resumeDismissTimer() {
    if (_isPaused && _remainingDuration != null && _onDismissCallback != null) {
      _isPaused = false;
      _timerStartTime = DateTime.now();
      
      if (_remainingDuration! > Duration.zero) {
        _dismissTimer = Timer(_remainingDuration!, () {
          if (!_isPaused) {
            _onDismissCallback?.call();
          }
        });
      } else {
        // 如果时间已经用完，立即触发关闭
        _onDismissCallback?.call();
      }
    }
  }

  void cancelDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _isPaused = false;
    _remainingDuration = null;
    _timerStartTime = null;
  }
  
  /// 更新目标位置
  void updateTargetPosition(double newOffset) {
    targetBottomOffset.value = newOffset;
  }
  
  /// 开始位置动画
  void animateToTarget() {
    // 使用补间动画平滑移动到目标位置
    final startOffset = currentBottomOffset.value;
    final endOffset = targetBottomOffset.value;
    const duration = Duration(milliseconds: 300);
    
    final startTime = DateTime.now();
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      final progress = (elapsed.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      
      // 使用缓出曲线
      final easedProgress = _easeOut(progress);
      final currentOffset = startOffset + (endOffset - startOffset) * easedProgress;
      
      currentBottomOffset.value = currentOffset;
      
      if (progress >= 1.0) {
        timer.cancel();
      }
    });
  }
  
  /// 缓出动画曲线
  double _easeOut(double t) {
    return 1 - (1 - t) * (1 - t) * (1 - t);
  }

  void dispose() {
    _dismissTimer?.cancel();
  }
}

/// 通知类型
enum NotificationType {
  success,
  error,
  info,
  warning,
}

/// 通知栈管理器
class NotificationStackManager extends GetxController {
  static NotificationStackManager get instance => Get.find<NotificationStackManager>();
  
  /// 通知列表
  final RxList<NotificationItem> _notifications = <NotificationItem>[].obs;
  
  /// 全局悬停状态 - 当任何通知被悬停时为true
  final RxBool _isAnyNotificationHovered = false.obs;
  
  /// 最大通知数量
  static const int maxNotifications = 3;
  
  /// 通知间距
  static const double notificationSpacing = 10.0;
  
  /// 基础底部偏移
  static const double baseBottomOffset = 20.0;
  
  /// 通知高度（包括间距）
  static const double notificationHeight = 70.0;

  List<NotificationItem> get notifications => _notifications;
  bool get isAnyNotificationHovered => _isAnyNotificationHovered.value;

  /// 添加通知到栈中
  String addNotification({
    required String message,
    required NotificationType type,
    Duration displayDuration = const Duration(milliseconds: 2500),
  }) {
    final id = const Uuid().v4();
    final notification = NotificationItem(
      id: id,
      message: message,
      type: type,
      displayDuration: displayDuration,
    );

    // 如果超过最大数量，移除最旧的通知（列表末尾）
    if (_notifications.length >= maxNotifications) {
      final oldestNotification = _notifications.last;
      // 超限移除使用立即移除，避免阻塞新通知添加
      removeNotification(oldestNotification.id, withAnimation: false);
    }

    // 设置新通知的初始位置（最底部 - 索引0）
    notification.currentBottomOffset.value = baseBottomOffset;
    notification.targetBottomOffset.value = baseBottomOffset;

    // 为所有已有通知更新目标位置（向上移动，索引+1）
    for (int i = 0; i < _notifications.length; i++) {
      final existingNotification = _notifications[i];
      final newIndex = i + 1; // 已有通知索引+1
      final newOffset = _calculateBottomOffset(newIndex);
      
      existingNotification.updateTargetPosition(newOffset);
      existingNotification.animateToTarget();
    }

    // 将新通知添加到列表开头（索引0 = 最底部位置）
    _notifications.insert(0, notification);
    
    // 注释掉自动定时器启动逻辑，通知只能手动关闭
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // 无论是否有悬停状态都启动定时器，让暂停逻辑在需要时处理
    //   notification.startDismissTimer(() {
    //     _removeExpiredNotification(id);
    //   });
    //   
    //   // 如果当前有全局悬停状态，立即暂停新通知的定时器
    //   if (_isAnyNotificationHovered.value) {
    //     notification.pauseDismissTimer();
    //   }
    // });

    return id;
  }


  /// 移除指定通知
  void removeNotification(String id, {bool withAnimation = true, bool isManualClose = false}) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      notification.dispose();
      
      if (withAnimation) {
        // 先关闭 SmartDialog 让它播放退出动画
        SmartDialog.dismiss(tag: 'notification_$id');
        
        // 根据关闭类型决定延迟时间
        final delayDuration = isManualClose 
            ? const Duration(milliseconds: 400)  // 手动关闭：稍长的动画
            : const Duration(milliseconds: 200);  // 自动过期：短动画
        
        // 延迟移除通知项和更新位置，让退出动画播放完成
        Future.delayed(delayDuration, () {
          final currentIndex = _notifications.indexWhere((n) => n.id == id);
          if (currentIndex != -1) {
            _notifications.removeAt(currentIndex);
            _updateRemainingNotificationsPosition();
          }
        });
      } else {
        // 立即移除（无动画）
        _notifications.removeAt(index);
        SmartDialog.dismiss(tag: 'notification_$id');
        _updateRemainingNotificationsPosition();
      }
    }
  }
  
  // 注释掉不再需要的过期通知移除方法
  // /// 移除过期通知（自动消失，短动画）
  // void _removeExpiredNotification(String id) {
  //   // 自动过期的通知使用短动画
  //   removeNotification(id, withAnimation: true, isManualClose: false);
  // }
  
  /// 更新剩余通知的位置（在移除通知后）
  void _updateRemainingNotificationsPosition() {
    for (int i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      final newOffset = _calculateBottomOffset(i);
      
      notification.updateTargetPosition(newOffset);
      notification.animateToTarget();
    }
  }

  /// 清空所有通知
  void clearAllNotifications() {
    for (final notification in _notifications) {
      notification.dispose();
      SmartDialog.dismiss(tag: 'notification_${notification.id}');
    }
    _notifications.clear();
  }

  /// 计算通知的底部偏移量
  double _calculateBottomOffset(int index) {
    return baseBottomOffset + (index * (notificationHeight + notificationSpacing));
  }
  
  /// 计算通知的底部偏移量（公共方法，用于显示）
  double calculateBottomOffset(int index) {
    return _calculateBottomOffset(index);
  }

  /// 获取通知在栈中的索引
  int getNotificationIndex(String id) {
    return _notifications.indexWhere((n) => n.id == id);
  }
  
  /// 获取通知对象
  NotificationItem? getNotification(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// 处理通知悬停（仅保留视觉反馈，无定时器逻辑）
  void handleNotificationHover(String id, bool isHovered) {
    final notification = getNotification(id);
    if (notification != null) {
      notification.isHovered.value = isHovered;
      
      // 更新全局悬停状态（仅用于UI显示）
      _updateGlobalHoverState();
      
      // 注释掉定时器相关逻辑，因为没有自动过期功能
      // if (_isAnyNotificationHovered.value) {
      //   _pauseAllNotifications();
      // } else {
      //   _resumeAllNotifications();
      // }
    }
  }
  
  /// 更新全局悬停状态（仅用于UI显示）
  void _updateGlobalHoverState() {
    // 检查是否有任何通知处于悬停状态
    final hasHoveredNotification = _notifications.any((notification) => notification.isHovered.value);
    _isAnyNotificationHovered.value = hasHoveredNotification;
  }
  
  // 注释掉不再需要的定时器管理方法
  // /// 暂停所有通知的定时器
  // void _pauseAllNotifications() {
  //   for (final notification in _notifications) {
  //     notification.pauseDismissTimer();
  //   }
  // }
  // 
  // /// 恢复所有通知的定时器
  // void _resumeAllNotifications() {
  //   for (final notification in _notifications) {
  //     // 为每个通知重新设置回调
  //     notification.onDismissCallback = () {
  //       _removeExpiredNotification(notification.id);
  //     };
  //     notification.resumeDismissTimer();
  //   }
  // }

  @override
  void onClose() {
    clearAllNotifications();
    super.onClose();
  }
}

/// 通知栈管理器初始化
class NotificationStackBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NotificationStackManager(), permanent: true);
  }
}