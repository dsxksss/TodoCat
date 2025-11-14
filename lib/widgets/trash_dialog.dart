import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:TodoCat/controllers/trash_ctr.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/data/schemas/workspace.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:TodoCat/widgets/label_btn.dart';
import 'package:TodoCat/widgets/dpd_menu_btn.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:TodoCat/core/utils/date_time.dart';

/// 回收站对话框
class TrashDialog extends StatefulWidget {
  const TrashDialog({super.key});

  @override
  State<TrashDialog> createState() => _TrashDialogState();
}

class _TrashDialogState extends State<TrashDialog> {
  late final TrashController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TrashController());
    // 打开对话框时刷新数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 700,
      height: context.isPhone ? 0.8.sh : 600,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // 标题栏
          _buildHeader(context, controller),
          // 回收站内容
          Expanded(
            child: _buildContent(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TrashController controller) {
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
                    Icons.delete_outline,
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
                        'trash'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Obx(() {
                        final count = controller.deletedTasks.length;
                        if (count == 0) {
                          return Text(
                            'trashEmpty'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                        return Text(
                          count == 1 ? '1 item' : '$count items',
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
              // 清空回收站按钮
              Obx(() {
                if (controller.deletedTasks.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: LabelBtn(
                    ghostStyle: true,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.trashCan,
                          size: 14,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'emptyTrash'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onPressed: () => _showEmptyTrashDialog(context, controller),
                  ),
                );
              }),
              // 关闭按钮
              LabelBtn(
                ghostStyle: true,
                label: Builder(
                  builder: (context) => Icon(
                    Icons.close,
                    size: 18,
                    color: context.theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
                padding: const EdgeInsets.all(4),
                onPressed: () => SmartDialog.dismiss(tag: 'trash_dialog'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, TrashController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.deletedTasks.isEmpty &&
          controller.deletedWorkspaces.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.trashCan,
                size: 64,
                color: context.theme.iconTheme.color?.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'trashEmpty'.tr,
                style: TextStyle(
                  fontSize: 18,
                  color: context.theme.textTheme.bodyLarge?.color
                      ?.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'trashEmptyDesc'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final hasDeletedWorkspaces = controller.deletedWorkspaces.isNotEmpty;
      final hasDeletedTasks = controller.deletedTasks.isNotEmpty;
      final totalItems = controller.deletedTasks.length +
          (hasDeletedWorkspaces ? controller.deletedWorkspaces.length + 1 : 0) +
          (hasDeletedWorkspaces && hasDeletedTasks ? 1 : 0); // 任务标题

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          // 先显示已删除的工作空间
          if (hasDeletedWorkspaces) {
            if (index == 0) {
              // 工作空间标题
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'deletedWorkspaces'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.theme.textTheme.titleLarge?.color,
                  ),
                ),
              );
            }
            if (index <= controller.deletedWorkspaces.length) {
              final workspace = controller.deletedWorkspaces[index - 1];
              return _buildDeletedWorkspaceCard(context, controller, workspace);
            }
            // 任务标题
            if (hasDeletedTasks &&
                index == controller.deletedWorkspaces.length + 1) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(
                  'deletedTasks'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.theme.textTheme.titleLarge?.color,
                  ),
                ),
              );
            }
            // 任务项
            final taskIndex = index -
                controller.deletedWorkspaces.length -
                (hasDeletedTasks ? 2 : 1);
            if (taskIndex >= 0 && taskIndex < controller.deletedTasks.length) {
              final task = controller.deletedTasks[taskIndex];
              return _buildDeletedTaskCard(context, controller, task);
            }
          } else {
            // 没有已删除的工作空间，直接显示任务
            final task = controller.deletedTasks[index];
            return _buildDeletedTaskCard(context, controller, task);
          }
          return const SizedBox.shrink();
        },
      );
    });
  }

  Widget _buildDeletedTaskCard(
      BuildContext context, TrashController controller, Task task) {
    // 如果task本身被删除，使用task的删除时间；否则使用最早被删除的todo的时间
    int displayDeletedAt = task.deletedAt;
    if (displayDeletedAt == 0 && task.todos != null && task.todos!.isNotEmpty) {
      // 找到最早被删除的todo
      final deletedTodos = task.todos!.where((t) => t.deletedAt > 0).toList();
      if (deletedTodos.isNotEmpty) {
        displayDeletedAt = deletedTodos
            .map((t) => t.deletedAt)
            .reduce((a, b) => a < b ? a : b);
      }
    }
    final deletedTime = controller.formatDeletedAt(displayDeletedAt);
    final deletedTodos = task.todos ?? [];
    final hasTodos = deletedTodos.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任务标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                final colorAndIcon = _getTaskColorAndIcon(task);
                return Row(
                  children: [
                    // 任务颜色标识
                    Container(
                      width: 5,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: colorAndIcon[0],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                colorAndIcon[1],
                                size: 16,
                                color: colorAndIcon[0],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.title.tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.clock,
                                size: 11,
                                color: context.theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${'deletedAt'.tr}: $deletedTime',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context
                                      .theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 操作按钮
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: DPDMenuBtn(
                        tag: 'trash_task_menu_${task.uuid}',
                        menuItems: [
                          MenuItem(
                            title: 'restore',
                            iconData: FontAwesomeIcons.rotateLeft,
                            callback: () =>
                                _restoreTask(context, controller, task),
                          ),
                          MenuItem(
                            title: 'permanentDelete',
                            iconData: FontAwesomeIcons.trashCan,
                            callback: () =>
                                _permanentDeleteTask(context, controller, task),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 已删除的Todos列表
          if (hasTodos) ...[
            Divider(
                height: 1,
                color: context.theme.dividerColor.withValues(alpha: 0.3)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'deletedTodos'.tr} (${deletedTodos.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...deletedTodos.map((todo) =>
                      _buildDeletedTodoItem(context, controller, task, todo)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 获取显示标题（直接返回todo标题，因为已经有时间显示来区分了）
  String _getDisplayTitle(Todo todo, List<Task> allTasks) {
    return todo.title;
  }

  Widget _buildDeletedTodoItem(
      BuildContext context, TrashController controller, Task task, Todo todo) {
    // 使用精确的删除时间（包含时分秒）
    final deletedTime =
        todo.deletedAt > 0 ? timestampToDateTime(todo.deletedAt) : '';

    // 获取显示标题（如果有同名todo，加上创建时间）
    final displayTitle = _getDisplayTitle(todo, controller.deletedTasks);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.theme.dividerColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    todo.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (deletedTime.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        size: 11,
                        color: context.theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${'deletedAt'.tr}: $deletedTime',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: DPDMenuBtn(
              tag: 'trash_todo_menu_${todo.uuid}',
              menuItems: [
                MenuItem(
                  title: 'restore',
                  iconData: FontAwesomeIcons.rotateLeft,
                  callback: () => _restoreTodo(context, controller, task, todo),
                ),
                MenuItem(
                  title: 'permanentDelete',
                  iconData: FontAwesomeIcons.trashCan,
                  callback: () =>
                      _permanentDeleteTodo(context, controller, task, todo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建已删除的工作空间卡片
  Widget _buildDeletedWorkspaceCard(
      BuildContext context, TrashController controller, Workspace workspace) {
    final deletedTime = controller.formatDeletedAt(workspace.deletedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 工作空间图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.work_outline,
                color: Colors.blueAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // 工作空间信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workspace.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deletedTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // 操作按钮
            DPDMenuBtn(
              tag: 'trash_workspace_menu_${workspace.uuid}',
              menuItems: [
                MenuItem(
                  title: 'restore',
                  iconData: FontAwesomeIcons.rotateLeft,
                  callback: () =>
                      _restoreWorkspace(context, controller, workspace),
                ),
                MenuItem(
                  title: 'permanentDelete',
                  iconData: FontAwesomeIcons.trashCan,
                  callback: () =>
                      _permanentDeleteWorkspace(context, controller, workspace),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 获取任务的颜色和图标
  List<dynamic> _getTaskColorAndIcon(Task task) {
    switch (task.status) {
      case TaskStatus.todo:
        return [Colors.grey, FontAwesomeIcons.clipboard];
      case TaskStatus.inProgress:
        return [Colors.orangeAccent, FontAwesomeIcons.pencil];
      case TaskStatus.done:
        return [
          const Color.fromRGBO(46, 204, 147, 1),
          FontAwesomeIcons.circleCheck
        ];
    }
  }

  void _restoreWorkspace(
      BuildContext context, TrashController controller, Workspace workspace) {
    showToast(
      '${'sureRestoreWorkspace'.tr}「${workspace.name}」',
      alwaysShow: true,
      confirmMode: true,
      keepSingle: true,
      onYesCallback: () async {
        final success = await controller.restoreWorkspace(workspace.uuid);
        SmartDialog.dismiss(tag: 'trash_workspace_menu_${workspace.uuid}');
        if (success) {
          showSuccessNotification('workspaceRestored'.tr);
        } else {
          showErrorNotification('workspaceRestoreFailed'.tr);
        }
      },
    );
  }

  void _permanentDeleteWorkspace(
      BuildContext context, TrashController controller, Workspace workspace) {
    showToast(
      '${'surePermanentDeleteWorkspace'.tr}「${workspace.name}」',
      alwaysShow: true,
      confirmMode: true,
      keepSingle: true,
      onYesCallback: () async {
        final success =
            await controller.permanentDeleteWorkspace(workspace.uuid);
        SmartDialog.dismiss(tag: 'trash_workspace_menu_${workspace.uuid}');
        if (success) {
          showSuccessNotification('workspacePermanentlyDeleted'.tr);
        } else {
          showErrorNotification('permanentDeleteFailed'.tr);
        }
      },
    );
  }

  void _restoreTask(
      BuildContext context, TrashController controller, Task task) {
    showToast(
      '${'sureRestoreTask'.tr}「${task.title}」',
      alwaysShow: true,
      confirmMode: true,
      keepSingle: true,
      onYesCallback: () async {
        final success = await controller.restoreTask(task.uuid);
        // 关闭对应的菜单
        SmartDialog.dismiss(tag: 'trash_task_menu_${task.uuid}');
        if (success) {
          // 刷新主页数据
          try {
            final homeCtrl = Get.find<HomeController>();
            // 直接刷新TaskManager，确保数据同步
            await homeCtrl.refreshData();
            // 成功时不添加消息到消息中心
          } catch (e) {
            // HomeController可能未初始化，忽略错误
          }
        } else {
          // 只在失败时显示通知
          showErrorNotification('restoreFailed'.tr);
        }
      },
    );
  }

  void _permanentDeleteTask(
      BuildContext context, TrashController controller, Task task) {
    showToast(
      '${'surePermanentDeleteTask'.tr}「${task.title}」',
      alwaysShow: true,
      confirmMode: true,
      keepSingle: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success = await controller.permanentDeleteTask(task.uuid);
        // 关闭对应的菜单
        SmartDialog.dismiss(tag: 'trash_task_menu_${task.uuid}');
        // 只在失败时显示通知，成功时不添加消息到消息中心
        if (!success) {
          showErrorNotification('permanentDeleteFailed'.tr);
        }
      },
    );
  }

  void _restoreTodo(
      BuildContext context, TrashController controller, Task task, Todo todo) {
    showToast(
      '${'sureRestoreTodo'.tr}「${todo.title}」',
      alwaysShow: true,
      confirmMode: true,
      keepSingle: true,
      onYesCallback: () async {
        final success = await controller.restoreTodo(task.uuid, todo.uuid);
        // 关闭对应的菜单
        SmartDialog.dismiss(tag: 'trash_todo_menu_${todo.uuid}');
        if (success) {
          // 刷新主页数据
          try {
            final homeCtrl = Get.find<HomeController>();
            // 直接刷新TaskManager，确保数据同步
            await homeCtrl.refreshData();
            // 成功时不添加消息到消息中心
          } catch (e) {
            // HomeController可能未初始化，忽略错误
          }
        } else {
          // 只在失败时显示通知
          showErrorNotification('restoreFailed'.tr);
        }
      },
    );
  }

  void _permanentDeleteTodo(
      BuildContext context, TrashController controller, Task task, Todo todo) {
    showToast(
      '${'surePermanentDeleteTodo'.tr}「${todo.title}」',
      alwaysShow: true,
      confirmMode: true,
      keepSingle: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success =
            await controller.permanentDeleteTodo(task.uuid, todo.uuid);
        // 关闭对应的菜单
        SmartDialog.dismiss(tag: 'trash_todo_menu_${todo.uuid}');
        // 只在失败时显示通知，成功时不添加消息到消息中心
        if (!success) {
          showErrorNotification('permanentDeleteFailed'.tr);
        }
      },
    );
  }

  void _showEmptyTrashDialog(BuildContext context, TrashController controller) {
    showToast(
      'sureEmptyTrash'.tr,
      alwaysShow: true,
      confirmMode: true,
      keepSingle: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success = await controller.emptyTrash();
        // 只在失败时显示通知，成功时不添加消息到消息中心
        if (!success) {
          showErrorNotification('emptyTrashFailed'.tr);
        }
      },
    );
  }
}
