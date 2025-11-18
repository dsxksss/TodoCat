import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_cat/controllers/trash_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/controllers/home_ctr.dart';

/// 回收站页面
class TrashPage extends GetView<TrashController> {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TodoCatScaffold(
      title: 'trash'.tr,
      leftWidgets: [
        AnimationBtn(
          onPressed: () => Get.back(),
          child: Icon(
            Icons.arrow_back,
            size: 24,
            color: context.theme.iconTheme.color,
          ),
        ),
        const SizedBox(width: 12),
      ],
      rightWidgets: [
        Obx(() {
          if (controller.deletedTasks.isEmpty) {
            return const SizedBox.shrink();
          }
          return AnimationBtn(
            onPressed: () => _showEmptyTrashDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FontAwesomeIcons.trashCan,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'emptyTrash'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.deletedTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.trashCan,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'trashEmpty'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'trashEmptyDesc'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.deletedTasks.length,
          itemBuilder: (context, index) {
            final task = controller.deletedTasks[index];
            return _buildDeletedTaskCard(context, task);
          },
        );
      }),
    );
  }

  Widget _buildDeletedTaskCard(BuildContext context, Task task) {
    // 如果task本身被删除，使用task的删除时间；否则使用最早被删除的todo的时间
    int displayDeletedAt = task.deletedAt;
    if (displayDeletedAt == 0 && task.todos != null && task.todos!.isNotEmpty) {
      // 找到最早被删除的todo
      final deletedTodos = task.todos!.where((t) => t.deletedAt > 0).toList();
      if (deletedTodos.isNotEmpty) {
        displayDeletedAt = deletedTodos.map((t) => t.deletedAt).reduce((a, b) => a < b ? a : b);
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任务标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.clock,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${'deletedAt'.tr}: $deletedTime',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 操作按钮
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: context.theme.iconTheme.color,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'restore',
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.rotateLeft, size: 14),
                          const SizedBox(width: 8),
                          Text('restore'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.trashCan, size: 14, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('permanentDelete'.tr, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'restore') {
                      _restoreTask(context, task);
                    } else if (value == 'delete') {
                      _permanentDeleteTask(context, task);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // 已删除的Todos列表
          if (hasTodos) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'deletedTodos'.tr} (${deletedTodos.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...deletedTodos.map((todo) => _buildDeletedTodoItem(context, task, todo)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeletedTodoItem(BuildContext context, Task task, Todo todo) {
    final deletedTime = controller.formatDeletedAt(todo.deletedAt);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
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
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  deletedTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 恢复按钮
              IconButton(
                icon: const Icon(FontAwesomeIcons.rotateLeft, size: 16),
                color: Colors.blue,
                onPressed: () => _restoreTodo(context, task, todo),
                tooltip: 'restore'.tr,
              ),
              // 永久删除按钮
              IconButton(
                icon: const Icon(FontAwesomeIcons.trashCan, size: 16),
                color: Colors.red,
                onPressed: () => _permanentDeleteTodo(context, task, todo),
                tooltip: 'permanentDelete'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _restoreTask(BuildContext context, Task task) {
    showToast(
      '${'sureRestoreTask'.tr}「${task.title}」',
      alwaysShow: true,
      confirmMode: true,
      onYesCallback: () async {
        final success = await controller.restoreTask(task.uuid);
        if (success) {
          showSuccessNotification('taskRestored'.tr);
          // 刷新主页数据
          try {
            final homeCtrl = Get.find<HomeController>();
            await homeCtrl.refreshData();
          } catch (e) {
            // HomeController可能未初始化，忽略错误
          }
        } else {
          showErrorNotification('restoreFailed'.tr);
        }
      },
    );
  }

  void _permanentDeleteTask(BuildContext context, Task task) {
    showToast(
      '${'surePermanentDeleteTask'.tr}「${task.title}」',
      alwaysShow: true,
      confirmMode: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success = await controller.permanentDeleteTask(task.uuid);
        if (success) {
          showSuccessNotification('taskPermanentlyDeleted'.tr);
        } else {
          showErrorNotification('permanentDeleteFailed'.tr);
        }
      },
    );
  }

  void _restoreTodo(BuildContext context, Task task, Todo todo) {
    showToast(
      '${'sureRestoreTodo'.tr}「${todo.title}」',
      alwaysShow: true,
      confirmMode: true,
      onYesCallback: () async {
        final success = await controller.restoreTodo(task.uuid, todo.uuid);
        if (success) {
          showSuccessNotification('todoRestored'.tr);
          // 如果任务也恢复了，刷新主页数据
          try {
            final homeCtrl = Get.find<HomeController>();
            await homeCtrl.refreshData();
          } catch (e) {
            // HomeController可能未初始化，忽略错误
          }
        } else {
          showErrorNotification('restoreFailed'.tr);
        }
      },
    );
  }

  void _permanentDeleteTodo(BuildContext context, Task task, Todo todo) {
    showToast(
      '${'surePermanentDeleteTodo'.tr}「${todo.title}」',
      alwaysShow: true,
      confirmMode: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success = await controller.permanentDeleteTodo(task.uuid, todo.uuid);
        if (success) {
          showSuccessNotification('todoPermanentlyDeleted'.tr);
        } else {
          showErrorNotification('permanentDeleteFailed'.tr);
        }
      },
    );
  }

  void _showEmptyTrashDialog(BuildContext context) {
    showToast(
      'sureEmptyTrash'.tr,
      alwaysShow: true,
      confirmMode: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success = await controller.emptyTrash();
        if (success) {
          showSuccessNotification('trashEmptied'.tr);
        } else {
          showErrorNotification('emptyTrashFailed'.tr);
        }
      },
    );
  }
}

