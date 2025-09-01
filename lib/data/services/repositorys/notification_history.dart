import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/data/schemas/notification_history.dart';
import 'package:todo_cat/data/services/database.dart';

class NotificationHistoryRepository {
  static final _logger = Logger();
  static NotificationHistoryRepository? _instance;
  
  final Database _database;
  Box<NotificationHistory>? _box;
  
  NotificationHistoryRepository._(this._database);
  
  static Future<NotificationHistoryRepository> getInstance() async {
    if (_instance == null) {
      final database = await Database.getInstance();
      _instance = NotificationHistoryRepository._(database);
      await _instance!._init();
      _logger.i('NotificationHistoryRepository initialized');
    }
    return _instance!;
  }
  
  Future<void> _init() async {
    _box = await _database.getBox<NotificationHistory>('notificationHistory');
  }
  
  Box<NotificationHistory> get box {
    if (_box == null) {
      throw StateError('NotificationHistoryRepository not initialized');
    }
    return _box!;
  }

  /// 读取所有通知历史
  Future<List<NotificationHistoryItem>> readAll() async {
    try {
      final notifications = box.values.toList();
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notifications.map((model) => model.toItem()).toList();
    } catch (e) {
      _logger.e('Error reading all notification history: $e');
      return [];
    }
  }

  /// 读取单个通知历史
  Future<NotificationHistoryItem?> read(String id) async {
    try {
      final notification = box.get(id);
      return notification?.toItem();
    } catch (e) {
      _logger.e('Error reading notification history: $e');
      return null;
    }
  }

  /// 保存通知历史
  Future<void> write(String id, NotificationHistoryItem item) async {
    try {
      final model = NotificationHistory.fromItem(item);
      await box.put(id, model);
      _logger.d('Saved notification history: $id');
    } catch (e) {
      _logger.e('Error writing notification history: $e');
      rethrow;
    }
  }

  /// 删除通知历史
  Future<void> delete(String id) async {
    try {
      await box.delete(id);
      _logger.d('Deleted notification history: $id');
    } catch (e) {
      _logger.e('Error deleting notification history: $e');
      rethrow;
    }
  }

  /// 标记单个通知为已读
  Future<void> markAsRead(String id) async {
    try {
      final notification = box.get(id);
      if (notification != null) {
        notification.isRead = true;
        await box.put(id, notification);
      }
      _logger.d('Marked notification as read: $id');
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// 标记所有通知为已读
  Future<void> markAllAsRead() async {
    try {
      final notifications = box.toMap();
      for (var entry in notifications.entries) {
        entry.value.isRead = true;
        await box.put(entry.key, entry.value);
      }
      _logger.d('Marked all notifications as read');
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// 清空所有通知
  Future<void> clearAll() async {
    try {
      await box.clear();
      _logger.d('Cleared all notification history');
    } catch (e) {
      _logger.e('Error clearing notification history: $e');
      rethrow;
    }
  }

  /// 保留最近的N条通知，删除更早的通知
  Future<void> keepRecentNotifications(int limit) async {
    try {
      final notifications = box.values.toList();
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      if (notifications.length > limit) {
        await box.clear();
        final recentNotifications = notifications.take(limit).toList();
        for (int i = 0; i < recentNotifications.length; i++) {
          await box.put(recentNotifications[i].notificationId, recentNotifications[i]);
        }
        _logger.d('Removed ${notifications.length - limit} old notifications, keeping $limit recent ones');
      }
    } catch (e) {
      _logger.e('Error pruning notification history: $e');
      rethrow;
    }
  }
}