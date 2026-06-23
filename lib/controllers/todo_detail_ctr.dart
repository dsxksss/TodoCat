import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/base/base_form_controller.dart';
import 'package:todo_cat/controllers/todo_dialog_ctr.dart';
import 'package:todo_cat/widgets/todo_dialog.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/routers/app_router.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:todo_cat/core/utils/l10n.dart';

part 'todo_detail_ctr.g.dart';

/// 待办详情参数（family key）。
typedef TodoDetailParams = ({String todoId, String taskId});

const _editTodoDetailDialogTag = 'edit_todo_detail_dialog';

/// 待办详情状态：当前展示的 [Todo]（null 表示加载中或已消失）。
@immutable
class TodoDetailState {
  final Todo? todo;

  const TodoDetailState({this.todo});

  TodoDetailState copyWith({Todo? todo}) =>
      TodoDetailState(todo: todo ?? this.todo);
}

/// 待办详情控制器（autoDispose family，按 (todoId, taskId) 分实例）。
/// 生成 `todoDetailControllerProvider(params)`。
///
/// 预览模式（原 `previewTodo` 构造参数）由独立的
/// [previewTodoDetailControllerProvider] 提供，避免与从数据源加载的逻辑混淆。
@riverpod
class TodoDetailController extends _$TodoDetailController {
  bool _isNavigatingBack = false;

  String get todoId => params.todoId;
  String get taskId => params.taskId;

  late final TodoDetailParams params;

  @override
  TodoDetailState build(TodoDetailParams params) {
    this.params = params;

    // 监听 HomeController 的任务列表变化，自动刷新详情。
    ref.listen(homeControllerProvider, (_, __) {
      if (!_isNavigatingBack) {
        _loadTodoDetail();
      }
    });

    _loadTodoDetail();
    return const TodoDetailState();
  }

  bool get isPreview => false;

  void _loadTodoDetail() {
    if (_isNavigatingBack) {
      return;
    }

    try {
      final tasks = ref.read(homeControllerProvider.notifier).tasks;
      // 使用 firstWhereOrNull 避免找不到元素时抛出异常
      final task = tasks.firstWhereOrNull(
        (task) => task.uuid == taskId,
      );

      if (task == null) {
        if (!_isNavigatingBack) {
          FormControllerMixin.logger.w('Task not found: $taskId');
          _isNavigatingBack = true;
          _popIfDetailRoute();
        }
        return;
      }

      if (task.todos != null) {
        final foundTodo = task.todos!.firstWhereOrNull(
          (todo) => todo.uuid == todoId,
        );

        if (foundTodo != null) {
          state = state.copyWith(todo: foundTodo);
        } else {
          if (!_isNavigatingBack) {
            FormControllerMixin.logger
                .w('Todo not found: $todoId in task $taskId');
            _isNavigatingBack = true;
            _popIfDetailRoute();
          }
        }
      } else {
        if (!_isNavigatingBack) {
          FormControllerMixin.logger.w('Task todos is null: $taskId');
          _isNavigatingBack = true;
          _popIfDetailRoute();
        }
      }
    } catch (e) {
      if (!_isNavigatingBack) {
        FormControllerMixin.logger.e('Error loading todo detail: $e');
        _isNavigatingBack = true;
        _popIfDetailRoute();
      }
    }
  }

  void _popIfDetailRoute() {
    if (currentRoutePath == '/todo-detail') {
      appRouter.pop();
    }
  }

  /// 手动刷新待办详情数据
  void refreshTodoDetail() {
    _loadTodoDetail();
  }

  void editTodo() {
    final todo = state.todo;
    if (todo == null) return;

    ref
        .read(addTodoDialogControllerProvider(_editTodoDetailDialogTag).notifier)
        .initForEditing(taskId, todo);

    DialogService.showFormDialog(
      tag: _editTodoDetailDialogTag,
      dialog: const TodoDialog(dialogTag: _editTodoDetailDialogTag),
      useFixedSize: false, // TodoDialog 需要动态调整宽度以支持预览窗口
    );

    // 由于已经有自动监听机制，不需要手动刷新
  }

  void deleteTodo() async {
    final todo = state.todo;
    if (todo == null) return;

    FormControllerMixin.logger.d('Deleting todo: $todoId');

    // 设置标志，防止自动监听器触发导航
    _isNavigatingBack = true;

    // 执行删除操作
    await ref.read(homeControllerProvider.notifier).deleteTodo(taskId, todoId);

    FormControllerMixin.logger.d('Todo deleted, closing dialog/page...');

    // 添加短暂延迟，确保确认toast完全关闭后再关闭页面
    await Future.delayed(const Duration(milliseconds: 150));

    // 删除成功后关闭对话框或页面
    try {
      // 对话框tag格式：'todo_detail_dialog_${todoId}'
      final dialogTag = 'todo_detail_dialog_$todoId';

      // 尝试关闭SmartDialog（对话框模式）
      SmartDialog.dismiss(tag: dialogTag);
      FormControllerMixin.logger.d('Dialog dismissed with tag: $dialogTag');

      // 如果是页面模式（/todo-detail路由），也需要关闭页面
      if (currentRoutePath == '/todo-detail') {
        appRouter.pop();
        FormControllerMixin.logger.d('Page also closed');
      }
      // controller 由 autoDispose 自动回收，无需手动删除
    } catch (e) {
      FormControllerMixin.logger.e('Error closing dialog/page: $e');
    }
  }

  String getPriorityText(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return l10n.lowLevel;
      case TodoPriority.mediumLevel:
        return l10n.mediumLevel;
      case TodoPriority.highLevel:
        return l10n.highLevel;
    }
  }

  String getStatusText(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return l10n.todo;
      case TodoStatus.inProgress:
        return l10n.inProgress;
      case TodoStatus.done:
        return l10n.done;
    }
  }
}

/// 预览模式的待办详情控制器（autoDispose family，按预览的 [Todo] 分实例）。
/// 生成 `previewTodoDetailControllerProvider(previewTodo)`。
///
/// 与 [TodoDetailController] 共享同样的文本辅助方法（[getPriorityText] /
/// [getStatusText]），但不从数据源加载、不监听变化、不导航。
@riverpod
class PreviewTodoDetailController extends _$PreviewTodoDetailController {
  @override
  TodoDetailState build(Todo previewTodo) {
    return TodoDetailState(todo: previewTodo);
  }

  bool get isPreview => true;

  void refreshTodoDetail() {}

  void editTodo() {}

  void deleteTodo() {}

  String getPriorityText(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return l10n.lowLevel;
      case TodoPriority.mediumLevel:
        return l10n.mediumLevel;
      case TodoPriority.highLevel:
        return l10n.highLevel;
    }
  }

  String getStatusText(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return l10n.todo;
      case TodoStatus.inProgress:
        return l10n.inProgress;
      case TodoStatus.done:
        return l10n.done;
    }
  }
}
