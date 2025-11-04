import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/keys/dialog_keys.dart';
import 'package:TodoCat/widgets/dpd_menu_btn.dart';
import 'package:TodoCat/pages/home/components/todo/add_todo_card_btn.dart';
import 'package:TodoCat/pages/home/components/todo/todo_card.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:TodoCat/controllers/task_dialog_ctr.dart';
import 'package:TodoCat/widgets/task_dialog.dart';
import 'package:TodoCat/services/dialog_service.dart';
import 'dart:async';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key, 
    required Task task,
    ScrollController? parentScrollController, // 保留但不使用，避免破坏调用
    this.showTodos = true, // 是否显示内部 todo 列表，默认显示
  }) : _task = task;
  final Task _task;
  final bool showTodos; // 新增参数，控制是否显示内部 todo 列表

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
        final to = (position.pixels - scrollSpeed).clamp(0.0, position.maxScrollExtent);
        _scrollController.jumpTo(to);
      } else if (pointerDy > height - edgeMargin && position.pixels < position.maxScrollExtent) {
        final to = (position.pixels + scrollSpeed).clamp(0.0, position.maxScrollExtent);
        _scrollController.jumpTo(to);
      }
    }

    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => scrollTick());
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
                            size: colorAndIcon[1] == FontAwesomeIcons.pencil
                                ? 18
                                : 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Tooltip(
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
                                dialog: const TaskDialog(),
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
                                  // 只在删除失败时显示通知，成功时不添加消息到消息中心
                                  if (!isDeleted) {
                                    0.5.delay(() {
                                      showErrorNotification(
                                        "${"task".tr} '${widget._task.title.tr}' ${"deletionFailed".tr}",
                                      );
                                    });
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
                            final canScrollDown = _scrollController.offset < _scrollController.position.maxScrollExtent;
                            
                            // 只有当需要滚动时才处理
                            if ((scrollDelta < 0 && canScrollUp) || (scrollDelta > 0 && canScrollDown)) {
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
                          final local = (context.findRenderObject() as RenderBox?)?.globalToLocal(event.position);
                          if (local != null) {
                            _startAutoScroll(local.dy, context);
                          }
                        }
                      },
                      onPointerUp: (event) {
                        _stopAutoScroll();
                      },
                      child: Obx(
                        () {
                          // 安全地获取最新的任务状态
                          final currentTask = _homeCtrl.allTasks.firstWhere(
                            (task) => task.uuid == widget._task.uuid,
                            orElse: () => widget._task,
                          );
                          // 过滤已删除的todos
                          final todos = (currentTask.todos ?? []).where((todo) => todo.deletedAt == 0).toList();
                          
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
                            physics: const ClampingScrollPhysics(), // 限制滚动范围，不影响父级 x 轴滚动
                            onReorder: (oldIndex, newIndex) {
                              try {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                _homeCtrl.reorderTodo(widget._task.uuid, oldIndex, newIndex);
                              } catch (e) {
                                print('Reorder error: $e');
                              }
                            },
                            onReorderStart: (index) {
                              try {
                                _homeCtrl.startDragging();
                                _isDragging = true;
                              } catch (e) {
                                print('ReorderStarted error: $e');
                              }
                            },
                            onReorderEnd: (index) {
                              try {
                                _homeCtrl.endDragging();
                                _isDragging = false;
                                _stopAutoScroll();
                              } catch (e) {
                                print('ReorderEnd error: $e');
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
                                child: TodoCard(
                                  taskId: widget._task.uuid,
                                  todo: todo,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );

    if (showContainer) {
      return Container(
        width: context.isPhone ? 0.9.sw : 260,
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.4, color: context.theme.dividerColor),
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
    } else {
      // showTodos 为 false 时，只返回内容，不包裹 Container
      // Container decoration 由外部的 DragAndDropList 提供
      return SizedBox(
        width: context.isPhone ? 0.9.sw : 260,
        child: content,
      );
    }
  }
}
