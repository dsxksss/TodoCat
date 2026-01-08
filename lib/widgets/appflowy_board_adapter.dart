import 'dart:async';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/components/task/task_card.dart';
import 'package:todo_cat/pages/home/components/todo/todo_card.dart';

/// 使用 AppFlowyBoard 渲染横向任务列与待办卡片
///
/// 优化策略：
/// 1. 拖拽锁定：拖拽时暂停数据同步，避免冲突
/// 2. 智能防抖：减少不必要的重建
/// 3. 生命周期保护：防止 dispose 后的操作
class AppFlowyTodosBoard extends StatefulWidget {
  const AppFlowyTodosBoard({
    super.key,
    required this.tasks,
    this.listWidth = 260.0,
    this.scrollController,
    this.onTaskContextReady, // 回调：当 Task Context 可用时
    this.onDragEnded, // 拖拽结束回调
  });

  final RxList<Task> tasks;
  final double listWidth;
  final ScrollController? scrollController; // 可选的滚动控制器
  final void Function(String taskId, BuildContext context)? onTaskContextReady;
  final VoidCallback? onDragEnded; // 拖拽结束时调用

  @override
  State<AppFlowyTodosBoard> createState() => _AppFlowyTodosBoardState();
}

class _AppFlowyTodosBoardState extends State<AppFlowyTodosBoard> {
  final HomeController _controller = Get.find();
  late final AppFlowyBoardController _boardController;
  late final ScrollController _scrollController;

  String _lastSignature = '';
  Timer? _debounceTimer;
  bool _isSyncing = false;
  bool _isDisposed = false;

  // 拖拽锁定机制
  bool _isDragging = false;
  bool _hasPendingUpdate = false;

