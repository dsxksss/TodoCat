import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/core/notification_center_manager.dart';
import 'package:todo_cat/data/schemas/notification_history.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/widgets/show_toast.dart';

import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/responsive.dart';

class NotificationCenterDialog extends ConsumerWidget {
  const NotificationCenterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: context.isPhone ? 1.sw : 550,
      height: context.isPhone ? 0.7.sh : 600,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : BorderRadius.circular(10),
        // 移除阴影效果，避免亮主题下的亮光高亮
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: context.theme.dividerColor,
        //     blurRadius: context.isDarkMode ? 1 : 2,
        //   ),
        // ],
      ),
      child: Column(
        children: [
          // 标题栏
          _buildHeader(context, ref),
          // 通知列表
          Expanded(
            child: _buildNotificationList(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.theme.dividerColor,
            width: 0.3,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) => Icon(
                    Icons.notifications,
                    size: 20,
                    color: context.theme.iconTheme.color,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.notificationCenter,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Consumer(builder: (context, ref, _) {
                        ref.watch(notificationCenterManagerProvider);
                        final unreadCount = ref
                            .read(notificationCenterManagerProvider.notifier)
                            .unreadCount;
                        return Text(
                          unreadCount > 0
                              ? '$unreadCount ${l10n.unreadMessages}'
                              : l10n.allMessagesRead,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标记全部已读按钮
              Consumer(builder: (context, ref, _) {
                ref.watch(notificationCenterManagerProvider);
                final notifier =
                    ref.read(notificationCenterManagerProvider.notifier);
                if (notifier.unreadCount > 0) {
                  return LabelBtn(
                    ghostStyle: true,
                    label: Text(
                      l10n.markAllRead,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    onPressed: () => notifier.markAllAsRead(),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(width: 8),
              // 清空所有通知按钮
              LabelBtn(
                ghostStyle: true,
                label: Text(
                  l10n.clearAllNotifications,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                onPressed: () {
                  // 使用 Toast 确认清空所有通知
                  showToast(
                    l10n.confirmClearAllNotificationsDesc,
                    confirmMode: true,
                    alwaysShow: true,
                    toastStyleType: TodoCatToastStyleType.warning,
                    onYesCallback: () {
                      ref
                          .read(notificationCenterManagerProvider.notifier)
                          .clearAll();
                      // 使用 Toast 显示操作成功信息，而不是添加新通知
                      showToast(l10n.notificationsCleared);
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
              // 关闭按钮
              LabelBtn(
                ghostStyle: true,
                label: const Icon(Icons.close, size: 20),
                padding: const EdgeInsets.all(4),
                onPressed: () =>
                    SmartDialog.dismiss(tag: 'notification_center_dialog'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, WidgetRef ref) {
    final allNotifications = ref.watch(notificationCenterManagerProvider);

    // 过滤掉不重要的通知，只显示错误和警告级别，以及未读信息
    final filteredNotifications = allNotifications.where((notification) {
      // 显示所有未读通知
      if (!notification.isRead) return true;
      // 显示错误和警告级别的通知
      return notification.level == NotificationLevel.error ||
          notification.level == NotificationLevel.warning;
    }).toList();

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        children: filteredNotifications
            .map((notification) =>
                _buildNotificationItem(context, notification, ref))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(
            builder: (context) => Icon(
              Icons.notifications_none,
              size: 64,
              color: context.theme.disabledColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNotifications,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.theme.disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noNotificationsDesc,
            style: TextStyle(
              fontSize: 12,
              color: context.theme.disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context,
      NotificationHistoryItem notification, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.transparent
            : context.theme.primaryColor.withValues(alpha: 0.05),
        border: Border.all(
          color: context.theme.dividerColor,
          width: 0.3,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 通知图标和未读指示器
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Color(notification.level.colorValue)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    notification.level.icon,
                    color: Color(notification.level.colorValue),
                    size: 16,
                  ),
                ),
              ),
              // 通知内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.8),
                      ),
                      // 移除行数限制，显示完整内容
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.formattedTime,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // 删除按钮
              LabelBtn(
                ghostStyle: true,
                label: Builder(
                  builder: (context) => Icon(
                    Icons.close,
                    size: 16,
                    color: context.theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
                padding: const EdgeInsets.all(4),
                onPressed: () => ref
                    .read(notificationCenterManagerProvider.notifier)
                    .removeNotification(notification.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
