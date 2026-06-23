import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/schemas/workspace.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'package:todo_cat/data/services/repositorys/workspace.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/core/utils/l10n.dart';

part 'trash_ctr.g.dart';

/// 回收站状态（已删除的任务 / 工作空间 + 加载状态）。
@immutable
class TrashState {
  final List<Task> deletedTasks;
  final List<Workspace> deletedWorkspaces;
  final bool isLoading;

  const TrashState({
    this.deletedTasks = const [],
    this.deletedWorkspaces = const [],
    this.isLoading = false,
  });

  TrashState copyWith({
    List<Task>? deletedTasks,
    List<Workspace>? deletedWorkspaces,
    bool? isLoading,
  }) {
    return TrashState(
      deletedTasks: deletedTasks ?? this.deletedTasks,
      deletedWorkspaces: deletedWorkspaces ?? this.deletedWorkspaces,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 回收站控制器，管理已删除的任务和待办事项（原 GetxController -> Riverpod Notifier）。
@Riverpod(keepAlive: true)
class TrashController extends _$TrashController {
  static final _logger = Logger();
  TaskRepository? _repository;
  bool _isInitialized = false;

  @override
  TrashState build() {
    // 与原 onInit 一致：异步初始化，加载完成后更新 state。
    _init();
    return const TrashState();
  }

  Future<void> _init() async => initialize();

  /// 初始化回收站控制器
  Future<void> initialize() async {
    if (_isInitialized && _repository != null) {
      await refresh();
      return;
    }
    _logger.d('Initializing TrashController');
    _repository = await TaskRepository.getInstance();
    _isInitialized = true;
    await refresh();
  }

  /// 刷新已删除的任务列表和工作空间列表
  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true);
      _logger.d('Refreshing deleted tasks and workspaces');

      if (_repository == null || !_isInitialized) {
        _repository = await TaskRepository.getInstance();
        _isInitialized = true;
      }

      final tasks = await _repository!.readDeleted();

      // 过滤已删除的todos，只显示未删除的todos
      for (var task in tasks) {
        if (task.todos != null) {
          task.todos = task.todos!.where((todo) => todo.deletedAt > 0).toList();
        }
      }

      var deletedWorkspaces = state.deletedWorkspaces;
      final workspaces =
          await ref.read(workspaceControllerProvider.notifier).readDeleted();
      deletedWorkspaces = workspaces;

      state = state.copyWith(
        deletedTasks: tasks,
        deletedWorkspaces: deletedWorkspaces,
      );
      _logger.d('Deleted tasks refreshed, count: ${tasks.length}');
    } catch (e) {
      _logger.e('Error refreshing deleted items: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 恢复任务
  Future<bool> restoreTask(String uuid) async {
    try {
      _logger.d('Restoring task: $uuid');
      await _repository!.restore(uuid);
      await refresh();
      await _refreshHomeData();
      _logger.d('Task restored successfully');
      return true;
    } catch (e) {
      _logger.e('Error restoring task: $e');
      return false;
    }
  }

  /// 永久删除任务
  Future<bool> permanentDeleteTask(String uuid) async {
    try {
      _logger.d('Permanently deleting task: $uuid');
      await _repository!.permanentDelete(uuid);
      await refresh();
      _logger.d('Task permanently deleted');
      return true;
    } catch (e) {
      _logger.e('Error permanently deleting task: $e');
      return false;
    }
  }

  /// 恢复单个todo（从已删除的任务中）
  Future<bool> restoreTodo(String taskUuid, String todoUuid) async {
    try {
      _logger.d('Restoring todo $todoUuid from task $taskUuid');

      final actualTaskUuid = await _repository!.getTaskUuidForTodo(todoUuid);
      if (actualTaskUuid == null) {
        _logger.e('Todo $todoUuid not found in database');
        return false;
      }

      final todoToRestore = await _repository!.getTodoByUuid(todoUuid);
      if (todoToRestore == null) {
        _logger.e('Todo $todoUuid not found in database');
        return false;
      }

      if (todoToRestore.deletedAt == 0) {
        _logger.w('Todo $todoUuid is not deleted, nothing to restore');
        return false;
      }

      await _repository!.permanentDeleteTodo(todoUuid);
      _logger.d('Cleaned up duplicate todos with uuid: $todoUuid');

      final currentTask = await _repository!.readOne(actualTaskUuid);
      if (currentTask == null) {
        _logger.e('Task $actualTaskUuid not found in database');
        return false;
      }

      currentTask.todos ??= [];
      todoToRestore.deletedAt = 0;
      currentTask.todos = List<Todo>.from(currentTask.todos!)
        ..add(todoToRestore);
      _logger.d('Todo restored and added to task $actualTaskUuid');

      if (currentTask.deletedAt > 0) {
        _logger.d('Restoring parent task to make todo visible');
        currentTask.deletedAt = 0;
      }

      await _repository!.write(actualTaskUuid, currentTask);

      await refresh();
      await _refreshHomeData();

      _logger.d('Todo restored successfully to task $actualTaskUuid');
      return true;
    } catch (e) {
      _logger.e('Error restoring todo: $e');
      return false;
    }
  }

  /// 永久删除单个todo
  Future<bool> permanentDeleteTodo(String taskUuid, String todoUuid) async {
    try {
      _logger.d('Permanently deleting todo $todoUuid from task $taskUuid');

      final actualTaskUuid = await _repository!.getTaskUuidForTodo(todoUuid);
      if (actualTaskUuid == null) {
        _logger.e('Todo $todoUuid not found in database');
        return false;
      }

      await _repository!.permanentDeleteTodo(todoUuid);

      final task = await _repository!.readOne(actualTaskUuid);
      if (task != null) {
        final hasOtherDeletedTodos =
            task.todos?.any((t) => t.deletedAt > 0) ?? false;
        if (!hasOtherDeletedTodos && task.deletedAt > 0) {
          await _repository!.permanentDelete(actualTaskUuid);
        }
      }

      await refresh();
      _logger.d('Todo permanently deleted from task $actualTaskUuid');
      return true;
    } catch (e) {
      _logger.e('Error permanently deleting todo: $e');
      return false;
    }
  }

  /// 清空回收站
  Future<bool> emptyTrash() async {
    try {
      _logger.d('Emptying trash');
      final tasks = List<Task>.from(state.deletedTasks);
      for (var task in tasks) {
        await _repository!.permanentDelete(task.uuid);
      }
      await refresh();
      _logger.d('Trash emptied');
      return true;
    } catch (e) {
      _logger.e('Error emptying trash: $e');
      return false;
    }
  }

  /// 格式化删除时间
  String formatDeletedAt(int deletedAt) {
    if (deletedAt == 0) return '';

    final deleted = DateTime.fromMillisecondsSinceEpoch(deletedAt);
    final now = DateTime.now();
    final difference = now.difference(deleted);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${l10n.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${l10n.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${l10n.minutesAgo}';
    } else {
      return l10n.justNow;
    }
  }

  /// 恢复工作空间
  Future<bool> restoreWorkspace(String uuid) async {
    try {
      _logger.d('Restoring workspace: $uuid');
      final success = await ref
          .read(workspaceControllerProvider.notifier)
          .restoreWorkspace(uuid);
      if (success) {
        await refresh();
        _logger.d('Workspace restored successfully');
      }
      return success;
    } catch (e) {
      _logger.e('Error restoring workspace: $e');
      return false;
    }
  }

  /// 永久删除工作空间
  Future<bool> permanentDeleteWorkspace(String uuid) async {
    try {
      _logger.d('Permanently deleting workspace: $uuid');
      final repository = await WorkspaceRepository.getInstance();
      await repository.permanentDelete(uuid);
      await refresh();
      _logger.d('Workspace permanently deleted');
      return true;
    } catch (e) {
      _logger.e('Error permanently deleting workspace: $e');
      return false;
    }
  }

  /// 刷新主页数据
  Future<void> _refreshHomeData() async {
    try {
      await ref.read(homeControllerProvider.notifier).refreshData();
      _logger.d('Home data refreshed successfully');
    } catch (e) {
      _logger.d('刷新主页失败: $e');
    }
  }
}
