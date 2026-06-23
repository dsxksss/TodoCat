import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'notification_stack_manager.g.dart';

/// 通知项模型
///
/// 注意：原 `RxDouble currentBottomOffset/targetBottomOffset` 与 `RxBool isHovered`
/// 现为普通字段。其变化由 [NotificationStackManager] 在变更后重新发射 state 来驱动
/// UI 刷新（见 `NotificationStackState`）。
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

  // 位置动画定时器
  Timer? _animationTimer;

  // 暴露回调设置方法
  set onDismissCallback(VoidCallback? callback) {
    _onDismissCallback = callback;
  }

  // 位置相关属性（普通字段，替代原 RxDouble）
  double currentBottomOffset = 0.0;
  double targetBottomOffset = 0.0;

  // 悬停状态（普通字段，替代原 RxBool）
  bool isHovered = false;

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
    targetBottomOffset = newOffset;
  }

  /// 开始位置动画
  ///
  /// [onTick] 在每帧偏移更新后回调，用于让管理器重新发射 state 以驱动 UI 刷新。
  void animateToTarget({VoidCallback? onTick}) {
    // 使用补间动画平滑移动到目标位置
    final startOffset = currentBottomOffset;
    final endOffset = targetBottomOffset;
    const duration = Duration(milliseconds: 300);

    // 取消正在进行的动画，避免叠加
    _animationTimer?.cancel();

    final startTime = DateTime.now();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      final progress =
          (elapsed.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

      // 使用缓出曲线
      final easedProgress = _easeOut(progress);
      final currentOffset = startOffset + (endOffset - startOffset) * easedProgress;

      currentBottomOffset = currentOffset;
      onTick?.call();

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
    _animationTimer?.cancel();
  }
}

/// 通知类型
enum NotificationType {
  success,
  error,
  info,
  warning,
}

/// 通知栈状态
///
/// 不可变快照：每次变更（增删、动画帧、悬停）都会创建新的实例，使
/// `ref.watch(notificationStackManagerProvider)` 重新构建。
/// 列表内的 [NotificationItem] 保持稳定身份（定时器/回调依赖其引用），
/// 仅通过外层快照身份变化来驱动刷新。
class NotificationStackState {
  /// 通知列表
  final List<NotificationItem> notifications;

  /// 全局悬停状态 - 当任何通知被悬停时为 true
  final bool isAnyNotificationHovered;

  const NotificationStackState({
    this.notifications = const [],
    this.isAnyNotificationHovered = false,
  });

  NotificationStackState copyWith({
    List<NotificationItem>? notifications,
    bool? isAnyNotificationHovered,
  }) {
    return NotificationStackState(
      notifications: notifications ?? this.notifications,
      isAnyNotificationHovered:
          isAnyNotificationHovered ?? this.isAnyNotificationHovered,
    );
  }
}

/// 通知栈管理器
@Riverpod(keepAlive: true)
class NotificationStackManager extends _$NotificationStackManager {
  /// 最大通知数量
  static const int maxNotifications = 3;

  /// 通知间距
  static const double notificationSpacing = 10.0;

  /// 基础底部偏移
  static const double baseBottomOffset = 20.0;

  /// 通知高度（包括间距）
  static const double notificationHeight = 70.0;

  /// 内部通知列表（稳定引用，配合快照发射）
  final List<NotificationItem> _notifications = <NotificationItem>[];

  @override
  NotificationStackState build() {
    ref.onDispose(_disposeAll);
    return const NotificationStackState();
  }

  /// 重新发射状态快照（创建新的列表副本以触发 Riverpod 刷新）
  void _emit() {
    state = NotificationStackState(
      notifications: List<NotificationItem>.unmodifiable(_notifications),
      isAnyNotificationHovered:
          _notifications.any((notification) => notification.isHovered),
    );
  }

  List<NotificationItem> get notifications =>
      List<NotificationItem>.unmodifiable(_notifications);
  bool get isAnyNotificationHovered =>
      _notifications.any((notification) => notification.isHovered);

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
    notification.currentBottomOffset = baseBottomOffset;
    notification.targetBottomOffset = baseBottomOffset;

    // 为所有已有通知更新目标位置（向上移动，索引+1）
    for (int i = 0; i < _notifications.length; i++) {
      final existingNotification = _notifications[i];
      final newIndex = i + 1; // 已有通知索引+1
      final newOffset = _calculateBottomOffset(newIndex);

      existingNotification.updateTargetPosition(newOffset);
      existingNotification.animateToTarget(onTick: _emit);
    }

    // 将新通知添加到列表开头（索引0 = 最底部位置）
    _notifications.insert(0, notification);
    _emit();

    // 注释掉自动定时器启动逻辑，通知只能手动关闭
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // 无论是否有悬停状态都启动定时器，让暂停逻辑在需要时处理
    //   notification.startDismissTimer(() {
    //     _removeExpiredNotification(id);
    //   });
    //
    //   // 如果当前有全局悬停状态，立即暂停新通知的定时器
    //   if (isAnyNotificationHovered) {
    //     notification.pauseDismissTimer();
    //   }
    // });

    return id;
  }

  /// 移除指定通知
  void removeNotification(String id,
      {bool withAnimation = true, bool isManualClose = false}) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      notification.dispose();

      if (withAnimation) {
        // 先关闭 SmartDialog 让它播放退出动画
        SmartDialog.dismiss(tag: 'notification_$id');

        // 根据关闭类型决定延迟时间
        final delayDuration = isManualClose
            ? const Duration(milliseconds: 400) // 手动关闭：稍长的动画
            : const Duration(milliseconds: 200); // 自动过期：短动画

        // 延迟移除通知项和更新位置，让退出动画播放完成
        Future.delayed(delayDuration, () {
          final currentIndex = _notifications.indexWhere((n) => n.id == id);
          if (currentIndex != -1) {
            _notifications.removeAt(currentIndex);
            _updateRemainingNotificationsPosition();
            _emit();
          }
        });
      } else {
        // 立即移除（无动画）
        _notifications.removeAt(index);
        SmartDialog.dismiss(tag: 'notification_$id');
        _updateRemainingNotificationsPosition();
        _emit();
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
      notification.animateToTarget(onTick: _emit);
    }
  }

  /// 清空所有通知
  void clearAllNotifications() {
    for (final notification in _notifications) {
      notification.dispose();
      SmartDialog.dismiss(tag: 'notification_${notification.id}');
    }
    _notifications.clear();
    _emit();
  }

  /// 释放所有资源（provider dispose 时调用）
  void _disposeAll() {
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
      notification.isHovered = isHovered;

      // 更新全局悬停状态并刷新（仅用于UI显示）
      _emit();

      // 注释掉定时器相关逻辑，因为没有自动过期功能
      // if (isAnyNotificationHovered) {
      //   _pauseAllNotifications();
      // } else {
      //   _resumeAllNotifications();
      // }
    }
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
}
