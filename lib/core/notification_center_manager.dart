import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_cat/data/schemas/notification_history.dart';
import 'package:todo_cat/data/services/repositorys/notification_history.dart';

part 'notification_center_manager.g.dart';

@Riverpod(keepAlive: true)
class NotificationCenterManager extends _$NotificationCenterManager {
  static final _logger = Logger();

  // 最大存储通知数量
  static const int maxNotifications = 50;

  // 通知历史Repository
  NotificationHistoryRepository? _repository;

  // 是否已初始化
  bool _isInitialized = false;

  /// state 即通知历史列表
  @override
  List<NotificationHistoryItem> build() {
    _logger.i('Initializing NotificationCenterManager');
    // 异步初始化 Repository（fire-and-forget，等价于原 onInit）
    _initRepository();
    return <NotificationHistoryItem>[];
  }

  /// 初始化Repository并加载通知历史
  Future<void> _initRepository() async {
    try {
      _repository = await NotificationHistoryRepository.getInstance();
      await _loadNotifications();
      _isInitialized = true;
      _logger.i('NotificationCenterManager initialized with repository');
    } catch (e) {
      _logger.e('Failed to initialize notification repository: $e');
    }
  }

  /// 从数据库加载通知历史
  Future<void> _loadNotifications() async {
    try {
      if (_repository != null) {
        final savedNotifications = await _repository!.readAll();
        state = savedNotifications;
        _logger.i('Loaded ${state.length} notifications from database');
      }
    } catch (e) {
      _logger.e('Error loading notifications: $e');
    }
  }

  /// 添加通知到历史记录
  /// [skipDuplicateCheck] 是否跳过重复检查，默认false
  /// [duplicateWindowMinutes] 重复检查的时间窗口（分钟），默认30分钟
  Future<void> addNotification({
    required String title,
    required String message,
    NotificationLevel level = NotificationLevel.info,
    bool skipDuplicateCheck = false,
    int duplicateWindowMinutes = 30,
  }) async {
    // 检查是否在时间窗口内有重复的通知（相同的标题和消息）
    if (!skipDuplicateCheck) {
      final now = DateTime.now();
      final windowStart = now.subtract(Duration(minutes: duplicateWindowMinutes));

      final hasDuplicate = state.any((n) {
        return n.title == title &&
               n.message == message &&
               n.timestamp.isAfter(windowStart);
      });

      if (hasDuplicate) {
        _logger.d('Skipping duplicate notification: $title (within $duplicateWindowMinutes minutes)');
        return;
      }
    }

    final notification = NotificationHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      level: level,
      timestamp: DateTime.now(),
    );

    // 添加到列表开头
    final updated = [notification, ...state];

    // 限制最大数量
    List<NotificationHistoryItem> toRemove = const [];
    if (updated.length > maxNotifications) {
      toRemove = updated.sublist(maxNotifications);
      updated.removeRange(maxNotifications, updated.length);
    }
    state = updated;

    // 从数据库中删除多余通知
    if (toRemove.isNotEmpty && _repository != null && _isInitialized) {
      for (var item in toRemove) {
        await _repository!.delete(item.id);
      }
    }

    // 将新通知保存到数据库
    if (_repository != null && _isInitialized) {
      await _repository!.write(notification.id, notification);
    }

    _logger.d('Added notification: $title');
  }

  /// 标记通知为已读
  Future<void> markAsRead(String id) async {
    final index = state.indexWhere((n) => n.id == id);
    if (index != -1) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(isRead: true);
      state = updated;

      // 更新数据库
      if (_repository != null && _isInitialized) {
        await _repository!.markAsRead(id);
      }

      _logger.d('Marked notification as read: $id');
    }
  }

  /// 标记所有通知为已读
  Future<void> markAllAsRead() async {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];

    // 更新数据库
    if (_repository != null && _isInitialized) {
      await _repository!.markAllAsRead();
    }

    _logger.d('Marked all notifications as read');
  }

  /// 删除通知
  Future<void> removeNotification(String id) async {
    state = state.where((n) => n.id != id).toList();

    // 从数据库删除
    if (_repository != null && _isInitialized) {
      await _repository!.delete(id);
    }

    _logger.d('Removed notification: $id');
  }

  /// 清空所有通知
  Future<void> clearAll() async {
    state = <NotificationHistoryItem>[];

    // 清空数据库
    if (_repository != null && _isInitialized) {
      await _repository!.clearAll();
    }

    _logger.d('Cleared all notifications');
  }

  /// 获取未读通知数量
  int get unreadCount => state.where((n) => !n.isRead).length;

  /// 获取最近的通知（用于显示在通知中心）
  List<NotificationHistoryItem> getRecentNotifications({int limit = 20}) {
    return state.take(limit).toList();
  }
}
