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
  const AppFlowyTodosBoard(
      {super.key, required this.tasks, this.listWidth = 260.0});

  final RxList<Task> tasks;
  final double listWidth;

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
    _scrollController = ScrollController();
    _boardController = AppFlowyBoardController(
      onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        if (_isDisposed || !mounted) return;
        _isDragging = false; // 拖拽结束
        _controller.reorderTask(fromIndex, toIndex);
        // 延迟触发同步以确保数据已更新，避免ScrollController冲突
        _hasPendingUpdate = true;
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!_isDisposed && mounted) {
            _syncGroups();
          }
        });
      },
      onMoveGroupItem: (groupId, fromIndex, toIndex) {
        if (_isDisposed || !mounted) return;
        _isDragging = false; // 拖拽结束
        // 直接使用 appflowy_board 提供的索引，不做调整
        _controller.reorderTodo(groupId, fromIndex, toIndex);
        // 延迟触发同步以确保数据已更新，避免ScrollController冲突
        _hasPendingUpdate = true;
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!_isDisposed && mounted) {
            _syncGroups();
          }
        });
      },
      onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        if (_isDisposed || !mounted) return;
        _isDragging = false; // 拖拽结束
        final fromTask =
            widget.tasks.firstWhereOrNull((t) => t.uuid == fromGroupId);
        if (fromTask == null) return;
        final todo = (fromTask.todos ?? const <Todo>[])[fromIndex];
        _controller.moveTodoToTaskAt(
            fromGroupId, toGroupId, todo.uuid, toIndex);
        // 延迟触发同步以确保数据已更新，避免ScrollController冲突
        _hasPendingUpdate = true;
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!_isDisposed && mounted) {
            _syncGroups();
          }
        });
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
    
    try {
      _scrollController.dispose();
    } catch (e) {
      // 忽略错误
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
      
      final activeTodos = (task.todos ?? const <Todo>[])
          .where((todo) => todo.deletedAt == 0);
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
    
    const boardConfig = AppFlowyBoardConfig(
      groupCornerRadius: 10,
      groupMargin: EdgeInsets.only(right: 16),
      groupBodyPadding: EdgeInsets.all(0),
      groupFooterPadding: EdgeInsets.all(0),
      groupHeaderPadding: EdgeInsets.all(0),
      stretchGroupHeight: true,
    );

    return Scrollbar(
      controller: _scrollController,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: AppFlowyBoard(
          controller: _boardController,
          groupConstraints: BoxConstraints.tightFor(width: widget.listWidth),
          config: boardConfig,
          scrollController: _scrollController,
          headerBuilder: (_, groupData) {
            final task = widget.tasks.firstWhereOrNull((t) => t.uuid == groupData.id);
            if (task == null) {
              return const SizedBox.shrink();
            }
            final hasTodos = (task.todos ?? []).where((t) => t.deletedAt == 0).isNotEmpty;

            return KeyedSubtree(
              key: ValueKey(groupData.id),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: hasTodos
                      ? null
                      : const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                ),
                width: widget.listWidth,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(),
                  child: ClipRect(
                    child: TaskCard(task: task, showTodos: false),
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
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: isLastItem
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        )
                      : null,
                  border: Border.all(width: 0, color: Theme.of(context).cardColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: TodoCard(
                      taskId: data.taskId,
                      todo: data.todo,
                      compact: true,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodoItem extends AppFlowyGroupItem {
  _TodoItem({required this.taskId, required this.todo});

  final String taskId;
  final Todo todo;

  @override
  String get id => todo.uuid;
}
