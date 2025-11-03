import 'dart:async';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/components/task/task_card.dart';
import 'package:todo_cat/pages/home/components/todo/todo_card.dart';

/// 使用 AppFlowyBoard 渲染横向任务列与待办卡片，尽量保持项目原有 UI。
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _boardController = AppFlowyBoardController(
      onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        _controller.reorderTask(fromIndex, toIndex);
      },
      onMoveGroupItem: (groupId, fromIndex, toIndex) {
        // 同组内的拖拽，AppFlowy 新索引包含占位导致向后移动时 +1，这里做校正
        final adjusted = toIndex > fromIndex ? toIndex - 1 : toIndex;
        _controller.reorderTodo(groupId, fromIndex, adjusted);
      },
      onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        final fromTask =
            widget.tasks.firstWhereOrNull((t) => t.uuid == fromGroupId);
        if (fromTask == null) return;
        final todo = (fromTask.todos ?? const <Todo>[])[fromIndex];
        _controller.moveTodoToTaskAt(
            fromGroupId, toGroupId, todo.uuid, toIndex);
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
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _boardController.dispose();
    super.dispose();
  }

  void _syncGroups() {
    // 计算包含任务与其 todos 顺序及内容的签名，用于判断是否需要重建
    final buffer = StringBuffer();
    for (final task in widget.tasks) {
      buffer.write(task.uuid);
      buffer.write('#');
      buffer.write(task.title);
      for (final todo in (task.todos ?? const <Todo>[])) {
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
      }
      buffer.write('|');
    }
    final signature = buffer.toString();
    if (signature == _lastSignature) return;

    // 取消之前的防抖计时器
    _debounceTimer?.cancel();
    
    // 使用防抖避免频繁重建，减少 ScrollController 冲突
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        // 直接按当前数据全量重建分组与条目，可保证顺序与跨列拖拽后的正确性
        final existing = List<String>.from(_boardController.groupIds);
        for (final id in existing) {
          _boardController.removeGroup(id);
        }
        for (var i = 0; i < widget.tasks.length; i++) {
          _boardController.insertGroup(i, _toGroup(widget.tasks[i]));
        }
        _lastSignature = signature;
      });
    });
  }

  AppFlowyGroupData<AppFlowyGroupItem> _toGroup(Task task) {
    final List<AppFlowyGroupItem> items = (task.todos ?? <Todo>[])
        .map<AppFlowyGroupItem>(
            (todo) => _TodoItem(taskId: task.uuid, todo: todo))
        .toList();
    return AppFlowyGroupData<AppFlowyGroupItem>(
        id: task.uuid, name: task.title, items: items);
  }

  @override
  Widget build(BuildContext context) {
    _syncGroups();
    const boardConfig = AppFlowyBoardConfig(
      groupCornerRadius: 10,
      groupMargin: EdgeInsets.only(right: 16), // 统一右边距，避免第一个和最后一个宽度不一致
      groupBodyPadding: EdgeInsets.all(0),
      stretchGroupHeight: true, // 启用拉伸高度，使列占满整个高度，支持在空白区域放置
    );

    return AppFlowyBoard(
      controller: _boardController,
      groupConstraints: BoxConstraints.tightFor(width: widget.listWidth),
      config: boardConfig,
      scrollController: _scrollController, // 使用独立的 ScrollController 避免冲突
      headerBuilder: (_, groupData) {
        final task = widget.tasks.firstWhere((t) => t.uuid == groupData.id);
        final hasTodos = (task.todos ?? []).isNotEmpty;
        
        return KeyedSubtree(
          key: ValueKey(groupData.id),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              // 如果没有todo项，则显示底部圆角；如果有todo项，则不显示底部圆角
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
          // 占位/幻影卡片由 appflowy_board 自行渲染
          return const SizedBox.shrink(key: ValueKey('phantom'));
        }

        final data = item;
        
        // 判断是否是该列的最后一个todo
        final items = group.items;
        final isLastItem = items.isNotEmpty && items.last.id == data.id;
        
        return KeyedSubtree(
          key: ValueKey(data.id),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              // 只有最后一个todo才应用底部圆角
              borderRadius: isLastItem 
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: TodoCard(
                  taskId: data.taskId,
                  todo: data.todo,
                  // outerMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  compact: true,
                ),
              ),
            ),
          ),
        );
      },
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