  @override
  void initState() {
    super.initState();
    // 使用外部传入的ScrollController，如果没有则创建新的
    _scrollController = widget.scrollController ?? ScrollController();
    _boardController = AppFlowyBoardController(
      onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) async {
        if (_isDisposed || !mounted) return;
        _isDragging = false; // 拖拽结束
        await _controller.reorderTask(fromIndex, toIndex);
        // 操作完成后强制同步
        _hasPendingUpdate = true;
        _isSyncing = false; // 重置同步状态
        _lastSignature = ''; // 清空签名，强制重新计算
        if (!_isDisposed && mounted) {
          _syncGroups();
        }
        widget.onDragEnded?.call(); // 通知外部拖拽结束
      },
      onMoveGroupItem: (groupId, fromIndex, toIndex) async {
        if (_isDisposed || !mounted) return;
        _isDragging = false; // 拖拽结束
        // 直接使用 appflowy_board 提供的索引，不做调整
        await _controller.reorderTodo(groupId, fromIndex, toIndex);
        // 操作完成后强制同步
        _hasPendingUpdate = true;
        _isSyncing = false; // 重置同步状态
        _lastSignature = ''; // 清空签名，强制重新计算
        if (!_isDisposed && mounted) {
          _syncGroups();
        }
        widget.onDragEnded?.call(); // 通知外部拖拽结束
      },
      onMoveGroupItemToGroup:
          (fromGroupId, fromIndex, toGroupId, toIndex) async {
        if (_isDisposed || !mounted) return;
        _isDragging = false; // 拖拽结束
        final fromTask =
            widget.tasks.firstWhereOrNull((t) => t.uuid == fromGroupId);
        if (fromTask == null) {
          widget.onDragEnded?.call(); // 即使失败也通知外部
          return;
        }
        final todos = fromTask.todos ?? const <Todo>[];
        if (fromIndex < 0 || fromIndex >= todos.length) {
          widget.onDragEnded?.call(); // 即使失败也通知外部
          return;
        }
        final todo = todos[fromIndex];

        // 等待异步操作完成
        await _controller.moveTodoToTaskAt(
            fromGroupId, toGroupId, todo.uuid, toIndex);

        // 操作完成后强制同步
        _hasPendingUpdate = true;
        _isSyncing = false; // 重置同步状态，确保可以同步
        _lastSignature = ''; // 清空签名，强制重新计算
        if (!_isDisposed && mounted) {
          _syncGroups();
        }

        // 通知外部拖拽结束
        widget.onDragEnded?.call();
      },
    );
  }

  @override
  void didUpdateWidget(covariant AppFlowyTodosBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncGroups();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;

    if (_scrollController.hasClients) {
      try {
        _scrollController.jumpTo(_scrollController.offset);
      } catch (e) {
        // 忽略错误
      }
    }

    // 只有自己创建的ScrollController才需要dispose
    if (widget.scrollController == null) {
      try {
        _scrollController.dispose();
      } catch (e) {
        // 忽略错误
      }
    }

    Future.microtask(() {
      try {
        if (_isDisposed) {
          _boardController.dispose();
        }
      } catch (e) {
        // 忽略错误
      }
    });

    super.dispose();
  }

  /// 计算数据签名
  String _calculateSignature(List<Task> tasks) {
    final buffer = StringBuffer();
    for (final task in tasks) {
      buffer.write(task.uuid);
      buffer.write('#');
      buffer.write(task.title);
      buffer.write('#');
      buffer.write(task.deletedAt);

      final activeTodos =
          (task.todos ?? const <Todo>[]).where((todo) => todo.deletedAt == 0);
      for (final todo in activeTodos) {
        buffer.write('::');
        buffer.write(todo.uuid);
        buffer.write('#');
        buffer.write(todo.title);
        buffer.write('#');
        buffer.write(todo.status.toString());
        buffer.write('#');
        buffer.write(todo.priority.toString());
        buffer.write('#');
        buffer.write(todo.tags.join(','));
        buffer.write('#');
        buffer.write(todo.dueDate);
        buffer.write('#');
        buffer.write(todo.deletedAt);
      }
      buffer.write('|');
    }
    return buffer.toString();
  }

  /// 同步分组数据（简化版本，避免复杂的差量更新）
  void _syncGroups() {
    if (_isDisposed || !mounted) return;
    if (_isSyncing) return;

    // 拖拽时不同步，标记待更新
    if (_isDragging) {
      _hasPendingUpdate = true;
      return;
    }

    final newSignature = _calculateSignature(widget.tasks);
    final hasPending = _hasPendingUpdate;

    // 如果数据没变且没有待更新标记，跳过同步
    if (newSignature == _lastSignature && !hasPending) return;

    _debounceTimer?.cancel();

    // 拖拽后不使用防抖，立即同步以快速恢复UI
    if (hasPending) {
      _hasPendingUpdate = false;
      _performSyncImmediate(newSignature);
    } else {
      // 正常数据变化使用防抖
      _debounceTimer = Timer(const Duration(milliseconds: 50), () {
        if (_isDisposed || !mounted) {
          _debounceTimer = null;
          return;
        }
        _performSyncImmediate(newSignature);
        _debounceTimer = null;
      });
    }
  }

  /// 立即执行同步
  void _performSyncImmediate(String newSignature) {
    if (_isDisposed || !mounted || _isSyncing) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !mounted) {
        _isSyncing = false;
        return;
      }

      _isSyncing = true;

      try {
        _performSync();
        if (!_isDisposed && mounted) {
          _lastSignature = newSignature;
          // 强制刷新以确保UI正确更新
          setState(() {});
        }
      } catch (e) {
        debugPrint('Sync error: $e');
      } finally {
        _isSyncing = false;
      }
    });
  }

  /// 执行同步（全量重建，但简单稳定）
  void _performSync() {
    if (_isDisposed || !mounted) return;

    // 保存当前滚动位置（移动端修复：避免滚动位置被重置）
    double? savedScrollOffset;
    if (_scrollController.hasClients) {
      savedScrollOffset = _scrollController.offset;
    }

    try {
      final currentGroups = List<String>.from(_boardController.groupIds);

      // 移除所有旧分组
      for (final id in currentGroups) {
        if (_isDisposed || !mounted) return;
        try {
          _boardController.removeGroup(id);
        } catch (e) {
          // 忽略
        }
      }

      // 添加新分组
      for (var i = 0; i < widget.tasks.length; i++) {
        if (_isDisposed || !mounted) return;
        try {
          final group = _toGroup(widget.tasks[i]);
          _boardController.insertGroup(i, group);
        } catch (e) {
          // 忽略
        }
      }

      // 恢复滚动位置（延迟执行以确保布局完成）
      if (savedScrollOffset != null && _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isDisposed || !mounted || !_scrollController.hasClients) return;
          try {
            // 确保恢复的位置不超出边界
            final maxExtent = _scrollController.position.maxScrollExtent;
            final targetOffset = savedScrollOffset!.clamp(0.0, maxExtent);
            if ((_scrollController.offset - targetOffset).abs() > 1) {
              _scrollController.jumpTo(targetOffset);
            }
          } catch (e) {
            // 忽略
          }
        });
      }
    } catch (e) {
      debugPrint('Perform sync error: $e');
    }
  }

  AppFlowyGroupData<AppFlowyGroupItem> _toGroup(Task task) {
    final List<AppFlowyGroupItem> items = (task.todos ?? <Todo>[])
        .where((todo) => todo.deletedAt == 0)
        .map<AppFlowyGroupItem>(
            (todo) => _TodoItem(taskId: task.uuid, todo: todo))
        .toList();
    return AppFlowyGroupData<AppFlowyGroupItem>(
        id: task.uuid, name: task.title, items: items);
  }

  @override
  Widget build(BuildContext context) {
    // 首次构建时同步
    if (_lastSignature.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          _syncGroups();
        }
      });
    }

    // 始终显示滚动条，方便移动端快速定位
    final board = _buildBoard(context);

    return ExcludeSemantics(
      // 在拖拽时排除语义，减少可访问性树更新
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: board,
        ),
      ),
    );
  }

  Widget _buildBoard(BuildContext context) {
    // 使用统一的 groupMargin，不依赖 AppFlowyBoard 的 _marginFromIndex 逻辑
    // 因为 _marginFromIndex 会移除第一个 group 的左边距和最后一个 group 的右边距
    // 这会导致第一个和最后一个 task 看起来比中间的宽
    const marginHorizontal = 8.0;

    const boardConfig = AppFlowyBoardConfig(
      groupCornerRadius: 10,
      // 设置 groupMargin 为 0，完全由外层控制间距
      groupMargin: EdgeInsets.zero,
      groupBodyPadding: EdgeInsets.all(0),
      groupFooterPadding: EdgeInsets.all(0),
      groupHeaderPadding: EdgeInsets.all(0),
      stretchGroupHeight: true,
    );

    // 计算每个 group 实际需要的宽度（包含左右 margin）
    final groupWidthWithMargin = widget.listWidth + marginHorizontal * 2;

    return Listener(
      onPointerMove: (event) {
        _dragPosition = event.position;
        _checkAutoScroll();
      },
      onPointerUp: (_) {
        _stopAutoScroll();
        _dragPosition = null;
      },
      onPointerCancel: (_) {
        _stopAutoScroll();
        _dragPosition = null;
      },
      child: AppFlowyBoard(
        controller: _boardController,
        // 使用包含 margin 的宽度作为 group 约束
        groupConstraints: BoxConstraints.tightFor(width: groupWidthWithMargin),
        config: boardConfig,
        scrollController: _scrollController,
        headerBuilder: (_, groupData) {
          final task =
              widget.tasks.firstWhereOrNull((t) => t.uuid == groupData.id);
          if (task == null) {
            return const SizedBox.shrink();
          }
          final hasTodos =
              (task.todos ?? []).where((t) => t.deletedAt == 0).isNotEmpty;

          // 使用 Container 的 margin 来统一控制所有 group 的间距
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: marginHorizontal),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              // 顶部始终有圆角，底部只有在没有 todos 时才有圆角
              borderRadius: hasTodos
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )
                  : BorderRadius.circular(10),
            ),
            width: widget.listWidth,
            child: ConstrainedBox(
              constraints: const BoxConstraints(),
              child: ClipRRect(
                // 使用 ClipRRect 确保内容也遵循圆角
                borderRadius: hasTodos
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )
                    : BorderRadius.circular(10),
                child: TaskCard(
                  task: task,
                  showTodos: false,
                  onContextReady: (ctx) {
                    widget.onTaskContextReady?.call(task.uuid, ctx);
                  },
                ),
              ),
            ),
          );
        },
        cardBuilder: (_, group, item) {
          if (item is! _TodoItem) {
            return const SizedBox.shrink(key: ValueKey('phantom'));
          }

          final data = item;
          final items = group.items.whereType<_TodoItem>().toList();
          final isLastItem = items.isNotEmpty && items.last.id == data.id;

          return KeyedSubtree(
            key: ValueKey(data.id),
            child: Container(
              // 使用与 headerBuilder 相同的 margin 来保持一致性
              margin: const EdgeInsets.symmetric(horizontal: marginHorizontal),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: isLastItem
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )
                    : null,
                border:
                    Border.all(width: 0, color: Theme.of(context).cardColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: ConstrainedBox(
                  // 移动端图片封面更高，需要更大的 maxHeight
                  constraints:
                      BoxConstraints(maxHeight: context.isPhone ? 420 : 350),
                  child: ClipRect(
                    child: TodoCard(
                      taskId: data.taskId,
                      todo: data.todo,
                      compact: true,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Offset? _dragPosition;
  Timer? _autoScrollTimer;

  void _checkAutoScroll() {
    if (_dragPosition == null || !mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    const scrollThreshold = 50.0; // 边缘触发区域宽度
    final maxScrollSpeed = context.isPhone ? 4.0 : 15.0; // 最大滚动速度
    // 使用平滑因子，使滚动开始时更平缓
    // 速度 = maxScrollSpeed * (ratio ^ 2)

    double scrollDelta = 0.0;

    if (_dragPosition!.dx < scrollThreshold) {
      // 向左滚动
      final ratio = (scrollThreshold - _dragPosition!.dx) / scrollThreshold;
      // 使用二次方使加速更平滑
      scrollDelta = -maxScrollSpeed * ratio * ratio;
    } else if (_dragPosition!.dx > screenWidth - scrollThreshold) {
      // 向右滚动
      final ratio = (_dragPosition!.dx - (screenWidth - scrollThreshold)) /
          scrollThreshold;
      // 使用二次方使加速更平滑
      scrollDelta = maxScrollSpeed * ratio * ratio;
    }

    if (scrollDelta != 0.0) {
      _startAutoScroll(scrollDelta);
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(double delta) {
    if (_autoScrollTimer != null) return;

    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || _scrollController.hasClients == false) {
        _stopAutoScroll();
        return;
      }

      final currentOffset = _scrollController.offset;
      final maxOffset = _scrollController.position.maxScrollExtent;
      final minOffset = _scrollController.position.minScrollExtent;

      final targetOffset = (currentOffset + delta).clamp(minOffset, maxOffset);

      if (targetOffset != currentOffset) {
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }
}

class _TodoItem extends AppFlowyGroupItem {
  _TodoItem({required this.taskId, required this.todo});

  final String taskId;
  final Todo todo;

  @override
  String get id => todo.uuid;
}
