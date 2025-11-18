import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/data/schemas/workspace.dart';
import 'package:TodoCat/data/services/repositorys/task.dart';
import 'package:TodoCat/data/services/repositorys/workspace.dart';
import 'package:TodoCat/controllers/app_ctr.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/controllers/workspace_ctr.dart';

/// 回收站控制器，管理已删除的任务和待办事项
class TrashController extends GetxController {
  static final _logger = Logger();
  final AppController appCtrl = Get.find();
  TaskRepository? _repository;
  bool _isInitialized = false;

  // 已删除的任务列表
  final deletedTasks = RxList<Task>();

  // 已删除的工作空间列表
  final deletedWorkspaces = RxList<Workspace>();

  // 加载状态
  final isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await initialize();
  }

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
  @override
  Future<void> refresh() async {
    try {
      isLoading.value = true;
      _logger.d('Refreshing deleted tasks and workspaces');

      // 确保 Repository 已初始化（在数据库重置后可能需要重新获取）
      if (_repository == null || !_isInitialized) {
        _repository = await TaskRepository.getInstance();
        _isInitialized = true;
      }

      // 刷新已删除的任务
      final tasks = await _repository!.readDeleted();

      // 过滤已删除的todos，只显示未删除的todos（虽然任务已删除，但可能包含未删除的todos）
      for (var task in tasks) {
        if (task.todos != null) {
          task.todos = task.todos!.where((todo) => todo.deletedAt > 0).toList();
        }
      }

      deletedTasks.assignAll(tasks);
      deletedTasks.refresh();
      _logger.d('Deleted tasks refreshed, count: ${deletedTasks.length}');

      // 刷新已删除的工作空间
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        final workspaces = await workspaceCtrl.readDeleted();
        deletedWorkspaces.assignAll(workspaces);
        deletedWorkspaces.refresh();
        _logger.d(
            'Deleted workspaces refreshed, count: ${deletedWorkspaces.length}');
      }
    } catch (e) {
      _logger.e('Error refreshing deleted items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 恢复任务
  Future<bool> restoreTask(String uuid) async {
    try {
      _logger.d('Restoring task: $uuid');
      await _repository!.restore(uuid);

      // 立即刷新回收站和主页数据
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

      // 关键修复：从数据库查询todo的实际taskUuid，而不是使用传入的taskUuid
      // 这样可以确保todo恢复到正确的task中（即删除前的task）
      // 如果存在多个相同uuid的todo，选择最新的（按id排序）
      final actualTaskUuid = await _repository!.getTaskUuidForTodo(todoUuid);
      if (actualTaskUuid == null) {
        _logger.e('Todo $todoUuid not found in database');
        return false;
      }

      _logger.d(
          'Todo $todoUuid actually belongs to task $actualTaskUuid (requested: $taskUuid)');

      // 从数据库获取todo对象（如果有多个，会选择最新的）
      final todoToRestore = await _repository!.getTodoByUuid(todoUuid);
      if (todoToRestore == null) {
        _logger.e('Todo $todoUuid not found in database');
        return false;
      }

      // 检查todo是否已删除
      if (todoToRestore.deletedAt == 0) {
        _logger.w('Todo $todoUuid is not deleted, nothing to restore');
        return false;
      }

      // 关键修复：在恢复前，先删除所有task中相同uuid的todo（清理重复数据）
      // 这样可以确保恢复后todo只存在于一个task中
      await _repository!.permanentDeleteTodo(todoUuid);
      _logger.d('Cleaned up duplicate todos with uuid: $todoUuid');

      // 从数据库读取实际的task（todo所在的task）
      final currentTask = await _repository!.readOne(actualTaskUuid);

      if (currentTask == null) {
        _logger.e('Task $actualTaskUuid not found in database');
        return false;
      }

      // 确保 currentTask.todos 不为空
      currentTask.todos ??= [];

      // 恢复 todo 并添加到当前 task（因为已经删除了所有重复的，所以直接添加）
      todoToRestore.deletedAt = 0;
      currentTask.todos = List<Todo>.from(currentTask.todos!)
        ..add(todoToRestore);
      _logger.d('Todo restored and added to task $actualTaskUuid');

      // 恢复 todo 时，必须同时恢复父 task，否则 todo 无法在主页显示
      // 因为主页只显示 deletedAt == 0 的 task
      if (currentTask.deletedAt > 0) {
        _logger.d('Restoring parent task to make todo visible');
        currentTask.deletedAt = 0;
      }

      // 保存更改（write方法会确保todo只存在于当前task中）
      await _repository!.write(actualTaskUuid, currentTask);

      // 立即刷新回收站和主页数据
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

      // 关键修复：从数据库查询todo的实际taskUuid，确保删除正确的todo
      final actualTaskUuid = await _repository!.getTaskUuidForTodo(todoUuid);
      if (actualTaskUuid == null) {
        _logger.e('Todo $todoUuid not found in database');
        return false;
      }

      _logger.d(
          'Todo $todoUuid actually belongs to task $actualTaskUuid (requested: $taskUuid)');

      // 直接从数据库删除todo
      await _repository!.permanentDeleteTodo(todoUuid);

      // 从数据库读取实际的task，检查是否还有其他已删除的todos
      final task = await _repository!.readOne(actualTaskUuid);
      if (task != null) {
        // 检查是否还有其他已删除的 todos
        final hasOtherDeletedTodos =
            task.todos?.any((t) => t.deletedAt > 0) ?? false;

        // 如果没有已删除的 todos 了，并且 task 本身被删除了，永久删除整个 task
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
      final tasks = List<Task>.from(deletedTasks);

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
      return '${difference.inDays} ${'daysAgo'.tr}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${'hoursAgo'.tr}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${'minutesAgo'.tr}';
    } else {
      return 'justNow'.tr;
    }
  }

  /// 恢复工作空间
  Future<bool> restoreWorkspace(String uuid) async {
    try {
      _logger.d('Restoring workspace: $uuid');
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        final success = await workspaceCtrl.restoreWorkspace(uuid);
        if (success) {
          await refresh();
          _logger.d('Workspace restored successfully');
        }
        return success;
      }
      return false;
    } catch (e) {
      _logger.e('Error restoring workspace: $e');
      return false;
    }
  }

  /// 永久删除工作空间
  Future<bool> permanentDeleteWorkspace(String uuid) async {
    try {
      _logger.d('Permanently deleting workspace: $uuid');
      if (Get.isRegistered<WorkspaceController>()) {
        Get.find<WorkspaceController>();
        // 通过 WorkspaceRepository 访问
        final repository = await WorkspaceRepository.getInstance();
        await repository.permanentDelete(uuid);
        await refresh();
        _logger.d('Workspace permanently deleted');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error permanently deleting workspace: $e');
      return false;
    }
  }

  /// 刷新主页数据（参考排序拖拽的数据更新逻辑）
  Future<void> _refreshHomeData() async {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        // 使用 refreshData 从数据库重新加载数据，确保数据同步
        await homeController.refreshData();
        _logger.d('Home data refreshed successfully');
      }
    } catch (e) {
      _logger.d('未找到HomeController，跳过刷新主页: $e');
    }
  }
}
