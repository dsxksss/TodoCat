import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';

/// 任务状态管理Mixin
/// 提供通用的任务过滤、搜索、分组等功能
mixin TaskStateMixin on GetxController {
  final searchQuery = ''.obs;
  final groupByStatus = false.obs;
  final selectedTaskId = RxString('');
  final currentTask = Rx<Task?>(null);

  /// 获取所有任务的抽象方法（由具体控制器实现）
  List<Task> get allTasks;

  /// 获取过滤后的任务列表
  List<Task> get filteredTasks {
    if (searchQuery.value.isEmpty) return allTasks;
    
    return allTasks.where((task) {
      // 按标题搜索
      final titleMatch = task.title
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase());
      
      // 按标签搜索
      final tagMatch = task.tags.any((tag) =>
          tag.toLowerCase().contains(searchQuery.value.toLowerCase()));
      
      // 按描述搜索
      final descriptionMatch = task.description
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase());
      
      return titleMatch || tagMatch || descriptionMatch;
    }).toList();
  }

  /// 获取按状态分组的任务
  Map<TaskStatus, List<Task>> get groupedTasks {
    final tasks = filteredTasks;
    
    if (!groupByStatus.value) {
      return {TaskStatus.todo: tasks};
    }

    return {
      TaskStatus.todo: tasks.where((t) => t.status == TaskStatus.todo).toList(),
      TaskStatus.inProgress: tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
      TaskStatus.done: tasks.where((t) => t.status == TaskStatus.done).toList(),
    };
  }

  /// 选择任务
  void selectTask(Task? task) {
    currentTask.value = task;
    selectedTaskId.value = task?.uuid ?? '';
    onTaskSelected(task);
  }

  /// 取消选择任务
  void deselectTask() {
    currentTask.value = null;
    selectedTaskId.value = '';
    onTaskDeselected();
  }

  /// 设置搜索查询
  void setSearchQuery(String query) {
    searchQuery.value = query.trim();
    onSearchQueryChanged(query);
  }

  /// 清除搜索
  void clearSearch() {
    searchQuery.value = '';
    onSearchCleared();
  }

  /// 切换分组模式
  void toggleGroupByStatus() {
    groupByStatus.value = !groupByStatus.value;
    onGroupModeChanged(groupByStatus.value);
  }

  /// 按标签过滤任务
  List<Task> getTasksByTag(String tag) {
    return allTasks.where((task) => task.tags.contains(tag)).toList();
  }

  /// 按状态过滤任务
  List<Task> getTasksByStatus(TaskStatus status) {
    return allTasks.where((task) => task.status == status).toList();
  }

  /// 获取所有唯一标签
  List<String> get allUniqueTags {
    final tags = <String>{};
    for (final task in allTasks) {
      tags.addAll(task.tags);
    }
    return tags.toList()..sort();
  }

  /// 获取任务统计信息
  Map<String, int> get taskStatistics {
    final stats = <String, int>{
      'total': allTasks.length,
      'todo': 0,
      'inProgress': 0,
      'done': 0,
    };

    for (final task in allTasks) {
      switch (task.status) {
        case TaskStatus.todo:
          stats['todo'] = stats['todo']! + 1;
          break;
        case TaskStatus.inProgress:
          stats['inProgress'] = stats['inProgress']! + 1;
          break;
        case TaskStatus.done:
          stats['done'] = stats['done']! + 1;
          break;
      }
    }

    return stats;
  }

  /// 根据ID查找任务
  Task? findTaskById(String uuid) {
    try {
      return allTasks.firstWhere((task) => task.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// 检查任务是否存在
  bool taskExists(String uuid) {
    return allTasks.any((task) => task.uuid == uuid);
  }

  /// 获取任务在列表中的索引
  int getTaskIndex(String uuid) {
    return allTasks.indexWhere((task) => task.uuid == uuid);
  }

  /// 任务选择事件回调（子类可以重写）
  void onTaskSelected(Task? task) {
    // 子类可以重写此方法来响应任务选择
  }

  /// 任务取消选择事件回调（子类可以重写）
  void onTaskDeselected() {
    // 子类可以重写此方法来响应任务取消选择
  }

  /// 搜索查询变更事件回调（子类可以重写）
  void onSearchQueryChanged(String query) {
    // 子类可以重写此方法来响应搜索变更
  }

  /// 搜索清除事件回调（子类可以重写）
  void onSearchCleared() {
    // 子类可以重写此方法来响应搜索清除
  }

  /// 分组模式变更事件回调（子类可以重写）
  void onGroupModeChanged(bool isGrouped) {
    // 子类可以重写此方法来响应分组模式变更
  }
}