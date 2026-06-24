import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/core/utils/responsive.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/components/task/task_card.dart';
import 'package:todo_cat/pages/home/components/todo/todo_card.dart';

/// 自研看板组件（替代 appflowy_board）。
///
/// 每列结构：固定头部（TaskCard）+ Expanded 内的纵向滚动列表（TodoCard），
/// 因此列内容超高时会**独立滚动**而非溢出——彻底解决原 appflowy_board 列表
/// 不滚动导致的 BOTTOM OVERFLOWED 问题。
///
/// 拖拽（基于 [Draggable] / [DragTarget]，桌面即时拖、移动端长按拖）：
/// - 列内重排：拖动 todo 卡到本列的间隙；
/// - 跨列移动：拖动 todo 卡到其它列的间隙（状态按目标列标题自动变更，由 controller 处理）；
/// - 列重排：拖动列头到目标列位置。
class KanbanBoard extends ConsumerStatefulWidget {
  const KanbanBoard({
    super.key,
    required this.tasks,
    this.listWidth = 260.0,
    this.scrollController,
    this.onTaskContextReady,
    this.onDragEnded,
  });

  final List<Task> tasks;
  final double listWidth;
  final ScrollController? scrollController;

  /// 当某列头部 context 可用时回调（移动端吸附定位用）。
  final void Function(String taskId, BuildContext context)? onTaskContextReady;

  /// 任意一次拖拽结束（含投放与取消）后回调（移动端吸附用）。
  final VoidCallback? onDragEnded;

  @override
  ConsumerState<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends ConsumerState<KanbanBoard> {
  HomeController get _controller => ref.read(homeControllerProvider.notifier);

  late final ScrollController _scrollController;
  bool _ownsScrollController = false;

  // 每列待办列表各自的纵向滚动控制器与定位 Key（用于拖拽时列内自动滚动）。
  final Map<String, ScrollController> _columnScrollers = {};
  final Map<String, GlobalKey> _columnBodyKeys = {};

  // 边缘自动滚动
  bool _isDragging = false;
  Offset? _pointer;
  Timer? _autoScrollTimer;

  static const double _columnGap = 8.0;

  ScrollController _columnScroller(String id) =>
      _columnScrollers.putIfAbsent(id, () => ScrollController());

  GlobalKey _columnBodyKey(String id) =>
      _columnBodyKeys.putIfAbsent(id, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _ownsScrollController = true;
    }
  }

  @override
  void dispose() {
    _stopAutoScroll();
    for (final c in _columnScrollers.values) {
      c.dispose();
    }
    if (_ownsScrollController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  List<Todo> _activeTodos(Task task) =>
      (task.todos ?? const <Todo>[]).where((t) => t.deletedAt == 0).toList();

  // ---------------------------------------------------------------------------
  // 拖拽结果处理
  // ---------------------------------------------------------------------------

  void _onDragStart() {
    // setState：让各列出现可投放的槽位（间隙），并使源卡片塌陷。
    setState(() => _isDragging = true);
  }

  void _onDragFinish() {
    _stopAutoScroll();
    if (mounted) setState(() => _isDragging = false);
    widget.onDragEnded?.call();
  }

  /// 投放 todo 到 [toTaskId] 列的间隙 [toGapIndex]。
  Future<void> _handleTodoDrop(
      _TodoDrag drag, String toTaskId, int toGapIndex) async {
    if (drag.fromTaskId == toTaskId) {
      // 同列重排：reorderTodoInSameTask 内部 removeAt(old) 再 insert(new)，
      // 因此当向下移动（间隙在原位置之后）时目标索引需 -1。
      final newIndex =
          toGapIndex > drag.fromIndex ? toGapIndex - 1 : toGapIndex;
      if (newIndex == drag.fromIndex) return;
      await _controller.reorderTodoInSameTask(toTaskId, drag.todo, newIndex);
    } else {
      // 跨列移动到指定位置（状态变更由 controller 依据目标列标题处理）。
      await _controller.moveTodoToTaskAt(
          drag.fromTaskId, toTaskId, drag.todo.uuid, toGapIndex);
    }
  }

  // ---------------------------------------------------------------------------
  // 边缘自动滚动
  // ---------------------------------------------------------------------------

  void _maybeAutoScroll() {
    if (_isDragging && _pointer != null && mounted) {
      _autoScrollTimer ??=
          Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (!mounted || !_isDragging || _pointer == null) {
          _stopAutoScroll();
          return;
        }
        _autoScrollTick();
      });
    } else {
      _stopAutoScroll();
    }
  }

