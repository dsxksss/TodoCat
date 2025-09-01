import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/data/schemas/notification_history.dart';
import 'package:todo_cat/data/services/repositorys/notification_history.dart';

class NotificationCenterManager extends GetxController {
  static final _logger = Logger();
  
  // 存储通知历史
  final RxList<NotificationHistoryItem> notifications = <NotificationHistoryItem>[].obs;
  
  // 最大存储通知数量
  static const int maxNotifications = 50;
  
  // 通知历史Repository
  NotificationHistoryRepository? _repository;
  
  // 是否已初始化
  final RxBool _isInitialized = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _logger.i('Initializing NotificationCenterManager');
    _initRepository();
  }
  
  /// 初始化Repository并加载通知历史
  Future<void> _initRepository() async {
    try {
      _repository = await NotificationHistoryRepository.getInstance();
      await _loadNotifications();
      _isInitialized.value = true;
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
        notifications.value = savedNotifications;
        _logger.i('Loaded ${notifications.length} notifications from database');
      }
    } catch (e) {
      _logger.e('Error loading notifications: $e');
    }
  }
  
  /// 添加通知到历史记录
  Future<void> addNotification({
    required String title,
    required String message,
    NotificationLevel level = NotificationLevel.info,
  }) async {
    final notification = NotificationHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      level: level,
      timestamp: DateTime.now(),
    );
    
    // 添加到列表开头
    notifications.insert(0, notification);
    
    // 限制最大数量
    if (notifications.length > maxNotifications) {
      final toRemove = notifications.sublist(maxNotifications);
      notifications.removeRange(maxNotifications, notifications.length);
      
      // 从数据库中删除多余通知
      if (_repository != null && _isInitialized.value) {
        for (var item in toRemove) {
          await _repository!.delete(item.id);
        }
      }
    }
    
    // 将新通知保存到数据库
    if (_repository != null && _isInitialized.value) {
      await _repository!.write(notification.id, notification);
    }
    
    _logger.d('Added notification: $title');
  }
  
  /// 标记通知为已读
  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final updated = notifications[index].copyWith(isRead: true);
      notifications[index] = updated;
      
      // 更新数据库
      if (_repository != null && _isInitialized.value) {
        await _repository!.markAsRead(id);
      }
      
      _logger.d('Marked notification as read: $id');
    }
  }
  
  /// 标记所有通知为已读
  Future<void> markAllAsRead() async {
    final List<NotificationHistoryItem> updatedList = [];
    
    for (var notification in notifications) {
      updatedList.add(notification.copyWith(isRead: true));
    }
    
    notifications.value = updatedList;
    
    // 更新数据库
    if (_repository != null && _isInitialized.value) {
      await _repository!.markAllAsRead();
    }
    
    _logger.d('Marked all notifications as read');
  }
  
  /// 删除通知
  Future<void> removeNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);
    
    // 从数据库删除
    if (_repository != null && _isInitialized.value) {
      await _repository!.delete(id);
    }
    
    _logger.d('Removed notification: $id');
  }
  
  /// 清空所有通知
  Future<void> clearAll() async {
    notifications.clear();
    
    // 清空数据库
    if (_repository != null && _isInitialized.value) {
      await _repository!.clearAll();
    }
    
    _logger.d('Cleared all notifications');
  }
  
  /// 获取未读通知数量
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  
  /// 获取最近的通知（用于显示在通知中心）
  List<NotificationHistoryItem> getRecentNotifications({int limit = 20}) {
    return notifications.take(limit).toList();
  }
}