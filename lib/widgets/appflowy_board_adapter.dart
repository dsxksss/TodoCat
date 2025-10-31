import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/components/task/task_card.dart';
import 'package:todo_cat/pages/home/components/todo/todo_card.dart';

/// 使用 AppFlowyBoard 渲染横向任务列与待办卡片，尽量保持项目原有 UI。
class AppFlowyTodosBoard extends StatefulWidget {
  const AppFlowyTodosBoard({super.key, required this.tasks, this.listWidth = 260.0});

  final RxList<Task> tasks;
  final double listWidth;

  @override
  State<AppFlowyTodosBoard> createState() => _AppFlowyTodosBoardState();
}

class _AppFlowyTodosBoardState extends State<AppFlowyTodosBoard> {
  final HomeController _controller = Get.find();
  late final AppFlowyBoardController _boardController;
  String _lastSignature = '';

  @override
  void initState() {
    super.initState();
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
        final fromTask = widget.tasks.firstWhereOrNull((t) => t.uuid == fromGroupId);
        if (fromTask == null) return;
        final todo = (fromTask.todos ?? const <Todo>[])[fromIndex];
        _controller.moveTodoToTaskAt(fromGroupId, toGroupId, todo.uuid, toIndex);
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
    _boardController.dispose();
    super.dispose();
  }

  int? _indexOfGroup(String groupId) {
    final index = widget.tasks.indexWhere((t) => t.uuid == groupId);
    return index == -1 ? null : index;
  }

  void _syncGroups() {
    // 计算包含任务与其 todos 顺序的签名，用于判断是否需要重建
    final buffer = StringBuffer();
    for (final task in widget.tasks) {
      buffer.write(task.uuid);
      for (final todo in (task.todos ?? const <Todo>[])) {
        buffer.write('::');
        buffer.write(todo.uuid);
      }
      buffer.write('|');
    }
    final signature = buffer.toString();
    if (signature == _lastSignature) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
  }

  AppFlowyGroupData<AppFlowyGroupItem> _toGroup(Task task) {
    final List<AppFlowyGroupItem> items = (task.todos ?? <Todo>[]) 
        .map<AppFlowyGroupItem>((todo) => _TodoItem(taskId: task.uuid, todo: todo))
        .toList();
    return AppFlowyGroupData<AppFlowyGroupItem>(id: task.uuid, name: task.title, items: items);
  }

  @override
  Widget build(BuildContext context) {
    _syncGroups();
    final boardConfig = AppFlowyBoardConfig(
      groupCornerRadius: 10,
      groupBackgroundColor: Theme.of(context).cardColor,
      groupMargin: const EdgeInsets.symmetric(horizontal: 8),
      groupHeaderPadding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      groupBodyPadding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      groupFooterPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      cardMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      stretchGroupHeight: false,
    );

    return AppFlowyBoard(
      controller: _boardController,
      groupConstraints: BoxConstraints.tightFor(width: widget.listWidth),
      config: boardConfig,
      headerBuilder: (_, groupData) {
        final task = widget.tasks.firstWhere((t) => t.uuid == groupData.id);
        return KeyedSubtree(
          key: ValueKey(groupData.id),
          child: SizedBox(
            width: widget.listWidth,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 128),
              child: ClipRect(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: TaskCard(task: task, showTodos: false),
                ),
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
        final data = item as _TodoItem;
        return KeyedSubtree(
          key: ValueKey(data.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ClipRect(
                child: TodoCard(
                  taskId: data.taskId,
                  todo: data.todo,
                  outerMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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


