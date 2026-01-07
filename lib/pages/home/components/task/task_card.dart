import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:todo_cat/pages/home/components/todo/add_todo_card_btn.dart';
import 'package:todo_cat/pages/home/components/todo/todo_card.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/controllers/task_dialog_ctr.dart';
import 'package:todo_cat/widgets/task_dialog.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/widgets/select_workspace_dialog.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/widgets/duplicate_name_dialog.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'dart:async';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required Task task,
    ScrollController? parentScrollController, // 保留但不使用，避免破坏调用
    this.showTodos = true, // 是否显示内部 todo 列表，默认显示
    this.onContextReady, // 回调：当 Context 可用时
    this.isPreview = false, // 是否为预览模式
  }) : _task = task;
  final Task _task;
  final bool showTodos; // 新增参数，控制是否显示内部 todo 列表
  final ValueChanged<BuildContext>? onContextReady;
  final bool isPreview;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final HomeController _homeCtrl = Get.find();
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // 在下一帧回调 context，确保 context 已挂载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onContextReady?.call(context);
      }
    });
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      widget.onContextReady?.call(context);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll(double pointerDy, BuildContext context) {
    const edgeMargin = 40.0;
    const scrollSpeed = 18.0;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final height = box.size.height;
    _autoScrollTimer?.cancel();

    void scrollTick() {
      if (!_scrollController.hasClients) return;
      if (!_isDragging) {
        _autoScrollTimer?.cancel();
        return;
      }
      final position = _scrollController.position;
      if (pointerDy < edgeMargin && position.pixels > 0) {
        final to = (position.pixels - scrollSpeed)
            .clamp(0.0, position.maxScrollExtent);
        _scrollController.jumpTo(to);
      } else if (pointerDy > height - edgeMargin &&
          position.pixels < position.maxScrollExtent) {
        final to = (position.pixels + scrollSpeed)
            .clamp(0.0, position.maxScrollExtent);
        _scrollController.jumpTo(to);
      }
    }

    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 16), (_) => scrollTick());
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  List<dynamic> _getColorAndIcon() {
    switch (widget._task.status) {
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

  @override
  Widget build(BuildContext context) {
    final todosLength = widget._task.todos?.length ?? 0;
    final colorAndIcon = _getColorAndIcon();

    // 如果 showTodos 为 false，不显示 Container decoration（由外部的 DragAndDropList decoration 提供）
    final showContainer = widget.showTodos;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                  ),
                  Container(
                    width: 5,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorAndIcon[0],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    colorAndIcon[1],
                    size: colorAndIcon[1] == FontAwesomeIcons.pencil ? 18 : 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    // 移动端禁用 tooltip，避免长按拖拽时误触发
                    child: context.isPhone
                        ? Text(
                            widget._task.title.tr,
                            style: GoogleFonts.getFont(
                              'Ubuntu',
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Tooltip(
                            message: widget._task.title.tr,
                            preferBelow: false,
                            child: Text(
                              widget._task.title.tr,
                              style: GoogleFonts.getFont(
                                'Ubuntu',
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                  if (todosLength > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Container(
                          width: 24,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color.fromRGBO(225, 224, 240, 1),
                          ),
                          child: Center(
                            child: Text(
                              todosLength.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(17, 10, 76, 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (!widget.isPreview)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: DPDMenuBtn(
                  tag: dropDownMenuBtnTag,
                  menuItems: [
                    MenuItem(
                      title: 'edit',
                      iconData: FontAwesomeIcons.penToSquare,
                      callback: () async {
                        final taskDialogController =
                            Get.put(TaskDialogController());
                        taskDialogController.initForEditing(widget._task);

                        DialogService.showFormDialog(
                          tag: addTaskDialogTag,
                          dialog: const TaskDialog(dialogTag: addTaskDialogTag),
                        );
                      },
                    ),
                    MenuItem(
                      title: 'moveToWorkspace',
                      iconData: FontAwesomeIcons.folderOpen,
                      callback: () {
                        // 获取当前工作空间ID
                        String currentWorkspaceId = 'default';
                        if (Get.isRegistered<WorkspaceController>()) {
                          final workspaceCtrl = Get.find<WorkspaceController>();
                          currentWorkspaceId =
                              workspaceCtrl.currentWorkspaceId.value;
                        }

                        // 显示选择工作空间对话框
                        showSelectWorkspaceDialog(
                          currentWorkspaceId: currentWorkspaceId,
                          onWorkspaceSelected: (targetWorkspaceId) async {
                            // 获取源工作空间和目标工作空间名称
                            String sourceWorkspaceName = 'defaultWorkspace'.tr;
                            String targetWorkspaceName = 'defaultWorkspace'.tr;

                            if (Get.isRegistered<WorkspaceController>()) {
                              final workspaceCtrl =
                                  Get.find<WorkspaceController>();

                              // 获取源工作空间名称
                              final sourceWorkspace =
                                  workspaceCtrl.workspaces.firstWhereOrNull(
                                (w) => w.uuid == widget._task.workspaceId,
                              );
                              if (sourceWorkspace != null) {
                                sourceWorkspaceName =
                                    sourceWorkspace.uuid == 'default'
                                        ? 'defaultWorkspace'.tr
                                        : sourceWorkspace.name;
                              }

                              // 获取目标工作空间名称
                              final targetWorkspace =
                                  workspaceCtrl.workspaces.firstWhereOrNull(
                                (w) => w.uuid == targetWorkspaceId,
                              );
                              if (targetWorkspace != null) {
                                targetWorkspaceName =
                                    targetWorkspace.uuid == 'default'
                                        ? 'defaultWorkspace'.tr
                                        : targetWorkspace.name;
                              }
                            }

                            // 保存原始工作空间ID用于撤销
                            final originalWorkspaceId =
                                widget._task.workspaceId;

                            // 先尝试移动，检查是否有同名任务
                            final hasDuplicate =
                                await _homeCtrl.moveTaskToWorkspace(
                              widget._task.uuid,
                              targetWorkspaceId,
                            );

                            // 如果返回false，可能是存在同名任务，需要显示对话框
                            if (!hasDuplicate) {
                              // 检查是否真的存在同名任务
                              try {
                                final taskRepository =
                                    await TaskRepository.getInstance();
                                final targetTasks = await taskRepository
                                    .readAll(workspaceId: targetWorkspaceId);
                                final duplicateTask =
                                    targetTasks.firstWhereOrNull(
                                  (t) =>
                                      t.title == widget._task.title &&
                                      t.uuid != widget._task.uuid,
                                );

                                if (duplicateTask != null) {
                                  // 显示同名处理对话框
                                  showDuplicateNameDialog(
                                    itemName: widget._task.title,
                                    itemType: 'task',
                                    sourceWorkspaceName: sourceWorkspaceName,
                                    targetWorkspaceName: targetWorkspaceName,
                                    onActionSelected: (action) async {
                                      if (action ==
                                          DuplicateNameAction.cancel) {
                                        return;
                                      }

                                      final success =
                                          await _homeCtrl.moveTaskToWorkspace(
                                        widget._task.uuid,
                                        targetWorkspaceId,
                                        duplicateAction: action,
                                      );

                                      if (success) {
                                        // 显示带撤销功能的通知
                                        final taskTitle = widget._task.title;
                                        String message;
                                        if (sourceWorkspaceName !=
                                            targetWorkspaceName) {
                                          message =
                                              '「$taskTitle」${'taskMovedToWorkspace'.tr}「$sourceWorkspaceName」→「$targetWorkspaceName」';
                                        } else {
                                          message =
                                              '「$taskTitle」${'taskMovedToWorkspace'.tr}「$targetWorkspaceName」';
                                        }

                                        showUndoToast(
                                          message,
                                          () async {
                                            final isUndone = await _homeCtrl
                                                .undoMoveTaskToWorkspace(
                                              widget._task.uuid,
                                              originalWorkspaceId,
                                            );
                                            if (isUndone) {
                                              showSuccessNotification(
                                                '「$taskTitle」${'taskRestored'.tr}',
                                                saveToNotificationCenter: false,
                                              );
                                            } else {
                                              showErrorNotification(
                                                '「$taskTitle」${'restoreFailed'.tr}',
                                              );
                                            }
                                          },
                                          countdownSeconds: 5,
                                        );
                                      } else {
                                        showErrorNotification(
                                            'taskMoveFailed'.tr);
                                      }
                                    },
                                  );
                                  return;
                                }
                              } catch (e) {
                                // 忽略错误，继续执行
                              }

                              // 不是同名问题，是其他错误
                              showErrorNotification('taskMoveFailed'.tr);
                              return;
                            }

                            // 移动成功
                            if (hasDuplicate) {
                              // 显示带撤销功能的通知
                              final taskTitle = widget._task.title;
                              String message;
                              if (sourceWorkspaceName != targetWorkspaceName) {
                                message =
                                    '「$taskTitle」${'taskMovedToWorkspace'.tr}「$sourceWorkspaceName」→「$targetWorkspaceName」';
                              } else {
                                message =
                                    '「$taskTitle」${'taskMovedToWorkspace'.tr}「$targetWorkspaceName」';
                              }

                              showUndoToast(
                                message,
                                () async {
                                  final isUndone =
                                      await _homeCtrl.undoMoveTaskToWorkspace(
                                    widget._task.uuid,
                                    originalWorkspaceId,
                                  );
                                  if (isUndone) {
                                    showSuccessNotification(
                                      '「$taskTitle」${'taskRestored'.tr}',
                                      saveToNotificationCenter: false,
                                    );
                                  } else {
                                    showErrorNotification(
                                      '「$taskTitle」${'restoreFailed'.tr}',
                                    );
                                  }
                                },
                                countdownSeconds: 5,
                              );
                            } else {
                              showErrorNotification('taskMoveFailed'.tr);
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
                          "sureDeleteTask".tr,
                          alwaysShow: true,
                          confirmMode: true,
                          toastStyleType: TodoCatToastStyleType.error,
                          onYesCallback: () async {
                            final bool isDeleted =
                                await _homeCtrl.deleteTask(widget._task.uuid);
                            // 只在删除失败时显示通知
                            if (!isDeleted) {
                              0.5.delay(() {
                                showErrorNotification(
                                  "${"task".tr} '${widget._task.title.tr}' ${"deletionFailed".tr}",
                                );
                              });
                            } else {
                              // 删除成功，显示undo toast
                              showUndoToast(
                                "taskDeleted".tr,
                                () async {
                                  final bool isUndone = await _homeCtrl
                                      .undoTask(widget._task.uuid);
                                  if (isUndone) {
                                    showSuccessNotification(
                                      "${"task".tr} '${widget._task.title.tr}' ${"taskRestored".tr}",
                                      saveToNotificationCenter: false,
                                    );
                                  } else {
                                    showErrorNotification(
                                      "${"task".tr} '${widget._task.title.tr}' ${"restoreFailed".tr}",
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
              )
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        if (!widget.isPreview)
          AddTodoCardBtn(
            task: widget._task,
          ),
        const SizedBox(
          height: 15,
        ),
        // 如果 showTodos 为 false，则不在内部显示 todo 列表（todo 列表在 home_page 中通过 DragAndDropLists 显示）
        if (widget.showTodos)
          Flexible(
            child: Listener(
              // 拦截滚动事件，在 todos 区域内纵向滚动，不影响外层横向滚动
              behavior: HitTestBehavior.opaque, // 完全捕获事件，阻止传播到父级
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  final scrollDelta = pointerSignal.scrollDelta.dy;
                  // 只处理纵向滚动，并且只有在scrollController可用且有可滚动内容时才处理
                  if (_scrollController.hasClients &&
                      scrollDelta != 0 &&
                      _scrollController.position.maxScrollExtent > 0) {
                    // 检查是否可以滚动（是否在边界）
                    final canScrollUp = _scrollController.offset > 0;
                    final canScrollDown = _scrollController.offset <
                        _scrollController.position.maxScrollExtent;

                    // 只有当需要滚动时才处理
                    if ((scrollDelta < 0 && canScrollUp) ||
                        (scrollDelta > 0 && canScrollDown)) {
                      // 手动处理纵向滚动
                      final newOffset = _scrollController.offset + scrollDelta;
                      _scrollController.animateTo(
                        newOffset.clamp(
                          0.0,
                          _scrollController.position.maxScrollExtent,
                        ),
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                      );
                      // 由于 behavior 是 opaque，事件已被阻止传播到父级
                    }
                    // 如果已经到达边界，不处理，但由于 opaque 行为，事件仍被阻止传播
                    // 这样可以确保在 todo 列表区域内时，无论如何都不会触发父级滚动
                  }
                }
              },
              onPointerMove: (event) {
                if (_isDragging) {
                  final local = (context.findRenderObject() as RenderBox?)
                      ?.globalToLocal(event.position);
                  if (local != null) {
                    _startAutoScroll(local.dy, context);
                  }
                }
              },
              onPointerUp: (event) {
                _stopAutoScroll();
              },
              child: ExcludeSemantics(
                // 在拖拽时排除语义，减少可访问性树更新
                child: Obx(
                  () {
                    // 安全地获取最新的任务状态
                    final currentTask = _homeCtrl.allTasks.firstWhere(
                      (task) => task.uuid == widget._task.uuid,
                      orElse: () => widget._task,
                    );
                    // 过滤已删除的todos
                    final todos = (currentTask.todos ?? [])
                        .where((todo) => todo.deletedAt == 0)
                        .toList();

                    // 使用 DragAndDropLists 显示 todo 列表（用于向后兼容，如果 showTodos 为 true）
                    if (todos.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // 使用 ReorderableListView 支持拖拽，但需要与外部的 DragAndDropLists 配合
                    // 使用 ClampingScrollPhysics 防止滚动影响父级
                    return ReorderableListView(
                      shrinkWrap: true,
                      buildDefaultDragHandles: false, // 移除默认拖拽手柄
                      scrollController: _scrollController,
                      physics:
                          const ClampingScrollPhysics(), // 限制滚动范围，不影响父级 x 轴滚动
                      onReorder: (oldIndex, newIndex) {
                        try {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          _homeCtrl.reorderTodo(
                              widget._task.uuid, oldIndex, newIndex);
                        } catch (e) {
                          if (kDebugMode) {
                            print('Reorder error: $e');
                          }
                        }
                      },
                      onReorderStart: (index) {
                        try {
                          _homeCtrl.startDragging();
                          _isDragging = true;
                        } catch (e) {
                          if (kDebugMode) {
                            print('ReorderStarted error: $e');
                          }
                        }
                      },
                      onReorderEnd: (index) {
                        try {
                          _homeCtrl.endDragging();
                          _isDragging = false;
                          _stopAutoScroll();
                        } catch (e) {
                          if (kDebugMode) {
                            print('ReorderEnd error: $e');
                          }
                        }
                      },
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Material(
                              elevation: 0,
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              child: Opacity(
                                opacity: 0.8,
                                child: child,
                              ),
                            );
                          },
                          child: child,
                        );
                      },
                      children: todos.asMap().entries.map<Widget>((entry) {
                        final index = entry.key;
                        final todo = entry.value;
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(todo.uuid),
                          index: index,
                          child: IgnorePointer(
                            ignoring: widget.isPreview,
                            child: TodoCard(
                              taskId: widget._task.uuid,
                              todo: todo,
                              isPreview: widget.isPreview,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );

    if (showContainer) {
      return LayoutBuilder(builder: (context, constraints) {
        // 使用 LayoutBuilder 获取父容器的约束，而不是直接依赖 MediaQuery
        // 这样可以避免在复杂布局中溢出
        double width = context.isPhone ? (1.sw - 100) : 270;
        if (width > constraints.maxWidth && constraints.maxWidth > 0) {
          width = constraints.maxWidth;
        }

        return Container(
          width: width,
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: context.isDarkMode
                ? <BoxShadow>[
                    BoxShadow(
                      color: context.theme.dividerColor,
                      blurRadius: 0.2,
                    ),
                  ]
                : null, // 亮色主题下不使用阴影
          ),
          child: content,
        );
      });
    } else {
      // showTodos 为 false 时，只返回内容，不包裹 Container
      // Container decoration 由外部的 DragAndDropList 提供
      return LayoutBuilder(builder: (context, constraints) {
        double width = context.isPhone ? (1.sw - 100) : 270;
        if (width > constraints.maxWidth && constraints.maxWidth > 0) {
          width = constraints.maxWidth;
        }

        return SizedBox(
          width: width,
          child: content,
        );
      });
    }
  }
}
