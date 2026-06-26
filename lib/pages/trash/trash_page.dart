import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_cat/controllers/trash_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/core/utils/responsive.dart';

import 'package:todo_cat/core/utils/l10n.dart';
/// 回收站页面
class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashState = ref.watch(trashControllerProvider);
    return TodoCatScaffold(
      title: l10n.trash,
      leftWidgets: [
        AnimationBtn(
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back,
            size: 24,
            color: context.theme.iconTheme.color,
          ),
        ),
        const SizedBox(width: 12),
      ],
      rightWidgets: [
        if (trashState.deletedTasks.isNotEmpty)
          AnimationBtn(
            onPressed: () => _showEmptyTrashDialog(context, ref),
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
                    l10n.emptyTrash,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
      body: Builder(builder: (context) {
        if (trashState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (trashState.deletedTasks.isEmpty) {
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
                  l10n.trashEmpty,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.trashEmptyDesc,
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
          itemCount: trashState.deletedTasks.length,
          itemBuilder: (context, index) {
            final task = trashState.deletedTasks[index];
            return _buildDeletedTaskCard(context, ref, task);
          },
        );
      }),
    );
  }

  Widget _buildDeletedTaskCard(BuildContext context, WidgetRef ref, Task task) {
    // 如果task本身被删除，使用task的删除时间；否则使用最早被删除的todo的时间
    int displayDeletedAt = task.deletedAt;
    if (displayDeletedAt == 0 && task.todos != null && task.todos!.isNotEmpty) {
      // 找到最早被删除的todo
      final deletedTodos = task.todos!.where((t) => t.deletedAt > 0).toList();
      if (deletedTodos.isNotEmpty) {
        displayDeletedAt = deletedTodos.map((t) => t.deletedAt).reduce((a, b) => a < b ? a : b);
      }
    }
    final deletedTime = ref
        .read(trashControllerProvider.notifier)
        .formatDeletedAt(displayDeletedAt);
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
                            '${l10n.deletedAt}: $deletedTime',
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
                          Text(l10n.restore),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.trashCan, size: 14, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(l10n.permanentDelete, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'restore') {
                      _restoreTask(context, ref, task);
                    } else if (value == 'delete') {
                      _permanentDeleteTask(context, ref, task);
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
                    '${l10n.deletedTodos} (${deletedTodos.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...deletedTodos.map(
                      (todo) => _buildDeletedTodoItem(context, ref, task, todo)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeletedTodoItem(
      BuildContext context, WidgetRef ref, Task task, Todo todo) {
    final deletedTime =
        ref.read(trashControllerProvider.notifier).formatDeletedAt(todo.deletedAt);
    
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
                onPressed: () => _restoreTodo(context, ref, task, todo),
                tooltip: l10n.restore,
              ),
              // 永久删除按钮
              IconButton(
                icon: const Icon(FontAwesomeIcons.trashCan, size: 16),
                color: Colors.red,
                onPressed: () => _permanentDeleteTodo(context, ref, task, todo),
                tooltip: l10n.permanentDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _restoreTask(BuildContext context, WidgetRef ref, Task task) {
    showToast(
      '${l10n.sureRestoreTask}「${task.title}」',
      alwaysShow: true,
      confirmMode: true,
      onYesCallback: () async {
        final success = await ref
            .read(trashControllerProvider.notifier)
            .restoreTask(task.uuid);
        if (success) {
          showSuccessNotification(l10n.taskRestored);
          // 刷新主页数据
          try {
            await ref.read(homeControllerProvider.notifier).refreshData();
          } catch (e) {
            // HomeController可能未初始化，忽略错误
          }
        } else {
          showErrorNotification(l10n.restoreFailed);
        }
      },
    );
  }

  void _permanentDeleteTask(BuildContext context, WidgetRef ref, Task task) {
    showToast(
      '${l10n.surePermanentDeleteTask}「${task.title}」',
      alwaysShow: true,
      confirmMode: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success = await ref
            .read(trashControllerProvider.notifier)
            .permanentDeleteTask(task.uuid);
        if (success) {
          showSuccessNotification(l10n.taskPermanentlyDeleted);
        } else {
          showErrorNotification(l10n.permanentDeleteFailed);
        }
      },
    );
  }

  void _restoreTodo(BuildContext context, WidgetRef ref, Task task, Todo todo) {
    showToast(
      '${l10n.sureRestoreTodo}「${todo.title}」',
      alwaysShow: true,
      confirmMode: true,
      onYesCallback: () async {
        final success = await ref
            .read(trashControllerProvider.notifier)
            .restoreTodo(task.uuid, todo.uuid);
        if (success) {
          showSuccessNotification(l10n.todoRestored);
          // 如果任务也恢复了，刷新主页数据
          try {
            await ref.read(homeControllerProvider.notifier).refreshData();
          } catch (e) {
            // HomeController可能未初始化，忽略错误
          }
        } else {
          showErrorNotification(l10n.restoreFailed);
        }
      },
    );
  }

  void _permanentDeleteTodo(
      BuildContext context, WidgetRef ref, Task task, Todo todo) {
    showToast(
      '${l10n.surePermanentDeleteTodo}「${todo.title}」',
      alwaysShow: true,
      confirmMode: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success = await ref
            .read(trashControllerProvider.notifier)
            .permanentDeleteTodo(task.uuid, todo.uuid);
        if (success) {
          showSuccessNotification(l10n.todoPermanentlyDeleted);
        } else {
          showErrorNotification(l10n.permanentDeleteFailed);
        }
      },
    );
  }

  void _showEmptyTrashDialog(BuildContext context, WidgetRef ref) {
    showToast(
      l10n.sureEmptyTrash,
      alwaysShow: true,
      confirmMode: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        final success =
            await ref.read(trashControllerProvider.notifier).emptyTrash();
        if (success) {
          showSuccessNotification(l10n.trashEmptied);
        } else {
          showErrorNotification(l10n.emptyTrashFailed);
        }
      },
    );
  }
}

