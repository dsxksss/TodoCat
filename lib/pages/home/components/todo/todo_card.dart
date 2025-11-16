import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/controllers/todo_detail_ctr.dart';
import 'package:TodoCat/pages/home/components/tag.dart';
import 'package:TodoCat/core/utils/date_time.dart';
import 'package:TodoCat/keys/dialog_keys.dart';
import 'package:TodoCat/widgets/dpd_menu_btn.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:TodoCat/controllers/todo_dialog_ctr.dart';
import 'package:TodoCat/widgets/todo_dialog.dart';
import 'package:TodoCat/services/dialog_service.dart';
import 'package:TodoCat/widgets/todo_detail_dialog.dart';
import 'package:TodoCat/widgets/select_workspace_and_task_dialog.dart';
import 'package:TodoCat/controllers/workspace_ctr.dart';
import 'package:TodoCat/data/services/repositorys/task.dart';
import 'package:TodoCat/widgets/duplicate_name_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class TodoCard extends StatelessWidget {
  TodoCard({
    super.key,
    required this.taskId,
    required this.todo,
    this.outerMargin,
    this.compact = false,
  });

  final String taskId;
  final Todo todo;
  final HomeController _homeCtrl = Get.find();
  final EdgeInsets? outerMargin;
  final bool compact;

  /// 获取显示标题（直接返回todo标题，因为左下角已经显示创建时间了）
  String _getDisplayTitle() {
    return todo.title;
  }

  /// 格式化日期时间（不显示年份）
  String _formatDateTimeWithoutYear(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    // 如果是今年，不显示年份
    if (dateTime.year == now.year) {
      return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // 如果不是今年，显示年份（但这种情况应该很少）
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Color _getPriorityColor() {
    switch (todo.priority) {
      case TodoPriority.lowLevel:
        return const Color.fromRGBO(46, 204, 147, 1);
      case TodoPriority.mediumLevel:
        return const Color.fromARGB(255, 251, 136, 94);
      case TodoPriority.highLevel:
        return const Color.fromARGB(255, 251, 98, 98);
    }
  }

  bool _isOverdue() {
    if (todo.dueDate <= 0 || todo.status == TodoStatus.done) {
      return false;
    }
    final now = DateTime.now();
    final dueDate = DateTime.fromMillisecondsSinceEpoch(todo.dueDate);
    return now.isAfter(dueDate);
  }

  Color _getStatusColor() {
    if (_isOverdue()) {
      return Colors.red;
    }
    switch (todo.status) {
      case TodoStatus.todo:
        return Colors.orange;
      case TodoStatus.inProgress:
        return Colors.blue;
      case TodoStatus.done:
        return Colors.green;
    }
  }

  String _getStatusText() {
    if (_isOverdue()) {
      return "overdue".tr;
    }
    switch (todo.status) {
      case TodoStatus.todo:
        return 'todo'.tr;
      case TodoStatus.inProgress:
        return 'inProgress'.tr;
      case TodoStatus.done:
        return 'done'.tr;
    }
  }

  Future<bool> _handleDelete() async {
    return await _homeCtrl.deleteTodo(taskId, todo.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return buildTodoContent(context);
  }

  Widget buildTodoContent(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          final dialogTag = 'todo_detail_dialog_${todo.uuid}';
          SmartDialog.show(
            tag: dialogTag,
            alignment: Alignment.center,
            animationTime: const Duration(milliseconds: 250),
            animationBuilder: (animController, child, _) {
              return FadeTransition(
                opacity: animController,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.9,
                    end: 1.0,
                  ).animate(CurvedAnimation(
                    parent: animController,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                ),
              );
            },
            builder: (_) => TodoDetailDialog(
              todoId: todo.uuid,
              taskId: taskId,
            ),
            clickMaskDismiss: true,
            onDismiss: () {
              // 清理 controller，避免内存泄漏
              Get.delete<TodoDetailController>(tag: dialogTag);
            },
          );
        },
        child: Container(
          margin: outerMargin ?? const EdgeInsets.only(left: 15, right: 15, bottom: 15),
          padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            border: Border.all(color: context.theme.dividerColor),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: context.theme.shadowColor.withValues(alpha: .1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.solidCircle,
                            size: 11,
                            color: _getPriorityColor(),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 1.0),
                              child: Tooltip(
                                message: todo.title,
                                preferBelow: false,
                                child: Text(
                                  _getDisplayTitle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DPDMenuBtn(
                      tag: dropDownMenuBtnTag,
                      menuItems: [
                        MenuItem(
                          title: 'edit',
                          iconData: FontAwesomeIcons.penToSquare,
                          callback: () async {
                            final todoDialogController = Get.put(
                              AddTodoDialogController(),
                              tag: 'edit_todo_dialog',
                              permanent: true,
                            );
                            todoDialogController.initForEditing(taskId, todo);

                            DialogService.showFormDialog(
                              tag: addTodoDialogTag,
                              dialog: const TodoDialog(
                                  dialogTag: 'edit_todo_dialog'),
                            );
                          },
                        ),
                        MenuItem(
                          title: 'moveTodoToWorkspace',
                          iconData: FontAwesomeIcons.folderOpen,
                          callback: () {
                            // 获取当前工作空间ID和task信息
                            String currentWorkspaceId = 'default';
                            if (Get.isRegistered<WorkspaceController>()) {
                              final workspaceCtrl = Get.find<WorkspaceController>();
                              currentWorkspaceId = workspaceCtrl.currentWorkspaceId.value;
                            }
                            
                            // 显示选择工作空间和任务对话框
                            showSelectWorkspaceAndTaskDialog(
                              currentTaskId: taskId,
                              currentWorkspaceId: currentWorkspaceId,
                              onSelected: (targetWorkspaceId, targetTaskId) async {
                                // 获取源工作空间、目标工作空间和任务名称
                                String sourceWorkspaceName = 'defaultWorkspace'.tr;
                                String targetWorkspaceName = 'defaultWorkspace'.tr;
                                String sourceTaskName = '';
                                String targetTaskName = '';
                                
                                if (Get.isRegistered<WorkspaceController>()) {
                                  final workspaceCtrl = Get.find<WorkspaceController>();
                                  
                                  // 获取当前任务信息（用于显示源工作空间）
                                  try {
                                    final taskRepository = await TaskRepository.getInstance();
                                    final sourceTask = await taskRepository.readOne(taskId);
                                    if (sourceTask != null) {
                                      sourceTaskName = sourceTask.title;
                                      
                                      // 获取源工作空间名称
                                      final sourceWorkspace = workspaceCtrl.workspaces.firstWhereOrNull(
                                        (w) => w.uuid == sourceTask.workspaceId,
                                      );
                                      if (sourceWorkspace != null) {
                                        sourceWorkspaceName = sourceWorkspace.uuid == 'default'
                                            ? 'defaultWorkspace'.tr
                                            : sourceWorkspace.name;
                                      }
                                    }
                                  } catch (e) {
                                    // 忽略错误
                                  }
                                  
                                  // 获取目标工作空间名称
                                  final targetWorkspace = workspaceCtrl.workspaces.firstWhereOrNull(
                                    (w) => w.uuid == targetWorkspaceId,
                                  );
                                  if (targetWorkspace != null) {
                                    targetWorkspaceName = targetWorkspace.uuid == 'default'
                                        ? 'defaultWorkspace'.tr
                                        : targetWorkspace.name;
                                  }
                                }
                                
                                // 获取目标任务名称
                                try {
                                  final taskRepository = await TaskRepository.getInstance();
                                  final targetTask = await taskRepository.readOne(targetTaskId);
                                  if (targetTask != null) {
                                    targetTaskName = targetTask.title;
                                  }
                                } catch (e) {
                                  // 忽略错误
                                }
                                
                                // 保存原始信息用于撤销
                                final originalTaskId = taskId;
                                final originalWorkspaceId = currentWorkspaceId;
                                // 保存目标taskId，用于撤销时直接使用
                                final targetTaskIdForUndo = targetTaskId;
                                
                                // 先尝试移动，检查是否有同名todo
                                final hasDuplicate = await _homeCtrl.moveTodoToWorkspaceTask(
                                  taskId,
                                  todo.uuid,
                                  targetWorkspaceId,
                                  targetTaskId,
                                );
                                
                                // 如果返回false，可能是存在同名todo，需要显示对话框
                                if (!hasDuplicate) {
                                  // 检查是否真的存在同名todo
                                  try {
                                    final taskRepository = await TaskRepository.getInstance();
                                    final targetTask = await taskRepository.readOne(targetTaskId);
                                    if (targetTask != null) {
                                      final duplicateTodo = (targetTask.todos ?? []).firstWhereOrNull(
                                        (t) => t.title == todo.title && t.uuid != todo.uuid && t.deletedAt == 0,
                                      );
                                      
                                      if (duplicateTodo != null) {
                                        // 显示同名处理对话框
                                        showDuplicateNameDialog(
                                          itemName: todo.title,
                                          itemType: 'todo',
                                          sourceWorkspaceName: sourceWorkspaceName,
                                          targetWorkspaceName: targetWorkspaceName,
                                          onActionSelected: (action) async {
                                            if (action == DuplicateNameAction.cancel) {
                                              return;
                                            }
                                            
                                            final success = await _homeCtrl.moveTodoToWorkspaceTask(
                                              taskId,
                                              todo.uuid,
                                              targetWorkspaceId,
                                              targetTaskId,
                                              duplicateAction: action,
                                            );
                                            
                                            if (success) {
                                              // 显示带撤销功能的通知
                                              final todoTitle = todo.title;
                                              String message;
                                              if (sourceWorkspaceName != targetWorkspaceName || sourceTaskName != targetTaskName) {
                                                message = '「$todoTitle」${'todoMovedToWorkspace'.tr}「$sourceWorkspaceName/$sourceTaskName」→「$targetWorkspaceName/$targetTaskName」';
                                              } else {
                                                message = '「$todoTitle」${'todoMovedToWorkspace'.tr}「$targetWorkspaceName/$targetTaskName」';
                                              }
                                              
                                              showUndoToast(
                                                message,
                                                () async {
                                                  final isUndone = await _homeCtrl.undoMoveTodoToWorkspaceTask(
                                                    todo.uuid,
                                                    originalTaskId,
                                                    originalWorkspaceId,
                                                    targetTaskIdForUndo,
                                                  );
                                                  if (isUndone) {
                                                    showSuccessNotification(
                                                      '「$todoTitle」${'todoRestored'.tr}',
                                                      saveToNotificationCenter: false,
                                                    );
                                                  } else {
                                                    showErrorNotification(
                                                      '「$todoTitle」${'restoreFailed'.tr}',
                                                    );
                                                  }
                                                },
                                                countdownSeconds: 5,
                                              );
                                            } else {
                                              showErrorNotification('todoMoveFailed'.tr);
                                            }
                                          },
                                        );
                                        return;
                                      }
                                    }
                                  } catch (e) {
                                    // 忽略错误，继续执行
                                  }
                                  
                                  // 不是同名问题，是其他错误
                                  showErrorNotification('todoMoveFailed'.tr);
                                  return;
                                }
                                
                                // 移动成功
                                if (hasDuplicate) {
                                  // 显示带撤销功能的通知
                                  final todoTitle = todo.title;
                                  String message;
                                  if (sourceWorkspaceName != targetWorkspaceName || sourceTaskName != targetTaskName) {
                                    message = '「$todoTitle」${'todoMovedToWorkspace'.tr}「$sourceWorkspaceName/$sourceTaskName」→「$targetWorkspaceName/$targetTaskName」';
                                  } else {
                                    message = '「$todoTitle」${'todoMovedToWorkspace'.tr}「$targetWorkspaceName/$targetTaskName」';
                                  }
                                  
                                  showUndoToast(
                                    message,
                                    () async {
                                      final isUndone = await _homeCtrl.undoMoveTodoToWorkspaceTask(
                                        todo.uuid,
                                        originalTaskId,
                                        originalWorkspaceId,
                                        targetTaskIdForUndo, // 传递目标taskId，避免查找失败
                                      );
                                      if (isUndone) {
                                        showSuccessNotification(
                                          '「$todoTitle」${'todoRestored'.tr}',
                                          saveToNotificationCenter: false,
                                        );
                                      } else {
                                        showErrorNotification(
                                          '「$todoTitle」${'restoreFailed'.tr}',
                                        );
                                      }
                                    },
                                    countdownSeconds: 5,
                                  );
                                } else {
                                  showErrorNotification('todoMoveFailed'.tr);
                                }
                              },
                            );
                          },
                        ),
                        MenuItem(
                          title: 'delete',
                          iconData: FontAwesomeIcons.trashCan,
                          callback: () => {
                            showToast(
                              "sureDeleteTodo".tr,
                              alwaysShow: true,
                              confirmMode: true,
                              toastStyleType: TodoCatToastStyleType.error,
                              onYesCallback: () async {
                                final bool isDeleted = await _handleDelete();
                                // 只在删除失败时显示通知
                                if (!isDeleted) {
                                  0.5.delay(() {
                                    showErrorNotification(
                                      "${"todo".tr} '${todo.title}' ${"deletionFailed".tr}",
                                    );
                                  });
                                } else {
                                  // 删除成功，显示undo toast
                                  showUndoToast(
                                    "todoDeleted".tr,
                                    () async {
                                      final bool isUndone = await _homeCtrl.undoTodo(taskId, todo.uuid);
                                      if (isUndone) {
                                        showSuccessNotification(
                                          "${"todo".tr} '${todo.title}' ${"todoRestored".tr}",
                                          saveToNotificationCenter: false,
                                        );
                                      } else {
                                        showErrorNotification(
                                          "${"todo".tr} '${todo.title}' ${"restoreFailed".tr}",
                                        );
                                      }
                                    },
                                    countdownSeconds: 5,
                                  );
                                }
                              },
                            )
                          },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (todo.tagsWithColor.isNotEmpty)
                  const SizedBox(
                    height: 10,
                  ),
                if (todo.tagsWithColor.isNotEmpty)
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: todo.tagsWithColor.take(3).map((tagWithColor) {
                                // 限制标签文本长度
                                String displayText = tagWithColor.name;
                                if (tagWithColor.name.length > 8) {
                                  displayText = '${tagWithColor.name.substring(0, 6)}...';
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Tag(
                                    tag: displayText,
                                    color: tagWithColor.color, // 使用存储的颜色
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (todo.tagsWithColor.length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${todo.tagsWithColor.length - 3}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(
                            size: 15,
                            FontAwesomeIcons.clock,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Flexible(
                            child: Tooltip(
                              message: timestampToDateTime(todo.createdAt),
                              preferBelow: false,
                              child: Text(
                                _formatDateTimeWithoutYear(todo.createdAt),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 6 : 15)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
