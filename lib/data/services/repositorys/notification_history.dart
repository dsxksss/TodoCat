import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/data/schemas/notification_history.dart';
import 'package:todo_cat/data/services/database.dart';

class NotificationHistoryRepository {
  static final _logger = Logger();
  static NotificationHistoryRepository? _instance;
  
  final Database _database;
  
  NotificationHistoryRepository._(this._database);
  
  static Future<NotificationHistoryRepository> getInstance() async {
    if (_instance == null) {
      final database = await Database.getInstance();
      _instance = NotificationHistoryRepository._(database);
      _logger.i('NotificationHistoryRepository initialized');
    }
    return _instance!;
  }

  /// 读取所有通知历史
  Future<List<NotificationHistoryItem>> readAll() async {
    try {
      final notifications = await _database.isar.notificationHistorys.where().sortByTimestampDesc().findAll();
      return notifications.map((model) => model.toItem()).toList();
    } catch (e) {
      _logger.e('Error reading all notification history: $e');
      return [];
    }
  }

  /// 读取单个通知历史
  Future<NotificationHistoryItem?> read(String id) async {
    try {
      final notification = await _database.isar.notificationHistorys
          .filter()
          .notificationIdEqualTo(id)
          .findFirst();
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
      await _database.isar.writeTxn(() async {
        await _database.isar.notificationHistorys.put(model);
      });
      _logger.d('Saved notification history: $id');
    } catch (e) {
      _logger.e('Error writing notification history: $e');
      rethrow;
    }
  }

  /// 删除通知历史
  Future<void> delete(String id) async {
    try {
      await _database.isar.writeTxn(() async {
        final notification = await _database.isar.notificationHistorys
            .filter()
            .notificationIdEqualTo(id)
            .findFirst();
        if (notification != null) {
          await _database.isar.notificationHistorys.delete(notification.id);
        }
      });
      _logger.d('Deleted notification history: $id');
    } catch (e) {
      _logger.e('Error deleting notification history: $e');
      rethrow;
    }
  }

  /// 标记单个通知为已读
  Future<void> markAsRead(String id) async {
    try {
      await _database.isar.writeTxn(() async {
        final notification = await _database.isar.notificationHistorys
            .filter()
            .notificationIdEqualTo(id)
            .findFirst();
        if (notification != null) {
          notification.isRead = true;
          await _database.isar.notificationHistorys.put(notification);
        }
      });
      _logger.d('Marked notification as read: $id');
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// 标记所有通知为已读
  Future<void> markAllAsRead() async {
    try {
      await _database.isar.writeTxn(() async {
        final notifications = await _database.isar.notificationHistorys.where().findAll();
        for (var notification in notifications) {
          notification.isRead = true;
          await _database.isar.notificationHistorys.put(notification);
        }
      });
      _logger.d('Marked all notifications as read');
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// 清空所有通知
  Future<void> clearAll() async {
    try {
      await _database.isar.writeTxn(() async {
        await _database.isar.notificationHistorys.clear();
      });
      _logger.d('Cleared all notification history');
    } catch (e) {
      _logger.e('Error clearing notification history: $e');
      rethrow;
    }
  }

  /// 保留最近的N条通知，删除更早的通知
  Future<void> keepRecentNotifications(int limit) async {
    try {
      await _database.isar.writeTxn(() async {
        final notifications = await _database.isar.notificationHistorys
            .where()
            .sortByTimestampDesc()
            .findAll();
        
        if (notifications.length > limit) {
          final toDelete = notifications.sublist(limit);
          for (var notification in toDelete) {
            await _database.isar.notificationHistorys.delete(notification.id);
          }
          _logger.d('Removed ${toDelete.length} old notifications, keeping $limit recent ones');
        }
      });
    } catch (e) {
      _logger.e('Error pruning notification history: $e');
      rethrow;
    }
  }
}