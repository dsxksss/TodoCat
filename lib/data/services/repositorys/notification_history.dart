import 'package:logger/logger.dart';
import 'package:TodoCat/data/schemas/notification_history.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:TodoCat/data/database/database.dart' as drift_db;
import 'package:TodoCat/data/database/converters.dart';
import 'package:drift/drift.dart';

class NotificationHistoryRepository {
  static final _logger = Logger();
  static NotificationHistoryRepository? _instance;
  
  drift_db.AppDatabase? _db;
  
  NotificationHistoryRepository._();

  static Future<NotificationHistoryRepository> getInstance() async {
    if (_instance == null) {
      _instance = NotificationHistoryRepository._();
      await _instance!._init();
      _logger.i('NotificationHistoryRepository initialized');
    }
    return _instance!;
  }

  Future<void> _init() async {
    final dbService = await Database.getInstance();
    _db = dbService.appDatabase;
  }

  drift_db.AppDatabase get db {
    if (_db == null) {
      throw StateError('NotificationHistoryRepository not initialized');
    }
    return _db!;
  }

  /// 读取所有通知历史
  Future<List<NotificationHistoryItem>> readAll() async {
    try {
      final rows = await (db.select(db.notificationHistorys)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
          .get();
      final notifications = rows.map((row) => DbConverters.notificationHistoryFromRow(row)).toList();
      return notifications.map((model) => model.toItem()).toList();
    } catch (e) {
      _logger.e('Error reading all notification history: $e');
      return [];
    }
  }

  /// 读取单个通知历史
  Future<NotificationHistoryItem?> read(String id) async {
    try {
      final row = await (db.select(db.notificationHistorys)
            ..where((t) => t.notificationId.equals(id)))
          .getSingleOrNull();
      return row != null ? DbConverters.notificationHistoryFromRow(row).toItem() : null;
    } catch (e) {
      _logger.e('Error reading notification history: $e');
      return null;
    }
  }

  /// 保存通知历史
  Future<void> write(String id, NotificationHistoryItem item) async {
    try {
      final model = NotificationHistory.fromItem(item);
      await db.transaction(() async {
        final existing = await (db.select(db.notificationHistorys)
              ..where((t) => t.notificationId.equals(id)))
            .getSingleOrNull();
        
        final companion = DbConverters.notificationHistoryToCompanion(model);
        
        if (existing != null) {
          model.id = existing.id;
          await (db.update(db.notificationHistorys)..where((t) => t.id.equals(existing.id)))
              .write(companion);
        } else {
          final insertedId = await db.into(db.notificationHistorys).insert(companion);
          model.id = insertedId;
        }
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
      await db.transaction(() async {
        final notification = await (db.select(db.notificationHistorys)
              ..where((t) => t.notificationId.equals(id)))
            .getSingleOrNull();
        
        if (notification != null) {
          await (db.delete(db.notificationHistorys)..where((t) => t.id.equals(notification.id))).go();
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
      await db.transaction(() async {
        final notification = await (db.select(db.notificationHistorys)
              ..where((t) => t.notificationId.equals(id)))
            .getSingleOrNull();
        
        if (notification != null) {
          await (db.update(db.notificationHistorys)..where((t) => t.id.equals(notification.id)))
              .write(const drift_db.NotificationHistorysCompanion(isRead: Value(true)));
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
      await db.transaction(() async {
        final notifications = await db.select(db.notificationHistorys).get();
        for (var notification in notifications) {
          await (db.update(db.notificationHistorys)..where((t) => t.id.equals(notification.id)))
              .write(const drift_db.NotificationHistorysCompanion(isRead: Value(true)));
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
      await db.delete(db.notificationHistorys).go();
      _logger.d('Cleared all notification history');
    } catch (e) {
      _logger.e('Error clearing notification history: $e');
      rethrow;
    }
  }

  /// 保留最近的N条通知，删除更早的通知
  Future<void> keepRecentNotifications(int limit) async {
    try {
      await db.transaction(() async {
        final notifications = await (db.select(db.notificationHistorys)
              ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
            .get();
        
        if (notifications.length > limit) {
          final toDelete = notifications.sublist(limit);
          for (var notification in toDelete) {
            await (db.delete(db.notificationHistorys)..where((t) => t.id.equals(notification.id))).go();
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