  /// 每帧根据最新指针位置滚动：横向滚动整块看板、纵向滚动指针所在的那一列。
  void _autoScrollTick() {
    final p = _pointer!;

    // 横向：整块看板（靠近左右屏幕边缘）。
    if (_scrollController.hasClients) {
      final screenWidth = MediaQuery.of(context).size.width;
      const edge = 60.0;
      final maxSpeed = context.isPhone ? 6.0 : 16.0;
      double dx = 0;
      if (p.dx < edge) {
        dx = -maxSpeed * ((edge - p.dx) / edge);
      } else if (p.dx > screenWidth - edge) {
        dx = maxSpeed * ((p.dx - (screenWidth - edge)) / edge);
      }
      if (dx != 0) {
        final pos = _scrollController.position;
        final t =
            (_scrollController.offset + dx).clamp(0.0, pos.maxScrollExtent);
        if (t != _scrollController.offset) _scrollController.jumpTo(t);
      }
    }

    // 纵向：指针所在那一列的待办列表（靠近该列上/下边缘）。
    for (final entry in _columnBodyKeys.entries) {
      final ctrl = _columnScrollers[entry.key];
      if (ctrl == null || !ctrl.hasClients) continue;
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (p.dx < rect.left || p.dx > rect.right) continue; // 不在这一列
      const vedge = 60.0;
      double dy = 0;
      if (p.dy < rect.top + vedge) {
        dy = -14.0 * ((rect.top + vedge - p.dy).clamp(0.0, vedge) / vedge);
      } else if (p.dy > rect.bottom - vedge) {
        dy = 14.0 * ((p.dy - (rect.bottom - vedge)).clamp(0.0, vedge) / vedge);
      }
      if (dy != 0) {
        final pos = ctrl.position;
        final t =
            (ctrl.offset + dy).clamp(pos.minScrollExtent, pos.maxScrollExtent);
        if (t != ctrl.offset) ctrl.jumpTo(t);
      }
      break; // 只滚动指针所在的那一列
    }
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  // ---------------------------------------------------------------------------
  // 构建
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isPhone = context.isPhone;

    return Listener(
      onPointerMove: (e) {
        _pointer = e.position;
        _maybeAutoScroll();
      },
      onPointerUp: (_) => _stopAutoScroll(),
      onPointerCancel: (_) => _stopAutoScroll(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height =
              constraints.maxHeight.isFinite ? constraints.maxHeight : 600.0;
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              // 列头作为唯一拖拽手柄，禁用默认整项拖拽手柄。
              buildDefaultDragHandles: false,
              scrollController: _scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: widget.tasks.length,
              onReorder: _onReorderColumns,
              onReorderEnd: (_) => widget.onDragEnded?.call(),
              proxyDecorator: _columnProxyDecorator,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                final w = widget.listWidth + _columnGap * 2;
                return ConstrainedBox(
                  key: ValueKey(task.uuid),
                  // 列高随内容收缩，但不超过视口高度（超出则列内滚动）。
                  constraints: BoxConstraints(
                    minWidth: w,
                    maxWidth: w,
                    maxHeight: height,
                  ),
                  child: _buildColumn(task, index, isPhone),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onReorderColumns(int oldIndex, int newIndex) {
    // ReorderableListView 约定：向后移动时 newIndex 含占位，需要 -1。
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex == oldIndex) {
      widget.onDragEnded?.call();
      return;
    }
    _controller.reorderTask(oldIndex, newIndex);
    widget.onDragEnded?.call();
  }

  /// 列拖动时的浮动样式：整列带阴影浮起，背景透明（不盖白底）。
  Widget _columnProxyDecorator(
      Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Material(
          color: Colors.transparent,
          elevation: 10 * animation.value,
          shadowColor: Colors.black54,
          borderRadius: BorderRadius.circular(10),
          child: child,
        );
      },
    );
  }

  Widget _buildColumn(Task task, int index, bool isPhone) {
    final todos = _activeTodos(task);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _columnGap),
      child: Builder(
        builder: (columnContext) {
          // 暴露列头 context（移动端吸附定位用）。
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onTaskContextReady?.call(task.uuid, columnContext);
            }
          });
          // 整列作为 todo 投放区：拖到该 task 任意位置都能放入；落在某张卡片上时由
          // 卡片自身的精确槽位处理（更内层优先），其余区域追加到该 task 末尾。
          return DragTarget<_TodoDrag>(
            onWillAcceptWithDetails: (_) => true,
            onAcceptWithDetails: (d) =>
                _handleTodoDrop(d.data, task.uuid, todos.length),
            builder: (context, candidate, rejected) {
              final todoHover = candidate.isNotEmpty;
              // 顶部对齐：横向列表会把列项拉满视口高，这里让列背景只包住内容、
              // 下方留空（壁纸），从而空列/短列不再有多余的深色块。
              return Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: _columnBackgroundColor(context),
                    borderRadius: BorderRadius.circular(10),
                    // 拖拽 todo 悬停该列时高亮整列边框（提示将放入此 task）。
                    border: Border.all(
                      color: todoHover
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildColumnHeader(task, index, isPhone),
                      Flexible(
                        // 拖拽时让「空列」的投放区填满整列高度，否则空列投放区太小、难命中。
                        fit: (todos.isEmpty && _isDragging)
                            ? FlexFit.tight
                            : FlexFit.loose,
                        child: _buildTodoList(task, todos, isPhone),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 列背景色：比卡片底色略深，使卡片在其上更分明（不透出壁纸）。
  Color _columnBackgroundColor(BuildContext context) => Color.alphaBlend(
        Colors.black.withValues(alpha: 0.18),
        Theme.of(context).cardColor,
      );

  /// 列头既是显示也是列拖拽手柄（桌面即时拖、移动端长按拖）。
  Widget _buildColumnHeader(Task task, int index, bool isPhone) {
    final headerCard = _headerVisual(task);
    if (isPhone) {
      return ReorderableDelayedDragStartListener(
        index: index,
        child: headerCard,
      );
    }
    return ReorderableDragStartListener(
      index: index,
      child: headerCard,
    );
  }

  /// 列头（标题 + 添加按钮），透明地显示在列背景之上。
  Widget _headerVisual(Task task) {
    return TaskCard(task: task, showTodos: false);
  }

  Widget _buildTodoList(Task task, List<Todo> todos, bool isPhone) {
    if (todos.isEmpty) {
      // 空列：空闲时高度 0（不留深色块）；拖拽时张开投放区。
      return _emptyTodoTarget(task.uuid);
    }

    final children = <Widget>[];
    for (var i = 0; i < todos.length; i++) {
      // 每张卡片整体是投放区：悬停时其上方张开卡片大小的槽位，卡片随之让位。
      children.add(_todoItem(task.uuid, i, _buildTodoCard(task, todos, i, isPhone)));
    }
    // 末尾投放区：投放到列表最后。
    children.add(_todoTailTarget(task.uuid, todos.length));

    // shrinkWrap：列表高度随内容收缩（由外层 Flexible 限高，超出则滚动）。
    // 外层 Container 带 Key 用于拖拽时定位该列可视区域并做纵向自动滚动。
    return Container(
      key: _columnBodyKey(task.uuid),
      child: ListView(
        controller: _columnScroller(task.uuid),
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 4),
        children: children,
      ),
    );
  }

  /// 单个待办项：DragTarget 包住「上方槽位 + 卡片」，悬停在该项任意位置都会
  /// 在卡片上方张开一个卡片大小的槽位（其余卡片下移），松手则插入到该卡片之前。
  Widget _todoItem(String taskId, int index, Widget cardDraggable) {
    return DragTarget<_TodoDrag>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _handleTodoDrop(d.data, taskId, index),
      builder: (context, candidate, rejected) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _slot(active: candidate.isNotEmpty),
            cardDraggable,
          ],
        );
      },
    );
  }

  /// 列表末尾的投放区（插入到最后）。
  Widget _todoTailTarget(String taskId, int count) {
    return DragTarget<_TodoDrag>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _handleTodoDrop(d.data, taskId, count),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        // 拖拽时给一块更大的尾部投放区（便于"拖到最后"命中）；悬停放大成槽位。
        if (active) return _slot(active: true);
        return SizedBox(height: _isDragging ? 48 : 0);
      },
    );
  }

  /// 空列的投放区：空闲时不占位；拖拽时填满整列高度，作为大投放区（便于命中）。
  Widget _emptyTodoTarget(String taskId) {
    if (!_isDragging) return const SizedBox.shrink();
    return DragTarget<_TodoDrag>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _handleTodoDrop(d.data, taskId, 0),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        final primary = Theme.of(context).colorScheme.primary;
        // 外层 Flexible 在「空列 + 拖拽」时为 tight，这个 Container 会填满整列高度。
        return Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
          decoration: BoxDecoration(
            color: active
                ? primary.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: active ? primary : Colors.white.withValues(alpha: 0.20),
              width: active ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  /// 让位间隙：拖拽悬停时卡片让开、露出列背景的空档（与列拖拽一致，无高亮框）。
  Widget _slot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: active ? 84 : 0,
    );
  }

  Widget _buildTodoCard(Task task, List<Todo> todos, int index, bool isPhone) {
    final todo = todos[index];

    // TodoCard 自带卡片底色/边框/外边距，这里不再额外包一层（避免双重边距/底色），
    // 只用 outerMargin 统一上下左右留白（露出略深的列背景作为分隔）。
    final card = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: isPhone ? 460 : 380),
      child: ClipRect(
        child: TodoCard(
          taskId: task.uuid,
          todo: todo,
          compact: true,
          outerMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
      ),
    );

    final dragData =
        _TodoDrag(fromTaskId: task.uuid, todo: todo, fromIndex: index);
    final feedback = _buildFeedback(width: widget.listWidth, child: card);

    if (isPhone) {
      return LongPressDraggable<_TodoDrag>(
        data: dragData,
        feedback: feedback,
        onDragStarted: _onDragStart,
        onDragEnd: (_) => _onDragFinish(),
        onDraggableCanceled: (_, __) => _onDragFinish(),
        childWhenDragging: const SizedBox.shrink(),
        child: card,
      );
    }
    return Draggable<_TodoDrag>(
      data: dragData,
      feedback: feedback,
      onDragStarted: _onDragStart,
      onDragEnd: (_) => _onDragFinish(),
      onDraggableCanceled: (_, __) => _onDragFinish(),
      childWhenDragging: const SizedBox.shrink(),
      child: card,
    );
  }

  Widget _buildFeedback({required double width, required Widget child}) {
    // 浮起的卡片：实心 + 阴影，像被“拎起”，与列拖拽的浮起效果一致。
    return Material(
      color: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: child,
        ),
      ),
    );
  }
}

class _TodoDrag {
  const _TodoDrag({
    required this.fromTaskId,
    required this.todo,
    required this.fromIndex,
  });

  final String fromTaskId;
  final Todo todo;
  final int fromIndex;
}
