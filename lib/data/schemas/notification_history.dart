import 'package:isar/isar.dart';

part 'notification_history.g.dart';

@collection
class NotificationHistory {
  Id id = Isar.autoIncrement; // 自动递增ID
  
  @Index(unique: true)
  late String notificationId; // 通知的唯一ID
  
  late String title;
  
  late String message;
  
  late int level; // 0: success, 1: info, 2: warning, 3: error
  
  late DateTime timestamp;
  
  late bool isRead;

  // 从NotificationHistoryItem创建
  static NotificationHistory fromItem(NotificationHistoryItem item) {
    final model = NotificationHistory();
    model.notificationId = item.id;
    model.title = item.title;
    model.message = item.message;
    model.level = item.level.index;
    model.timestamp = item.timestamp;
    model.isRead = item.isRead;
    return model;
  }

  // 转换为NotificationHistoryItem
  NotificationHistoryItem toItem() {
    return NotificationHistoryItem(
      id: notificationId,
      title: title,
      message: message,
      level: NotificationLevel.values[level],
      timestamp: timestamp,
      isRead: isRead,
    );
  }
}

/// 通知级别
enum NotificationLevel {
  success,
  info,
  warning,
  error,
}

/// 通知历史项
class NotificationHistoryItem {
  final String id;
  final String title;
  final String message;
  final NotificationLevel level;
  final DateTime timestamp;
  final bool isRead;
  
  const NotificationHistoryItem({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.timestamp,
    this.isRead = false,
  });
  
  NotificationHistoryItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationLevel? level,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
  
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${timestamp.month}月${timestamp.day}日';
    }
  }
}

/// 获取通知级别对应的颜色和图标
extension NotificationLevelExtension on NotificationLevel {
  String get icon {
    switch (this) {
      case NotificationLevel.success:
        return '✓';
      case NotificationLevel.info:
        return 'ℹ';
      case NotificationLevel.warning:
        return '⚠';
      case NotificationLevel.error:
        return '✗';
    }
  }
  
  int get colorValue {
    switch (this) {
      case NotificationLevel.success:
        return 0xFF4CAF50; // Green
      case NotificationLevel.info:
        return 0xFF2196F3; // Blue
      case NotificationLevel.warning:
        return 0xFFFF9800; // Orange
      case NotificationLevel.error:
        return 0xFFF44336; // Red
    }
  }
}