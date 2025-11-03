import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';

/// 回收站控制器，管理已删除的任务和待办事项
class TrashController extends GetxController {
  static final _logger = Logger();
  final AppController appCtrl = Get.find();
  TaskRepository? _repository;
  bool _isInitialized = false;
  
  // 已删除的任务列表
  final deletedTasks = RxList<Task>();
  
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

  /// 刷新已删除的任务列表
  @override
  Future<void> refresh() async {
    try {
      isLoading.value = true;
      _logger.d('Refreshing deleted tasks');
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
    } catch (e) {
      _logger.e('Error refreshing deleted tasks: $e');
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
      
      // 先从已删除的任务列表中查找任务
      Task? task = deletedTasks.firstWhereOrNull((t) => t.uuid == taskUuid);
      
      // 如果任务不存在，尝试从所有已删除的task中查找这个todo，然后创建新任务
      if (task == null) {
        _logger.d('Task $taskUuid not found in deleted tasks, searching for todo in all deleted tasks...');
        Task? templateTask;
        Todo? foundTodo;
        
        // 从所有已删除的任务中查找这个todo
        for (var deletedTask in deletedTasks) {
          if (deletedTask.todos != null) {
            final todo = deletedTask.todos!.firstWhereOrNull((t) => t.uuid == todoUuid);
            if (todo != null) {
              templateTask = deletedTask;
              foundTodo = todo;
              break;
            }
          }
        }
        
        if (foundTodo == null) {
          _logger.e('Todo $todoUuid not found in any deleted task');
          return false;
        }
        
        // 创建新任务，使用找到的任务作为模板
        final newTask = Task()
          ..uuid = taskUuid
          ..title = templateTask!.title
          ..description = templateTask.description
          ..createdAt = templateTask.createdAt > 0 
              ? templateTask.createdAt 
              : DateTime.now().millisecondsSinceEpoch
          ..status = templateTask.status
          ..tags = List<String>.from(templateTask.tags)
          ..tagsWithColorJsonString = templateTask.tagsWithColorJsonString
          ..deletedAt = 0
          ..todos = [];
        
        // 恢复todo并添加到新任务
        foundTodo.deletedAt = 0;
        newTask.todos = [foundTodo];
        
        // 保存新任务
        await _repository!.write(taskUuid, newTask);
        await refresh();
        _logger.d('Created new task and restored todo successfully');
        return true;
      }
      
      // 任务存在，恢复todo
      // 关键：先从数据库读取最新的 task 数据，而不是使用回收站里的旧数据
      // 这样可以避免覆盖已经移动过来的 todo
      final currentTask = await _repository!.readOne(taskUuid);
      
      if (currentTask == null) {
        _logger.e('Task $taskUuid not found in database');
        return false;
      }
      
      // 确保 currentTask.todos 不为空
      if (currentTask.todos == null) {
        currentTask.todos = [];
      }
      
      // 从回收站的 task 中找到要恢复的 todo（可能包含已删除的 todo）
      final todoToRestore = task.todos!.firstWhereOrNull((t) => t.uuid == todoUuid);
      if (todoToRestore == null) {
        _logger.e('Todo $todoUuid not found in deleted task');
        return false;
      }
      
      // 检查当前 task 中是否已经存在这个 todo（可能已经恢复过了）
      final existingTodoIndex = currentTask.todos!.indexWhere((t) => t.uuid == todoUuid);
      
      if (existingTodoIndex != -1) {
        // 如果已经存在，只恢复它的 deletedAt 状态
        currentTask.todos![existingTodoIndex].deletedAt = 0;
        _logger.d('Todo already exists in task, just restoring its deletedAt status');
      } else {
        // 如果不存在，恢复 todo 并添加到当前 task
        todoToRestore.deletedAt = 0;
        currentTask.todos = List<Todo>.from(currentTask.todos!)..add(todoToRestore);
        _logger.d('Todo restored and added to task');
      }
      
      // 恢复 todo 时，必须同时恢复父 task，否则 todo 无法在主页显示
      // 因为主页只显示 deletedAt == 0 的 task
      if (currentTask.deletedAt > 0) {
        _logger.d('Restoring parent task to make todo visible');
        currentTask.deletedAt = 0;
      }
      
      // 保存更改
      await _repository!.write(taskUuid, currentTask);
      
      // 立即刷新回收站和主页数据
      await refresh();
      await _refreshHomeData();
      
      _logger.d('Todo restored successfully');
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
      
      final task = deletedTasks.firstWhere((t) => t.uuid == taskUuid);
      if (task.todos == null) {
        return false;
      }
      
      // 从列表中移除todo
      task.todos = task.todos!.where((t) => t.uuid != todoUuid).toList();
      
      // 检查是否还有其他已删除的 todos
      final hasOtherDeletedTodos = task.todos!.any((t) => t.deletedAt > 0);
      
      // 如果没有已删除的 todos 了
      if (!hasOtherDeletedTodos) {
        // 如果 task 本身被删除了，永久删除整个 task
        if (task.deletedAt > 0) {
          await _repository!.permanentDelete(taskUuid);
        } else {
          // 如果 task 本身未被删除，只是清理数据
          await _repository!.write(taskUuid, task);
        }
      } else {
        // 还有其他已删除的 todos，保存更新
        await _repository!.write(taskUuid, task);
      }
      
      await refresh();
      _logger.d('Todo permanently deleted');
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
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
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

