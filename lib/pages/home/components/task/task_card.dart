import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
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

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key, 
    required Task task,
    ScrollController? parentScrollController, // 保留但不使用，避免破坏调用
  }) : _task = task;
  final Task _task;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final HomeController _homeCtrl = Get.find();
  late final ScrollController _scrollController;
  int? _hoverInsertIndex; // 跨列悬停的插入索引，用于联动动画
  final Map<String, double> _todoHeights = {}; // 记录每个 todo 的实时高度
  String? _justInsertedTodoId; // 刚插入/移动的 todo，用于高亮
  final GlobalKey _listKey = GlobalKey(); // 用于计算本列可滚动区域
  Timer? _edgeScrollTimer;
  double _edgeScrollDir = 0; // -1 向上，1 向下，0 停止

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void _autoScrollIfNeeded(Offset globalPosition) {
    try {
      if (!_scrollController.hasClients) return;
      final ctx = _listKey.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return;
      final topLeft = box.localToGlobal(Offset.zero);
      final size = box.size;
      final localDy = globalPosition.dy - topLeft.dy;
      const edge = 60.0;
      double dir = 0;
      if (localDy < edge) {
        dir = -1;
      } else if (localDy > size.height - edge) {
        dir = 1;
      }
      if (dir == 0) {
        _stopEdgeScroll();
        return;
      }
      _startEdgeScroll(dir);
    } catch (_) {}
  }

  void _startEdgeScroll(double dir) {
    if (_edgeScrollTimer != null && _edgeScrollDir == dir) return;
    _edgeScrollDir = dir;
    _edgeScrollTimer?.cancel();
    const step = 18.0; // 每步像素（更顺滑）
    const interval = Duration(milliseconds: 16); // 接近 60fps
    _edgeScrollTimer = Timer.periodic(interval, (_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final min = 0.0;
      final next = (_scrollController.offset + step * _edgeScrollDir).clamp(min, max);
      _scrollController.jumpTo(next);
    });
  }

  void _stopEdgeScroll() {
    _edgeScrollDir = 0;
    _edgeScrollTimer?.cancel();
    _edgeScrollTimer = null;
  }

  @override
  void dispose() {
    _stopEdgeScroll();
    _scrollController.dispose();
    super.dispose();
  }

  List<dynamic> _getColorAndIcon() {
    switch (widget._task.title) {
      case 'todo':
        return [Colors.grey, FontAwesomeIcons.clipboard];
      case 'inProgress':
        return [Colors.orangeAccent, FontAwesomeIcons.pencil];
      case 'done':
        return [
          const Color.fromRGBO(46, 204, 147, 1),
          FontAwesomeIcons.circleCheck
        ];
      default:
        return [Colors.lightBlue, FontAwesomeIcons.listOl];
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosLength = widget._task.todos?.length ?? 0;
    final colorAndIcon = _getColorAndIcon();

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
      child: Stack(
        children: [
          // 顶部滚动空气墙（不改变布局，仅用于持续自动滚动）
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 64,
            child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (d) => d.data.containsKey('todoId'),
              onMove: (_) => _startEdgeScroll(-1),
              onLeave: (_) => _stopEdgeScroll(),
              onAcceptWithDetails: (_) => _stopEdgeScroll(),
              builder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // 底部滚动空气墙
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 64,
                  child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (d) => d.data.containsKey('todoId'),
              onMove: (_) => _startEdgeScroll(1),
              onLeave: (_) => _stopEdgeScroll(),
              onAcceptWithDetails: (_) => _stopEdgeScroll(),
              builder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // 原有内容
          Column(
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
                                  0.5.delay(() {
                                    if (isDeleted) {
                                      showSuccessNotification(
                                        "${"task".tr} '${widget._task.title.tr}' ${"deletedSuccessfully".tr}",
                                      );
                                    } else {
                                      showErrorNotification(
                                        "${"task".tr} '${widget._task.title.tr}' ${"deletionFailed".tr}",
                                      );
                                    }
                                  });
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
                Flexible(
                  child: Listener(
                    // 拦截滚动事件，在 todos 区域内纵向滚动，不影响外层横向滚动
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        final scrollDelta = pointerSignal.scrollDelta.dy;
                        if (_scrollController.hasClients && scrollDelta != 0) {
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
                        }
                        // 不传递事件到父组件，阻止外层横向滚动
                      }
                    },
                    child: Obx(
                      () {
                        // 安全地获取最新的任务状态
                        final currentTask = _homeCtrl.allTasks.firstWhere(
                          (task) => task.uuid == widget._task.uuid,
                          orElse: () => widget._task,
                        );
                        final todos = currentTask.todos ?? [];
                        // 列内内容 + 局部滚动空气墙（只作用于 todo 列表自身）
                        return Stack(
                          key: _listKey,
                          children: [
                            ListView(
                              controller: _scrollController,
                              padding: EdgeInsets.zero,
                          shrinkWrap: true,
                              children: [
                            for (final entry in todos.asMap().entries) ...[
                              _buildCrossTaskInsertTarget(
                                insertIndex: entry.key,
                                nextTodoUuid: entry.value.uuid,
                                isFirst: entry.key == 0,
                              ),
                              KeyedSubtree(
                                key: ValueKey(entry.value.uuid),
                                child: Stack(
                                  children: [
                                    // todo 卡片
                                    _MeasureSize(
                                      onChange: (size) {
                                        final h = size.height;
                                        if (_todoHeights[entry.value.uuid] != h) {
                                          _todoHeights[entry.value.uuid] = h;
                                        }
                                      },
                                      child: AnimatedSlide(
                                        duration: const Duration(milliseconds: 220),
                                        curve: Curves.easeOut,
                                        offset: (_hoverInsertIndex == entry.key)
                                            ? const Offset(0, 0.06)
                                            : Offset.zero,
                                        child: TodoCard(
                                          key: ValueKey(entry.value.uuid),
                                          taskId: widget._task.uuid,
                                          todo: entry.value,
                                        ),
                                      ),
                                    ),
                                    // 卡片上方扩大检测区域（上方 80px，易于触发"插到前面"）
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: -80,
                                      height: 80,
                                      child: DragTarget<Map<String, dynamic>>(
                                        onWillAcceptWithDetails: (d) => d.data.containsKey('todoId'),
                                        onMove: (d) {
                                          _autoScrollIfNeeded(d.offset);
                                          if (_hoverInsertIndex != entry.key) {
                                            setState(() => _hoverInsertIndex = entry.key);
                                          }
                                        },
                                        onLeave: (_) {
                                          if (_hoverInsertIndex == entry.key) {
                                            setState(() => _hoverInsertIndex = null);
                                          }
                                        },
                                        onAcceptWithDetails: (details) {
                                          final data = details.data;
                                          final fromTaskId = data['fromTaskId'];
                                          final todoId = data['todoId'];
                                          if (fromTaskId == widget._task.uuid) {
                                            try {
                                              final task = _homeCtrl.allTasks.firstWhere((t) => t.uuid == widget._task.uuid);
                                              final currentIndex = task.todos?.indexWhere((t) => t.uuid == todoId) ?? -1;
                                              if (currentIndex != -1) {
                                                var targetIndex = entry.key;
                                                if (currentIndex < targetIndex) targetIndex -= 1;
                                                _homeCtrl.reorderTodoInSameTask(widget._task.uuid, data['todo'], targetIndex);
                                              }
                                            } catch (_) {}
                                          } else {
                                            _homeCtrl.moveTodoToTaskAtIndex(
                                              fromTaskId,
                                              widget._task.uuid,
                                              todoId,
                                              entry.key,
                                            );
                                          }
                                          setState(() {
                                            _hoverInsertIndex = null;
                                            _justInsertedTodoId = todoId;
                                          });
                                          Future.delayed(const Duration(milliseconds: 900), () {
                                            if (!mounted) return;
                                            if (_justInsertedTodoId == todoId) {
                                              setState(() => _justInsertedTodoId = null);
                                            }
                                          });
                                          _stopEdgeScroll();
                                        },
                                        builder: (_, __, ___) => const SizedBox.shrink(),
                                      ),
                                    ),
                                    // 卡片下方扩大检测区域（下方 80px，易于触发"插到后面"）
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: -80,
                                      height: 80,
                                      child: DragTarget<Map<String, dynamic>>(
                                        onWillAcceptWithDetails: (d) => d.data.containsKey('todoId'),
                                        onMove: (d) {
                                          _autoScrollIfNeeded(d.offset);
                                          if (_hoverInsertIndex != entry.key + 1) {
                                            setState(() => _hoverInsertIndex = entry.key + 1);
                                          }
                                        },
                                        onLeave: (_) {
                                          if (_hoverInsertIndex == entry.key + 1) {
                                            setState(() => _hoverInsertIndex = null);
                                          }
                                        },
                                        onAcceptWithDetails: (details) {
                                          final data = details.data;
                                          final fromTaskId = data['fromTaskId'];
                                          final todoId = data['todoId'];
                                          final targetIdx = entry.key + 1;
                                          if (fromTaskId == widget._task.uuid) {
                                            try {
                                              final task = _homeCtrl.allTasks.firstWhere((t) => t.uuid == widget._task.uuid);
                                              final currentIndex = task.todos?.indexWhere((t) => t.uuid == todoId) ?? -1;
                                              if (currentIndex != -1) {
                                                var targetIndex = targetIdx;
                                                if (currentIndex < targetIndex) targetIndex -= 1;
                                                _homeCtrl.reorderTodoInSameTask(widget._task.uuid, data['todo'], targetIndex);
                                              }
                                            } catch (_) {}
                                          } else {
                                            _homeCtrl.moveTodoToTaskAtIndex(
                                              fromTaskId,
                                              widget._task.uuid,
                                              todoId,
                                              targetIdx,
                                            );
                                          }
                                          setState(() {
                                            _hoverInsertIndex = null;
                                            _justInsertedTodoId = todoId;
                                          });
                                          Future.delayed(const Duration(milliseconds: 900), () {
                                            if (!mounted) return;
                                            if (_justInsertedTodoId == todoId) {
                                              setState(() => _justInsertedTodoId = null);
                                            }
                                          });
                                          _stopEdgeScroll();
                                        },
                                        builder: (_, __, ___) => const SizedBox.shrink(),
                                      ),
                                    ),
                                    // 高亮层：覆盖在上，不影响布局，不遮挡外边距
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: AnimatedOpacity(
                                          duration: const Duration(milliseconds: 700),
                                          curve: Curves.easeOutCubic,
                                          opacity: _justInsertedTodoId == entry.value.uuid ? 0.16 : 0.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                              _buildCrossTaskInsertTarget(
                                insertIndex: todos.length,
                                nextTodoUuid: todos.isNotEmpty ? todos.last.uuid : null,
                              ),
                            ],
                            ),
                            // 顶部滚动空气墙：位于列表顶部，但高度较小，不覆盖第一个插入位
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              height: 20,
                              child: DragTarget<Map<String, dynamic>>(
                                onWillAcceptWithDetails: (d) => d.data.containsKey('todoId'),
                                onMove: (_) => _startEdgeScroll(-1),
                                onLeave: (_) => _stopEdgeScroll(),
                                onAcceptWithDetails: (details) {
                                  try {
                                    final data = details.data;
                                    final fromTaskId = data['fromTaskId'];
                                    final todoId = data['todoId'];
                                    if (fromTaskId == widget._task.uuid) {
                                      _homeCtrl.reorderTodoInSameTask(widget._task.uuid, data['todo'], 0);
                                    } else {
                                      _homeCtrl.moveTodoToTaskAtIndex(fromTaskId, widget._task.uuid, todoId, 0);
                                    }
                                    setState(() => _justInsertedTodoId = todoId);
                                    Future.delayed(const Duration(milliseconds: 900), () {
                                      if (!mounted) return;
                                      if (_justInsertedTodoId == todoId) {
                                        setState(() => _justInsertedTodoId = null);
                                      }
                                    });
                                  } catch (_) {}
                                  _stopEdgeScroll();
                                },
                                builder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 120,
                              child: DragTarget<Map<String, dynamic>>(
                                onWillAcceptWithDetails: (d) => d.data.containsKey('todoId'),
                                onMove: (_) => _startEdgeScroll(1),
                                onLeave: (_) => _stopEdgeScroll(),
                                onAcceptWithDetails: (details) {
                                  try {
                                    final data = details.data;
                                    final fromTaskId = data['fromTaskId'];
                                    final todoId = data['todoId'];
                                    final targetIndex = (_homeCtrl.allTasks
                                        .firstWhere((t) => t.uuid == widget._task.uuid)
                                        .todos
                                        ?.length ?? 0);
                                    if (fromTaskId == widget._task.uuid) {
                                      _homeCtrl.reorderTodoInSameTask(widget._task.uuid, data['todo'], targetIndex);
                                    } else {
                                      _homeCtrl.moveTodoToTaskAtIndex(fromTaskId, widget._task.uuid, todoId, targetIndex);
                                    }
                                    setState(() => _justInsertedTodoId = todoId);
                                    Future.delayed(const Duration(milliseconds: 900), () {
                                      if (!mounted) return;
                                      if (_justInsertedTodoId == todoId) {
                                        setState(() => _justInsertedTodoId = null);
                                      }
                                    });
                                  } catch (_) {}
                                  _stopEdgeScroll();
                                },
                                builder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
      ),
    );
  }

  // 跨 Task 拖入时的插入位置目标（仅当来源是其它 Task 的 todo 时接收）
  Widget _buildCrossTaskInsertTarget({required int insertIndex, String? nextTodoUuid, bool isFirst = false}) {
    return DragTarget<Map<String, dynamic>>(
      key: ValueKey('insert-${widget._task.uuid}-$insertIndex'),
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        final hasTodo = data.containsKey('todoId');
        final canAccept = hasTodo; // 同列/跨列都接收
        if (canAccept) {
          setState(() => _hoverInsertIndex = insertIndex);
        }
        return canAccept;
      },
      onMove: (details) {
        _autoScrollIfNeeded(details.offset);
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        final fromTaskId = data['fromTaskId'];
        final todoId = data['todoId'];
        if (fromTaskId == widget._task.uuid) {
          try {
            final task = _homeCtrl.allTasks.firstWhere((t) => t.uuid == widget._task.uuid);
            final currentIndex = task.todos?.indexWhere((t) => t.uuid == todoId) ?? -1;
            if (currentIndex != -1) {
              var targetIndex = insertIndex;
              if (currentIndex < targetIndex) targetIndex -= 1;
              _homeCtrl.reorderTodoInSameTask(widget._task.uuid, data['todo'], targetIndex);
            }
          } catch (_) {}
        } else {
          _homeCtrl.moveTodoToTaskAtIndex(
            fromTaskId,
            widget._task.uuid,
            todoId,
            insertIndex,
          );
        }
        setState(() {
          _hoverInsertIndex = null;
          _justInsertedTodoId = todoId;
        });
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          if (_justInsertedTodoId == todoId) {
            setState(() => _justInsertedTodoId = null);
          }
        });
        _stopEdgeScroll();
      },
      onLeave: (_) {
        _stopEdgeScroll();
        setState(() => _hoverInsertIndex = null);
      },
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        final baseHeight = isFirst ? 16.0 : 6.0; // 减少基础高度，让todo之间更紧凑
        final expandedHeight = (() {
          if (!(hovering || _hoverInsertIndex == insertIndex)) return baseHeight;
          final nextHeight = nextTodoUuid != null ? _todoHeights[nextTodoUuid] : null;
          // 末尾没有 next todo 时，使用已知卡片高度的均值作为基准
          double fallback = 0;
          if (nextHeight == null || nextHeight <= 0) {
            if (_todoHeights.isNotEmpty) {
              fallback = _todoHeights.values.reduce((a, b) => a + b) / _todoHeights.length;
            }
          }
          final base = (nextHeight != null && nextHeight > 0) ? nextHeight : (fallback > 0 ? fallback : 88.0);
          // 减少增量（从+10改为+6），让todo之间间距更紧凑
          return base + 6.0;
        })();
        return AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          child: Container(
            height: expandedHeight,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: hovering ? 4 : 2),
            decoration: BoxDecoration(
              color: hovering
                  ? context.theme.colorScheme.primary.withOpacity(0.22)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      },
    );
  }
}

class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});
  final Widget child;
  final ValueChanged<Size> onChange;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        final newSize = renderBox.size;
        if (_oldSize == null || _oldSize != newSize) {
          _oldSize = newSize;
          widget.onChange(newSize);
        }
      }
    });
    return widget.child;
  }
}
