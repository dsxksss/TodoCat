import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  // 卡片入场动画：初次加载的 todo 全部"标记为已见"（不逐卡动画，交给页面切换动画），
  // 之后**新增**的 todo 才做一次淡入上滑入场。动画结束后标记为已见并解除包裹，
  // 此时已停在终态、视觉无跳变，且不影响拖拽逻辑。
  final Set<String> _seenTodoIds = {};
  final Set<String> _pendingEntranceIds = {};
  bool _seeded = false;

  // 卡片退场动画：删除一个 todo 时，先用淡出 + 高度收拢动画把卡片"送走"，再从列表移除。
  // 仅对**软删除**(deletedAt != 0)生效，不影响拖拽移动/重排（那些不会触发退场）。
  // key = todo.uuid。_prevActive 记录上一帧各 todo 的所属列与索引，用于 diff 出被删除项。
  final Map<String, _ExitingTodo> _exiting = {};
  Map<String, _ActiveRef> _prevActive = {};

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
  // 删除退场动画
  // ---------------------------------------------------------------------------

  /// 每帧对比上一帧的"可见 todo"，找出本帧消失且属于**软删除**的项，登记为退场卡片。
  void _trackDeletionsForExit() {
    final current = <String, _ActiveRef>{};
    for (final t in widget.tasks) {
      final list = _activeTodos(t);
      for (var i = 0; i < list.length; i++) {
        current[list[i].uuid] = _ActiveRef(t.uuid, i);
      }
    }

    // 重新出现（如撤销删除）的项，若还在退场队列里，撤回退场。
    for (final uuid in current.keys) {
      _exiting.remove(uuid);
    }

    // 仅在已有"上一帧"时做 diff（跳过首帧，避免初次加载误判）。
    if (_prevActive.isNotEmpty) {
      for (final entry in _prevActive.entries) {
        final uuid = entry.key;
        if (current.containsKey(uuid)) continue; // 仍可见
        if (_exiting.containsKey(uuid)) continue; // 已在退场
        final deleted = _findSoftDeletedTodo(uuid);
        if (deleted == null) continue; // 不是删除（可能是移动到别处），不做退场
        _exiting[uuid] = _ExitingTodo(
          todo: deleted,
          taskId: entry.value.taskId,
          index: entry.value.index,
        );
        // 动画结束后从队列移除并刷新（动画 ~260ms，这里留出余量）。
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          if (_exiting.remove(uuid) != null) setState(() {});
        });
      }
    }

    _prevActive = current;
  }

  /// 在所有 task 中查找已被软删除（deletedAt != 0）的指定 todo。
  Todo? _findSoftDeletedTodo(String uuid) {
    for (final t in widget.tasks) {
      for (final td in (t.todos ?? const <Todo>[])) {
        if (td.uuid == uuid && td.deletedAt != 0) return td;
      }
    }
    return null;
  }

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

    // 首帧把现有 todo 全部标记为已见，避免初次加载逐卡入场（由页面切换动画统一处理）。
    if (!_seeded) {
      for (final t in widget.tasks) {
        for (final td in _activeTodos(t)) {
          _seenTodoIds.add(td.uuid);
        }
      }
      _seeded = true;
    }

    _trackDeletionsForExit();

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

  /// 列拖动时的浮动样式：背景透明、无阴影。
  ///
  /// 不能用 Material 的 elevation 画阴影：拖拽代理是「整列项」，而列项高度被撑满
  /// 整个视口（内容顶对齐、下方留空透出壁纸），elevation 会沿整列高度画出一大块
  /// 深色阴影矩形（一直延伸到卡片下方的空白区）。这里直接去掉阴影，仅保留圆角裁剪。
  Widget _columnProxyDecorator(
      Widget child, int index, Animation<double> animation) {
    return Material(
      type: MaterialType.transparency,
      child: child,
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
                      // 列高随内容收缩（FlexFit.loose）：空列悬停时只张开一个
                      // 卡片大小的投放区，不再撑满整列——靠蓝色边框提示即可。
                      Flexible(
                        child: _buildTodoList(task, todos, isPhone, todoHover),
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

  Widget _buildTodoList(
      Task task, List<Todo> todos, bool isPhone, bool columnHovered) {
    // 本列正在退场（删除收拢中）的卡片，按删除前索引排序。
    final exiting = _exiting.values.where((e) => e.taskId == task.uuid).toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    if (todos.isEmpty && exiting.isEmpty) {
      // 空列：空闲时高度 0（不留深色块）；仅当拖拽悬停本列时张开投放区。
      return _emptyTodoTarget(task.uuid, columnHovered);
    }

    final children = <Widget>[];
    for (var i = 0; i < todos.length; i++) {
      // 每张卡片整体是投放区：悬停时其上方张开卡片大小的槽位，卡片随之让位。
      children.add(_todoItem(task.uuid, i, _buildTodoCard(task, todos, i, isPhone)));
    }
    // 把退场卡片插回它删除前的位置，让它原地淡出收拢、下方卡片随之顺滑上移。
    for (final e in exiting) {
      children.insert(e.index.clamp(0, children.length), _buildExitingCard(e, isPhone));
    }
    // 末尾投放区：投放到列表最后（仅在拖拽悬停本列时占位，避免其它列多出高度）。
    children.add(_todoTailTarget(task.uuid, todos.length, columnHovered));

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
  ///
  /// [columnHovered] 为 true（拖拽悬停在本列）时才占一块更大的尾部投放区，
  /// 便于「拖到最后」命中；否则高度为 0——这样未被悬停的其它列不会凭空变高。
  Widget _todoTailTarget(String taskId, int count, bool columnHovered) {
    return DragTarget<_TodoDrag>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _handleTodoDrop(d.data, taskId, count),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        // 直接悬停在尾部区域上时放大成槽位；否则按是否悬停本列决定占位高度。
        if (active) return _slot(active: true);
        return SizedBox(height: columnHovered ? 48 : 0);
      },
    );
  }

  /// 空列的投放区：**整段拖拽期间**都显示一个卡片大小的投放框（尺寸固定，不随
  /// 悬停增删，避免列高在悬停边界处反复跳动造成抖动）；悬停本列时只改高亮配色。
  Widget _emptyTodoTarget(String taskId, bool columnHovered) {
    if (!_isDragging) return const SizedBox.shrink();
    return DragTarget<_TodoDrag>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _handleTodoDrop(d.data, taskId, 0),
      builder: (context, candidate, rejected) {
        // 高亮只影响配色/边框,不影响尺寸：悬停本列或正落在投放框上时点亮。
        final active = candidate.isNotEmpty || columnHovered;
        final primary = Theme.of(context).colorScheme.primary;
        // 固定一个卡片大小的高度，而非填满整列。
        return Container(
          height: 84,
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
  ///
  /// 仅在「拖拽进行中」才用 150ms 平滑张开/合拢；一旦拖拽结束（投放完成），
  /// 让位间隙立即归零、不再做收拢过渡——否则卡片落位后会再多一段「换位」动画。
  Widget _slot({required bool active}) {
    return AnimatedContainer(
      duration:
          _isDragging ? const Duration(milliseconds: 150) : Duration.zero,
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
        child: _entranceCard(todo.uuid, card),
      );
    }
    return Draggable<_TodoDrag>(
      data: dragData,
      feedback: feedback,
      onDragStarted: _onDragStart,
      onDragEnd: (_) => _onDragFinish(),
      onDraggableCanceled: (_, __) => _onDragFinish(),
      childWhenDragging: const SizedBox.shrink(),
      child: _entranceCard(todo.uuid, card),
    );
  }

  /// 新增卡片的一次性入场动画（淡入 + 轻微上滑）；已见过的卡片直接返回原样。
  /// 只包裹「就地显示」的卡片，不包裹拖拽浮层(feedback)，因此不影响拖拽手感。
  Widget _entranceCard(String uuid, Widget card) {
    if (_seenTodoIds.contains(uuid)) return card;
    _scheduleEntranceDone(uuid);
    return card
        .animate(key: ValueKey('todo_in_$uuid'))
        .fadeIn(duration: 220.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.12,
          end: 0,
          duration: 260.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// 入场动画结束后（超过动画时长）把卡片标记为已见并解除包裹：此时动画已停在终态，
  /// 解除包裹无视觉跳变，也避免之后拖拽该卡时重复触发入场。
  void _scheduleEntranceDone(String uuid) {
    if (_pendingEntranceIds.contains(uuid)) return;
    _pendingEntranceIds.add(uuid);
    Future.delayed(const Duration(milliseconds: 360), () {
      if (!mounted) return;
      _pendingEntranceIds.remove(uuid);
      setState(() => _seenTodoIds.add(uuid));
    });
  }

  /// 退场卡片：纯展示、不可交互（IgnorePointer），自带淡出 + 高度收拢动画。
  Widget _buildExitingCard(_ExitingTodo e, bool isPhone) {
    final card = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: isPhone ? 460 : 380),
      child: ClipRect(
        child: TodoCard(
          taskId: e.taskId,
          todo: e.todo,
          compact: true,
          outerMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
      ),
    );
    return _ExitingCardView(
      key: ValueKey('todo_out_${e.todo.uuid}'),
      child: IgnorePointer(child: card),
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

/// 上一帧某个可见 todo 的所属列与索引（用于 diff 出被删除项）。
class _ActiveRef {
  const _ActiveRef(this.taskId, this.index);
  final String taskId;
  final int index;
}

/// 一个正在退场（删除收拢中）的 todo 及其删除前的位置。
class _ExitingTodo {
  const _ExitingTodo({
    required this.todo,
    required this.taskId,
    required this.index,
  });
  final Todo todo;
  final String taskId;
  final int index;
}

/// 退场动画包裹：淡出 + 沿垂直方向高度收拢（下方卡片随之顺滑上移）。
class _ExitingCardView extends StatefulWidget {
  const _ExitingCardView({super.key, required this.child});
  final Widget child;

  @override
  State<_ExitingCardView> createState() => _ExitingCardViewState();
}

class _ExitingCardViewState extends State<_ExitingCardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInCubic);
    final shrink = Tween<double>(begin: 1.0, end: 0.0).animate(curve);
    return FadeTransition(
      opacity: shrink,
      child: SizeTransition(
        sizeFactor: shrink,
        axisAlignment: -1.0,
        child: widget.child,
      ),
    );
  }
}
