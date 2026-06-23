import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_cat/controllers/base/base_form_controller.dart';
import 'package:todo_cat/controllers/mixins/edit_state_mixin.dart';

import 'package:todo_cat/core/utils/l10n.dart';

part 'todo_dialog_ctr.g.dart';

/// 新增/编辑 Todo 对话框的表单状态。
@immutable
class AddTodoFormState {
  final List<TagWithColor> selectedTags;
  final bool isDirty;
  final bool isEditing;
  final TodoPriority selectedPriority;
  final int remindersValue;
  final String remindersText;
  final DateTime? selectedDate;
  final TodoStatus selectedStatus;

  const AddTodoFormState({
    this.selectedTags = const [],
    this.isDirty = false,
    this.isEditing = false,
    this.selectedPriority = TodoPriority.lowLevel,
    this.remindersValue = 0,
    this.remindersText = "",
    this.selectedDate,
    this.selectedStatus = TodoStatus.todo,
  });

  AddTodoFormState copyWith({
    List<TagWithColor>? selectedTags,
    bool? isDirty,
    bool? isEditing,
    TodoPriority? selectedPriority,
    int? remindersValue,
    String? remindersText,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    TodoStatus? selectedStatus,
  }) {
    return AddTodoFormState(
      selectedTags: selectedTags ?? this.selectedTags,
      isDirty: isDirty ?? this.isDirty,
      isEditing: isEditing ?? this.isEditing,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      remindersValue: remindersValue ?? this.remindersValue,
      remindersText: remindersText ?? this.remindersText,
      selectedDate:
          clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

/// 新增/编辑 Todo 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
/// 生成 `addTodoDialogControllerProvider(tag)`。
@riverpod
class AddTodoDialogController extends _$AddTodoDialogController
    with FormControllerMixin, EditStateMixin {
  static final Map<String, Map<String, dynamic>> _dialogCache = {};

  /// 缓存 key —— 以 family 的 tag 作为标识（同一对话框复用同一缓存槽）。
  late final String dialogId;

  String? taskId;

  @override
  AddTodoFormState build(String tag) {
    dialogId = tag;
    ref.onDispose(disposeFormControllers);
    return const AddTodoFormState();
  }

  // ---- FormControllerMixin 钩子 ----
  @override
  List<TagWithColor> get selectedTags => state.selectedTags;

  @override
  void updateSelectedTags(List<TagWithColor> tags) =>
      state = state.copyWith(selectedTags: tags);

  @override
  void markDirty() => state = state.copyWith(isDirty: true);

  Future<bool> submitForm() async {
    if (!validateForm()) return false;

    if (state.isEditing && getEditingItem<Todo>() != null && taskId != null) {
      final currentTodo = getEditingItem<Todo>()!;
      final updatedTodo = Todo()
        ..uuid = currentTodo.uuid
        ..title = titleController.text
        ..description = descriptionController.text
        ..createdAt = currentTodo.createdAt
        ..tagsWithColor = state.selectedTags.toList()
        ..priority = state.selectedPriority
        ..status = state.selectedStatus
        ..finishedAt = state.selectedStatus == TodoStatus.done
            ? (currentTodo.finishedAt > 0
                ? currentTodo.finishedAt
                : DateTime.now().millisecondsSinceEpoch)
            : 0
        ..dueDate = state.selectedDate?.millisecondsSinceEpoch ?? 0
        ..reminders = state.remindersValue;

      try {
        final homeCtrl = ref.read(homeControllerProvider.notifier);
        final task =
            homeCtrl.tasks.firstWhere((task) => task.uuid == taskId);

        task.todos ??= [];

        final todoIndex = task.todos!.indexWhere(
          (todo) => todo.uuid == currentTodo.uuid,
        );

        if (todoIndex != -1) {
          // 创建可变副本来修改todo
          final newTodos = List<Todo>.from(task.todos!);
          newTodos[todoIndex] = updatedTodo;
          task.todos = newTodos;
          await homeCtrl.updateTask(taskId!, task);
          // 不在这里清理表单，让对话框处理
          return true;
        }
      } catch (e) {
        FormControllerMixin.logger.e('Error updating todo: $e');
      }
    } else {
      if (taskId == null || taskId!.isEmpty) {
        FormControllerMixin.logger.e('No task ID provided for new todo');
        showErrorToast(l10n.selectTaskFirst);
        return false;
      }

      try {
        final task = ref
            .read(homeControllerProvider.notifier)
            .tasks
            .firstWhereOrNull((task) => task.uuid == taskId);

        if (task == null) {
          FormControllerMixin.logger.e('Task not found: $taskId');
          showErrorToast(l10n.taskNotFound);
          return false;
        }
      } catch (e) {
        FormControllerMixin.logger.e('Error finding task: $e');
        showErrorToast(l10n.taskNotFound);
        return false;
      }

      final todo = Todo()
        ..uuid = const Uuid().v4()
        ..title = titleController.text
        ..description = descriptionController.text
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tagsWithColor = state.selectedTags.toList()
        ..priority = state.selectedPriority
        ..status = TodoStatus.todo
        ..finishedAt = 0
        ..dueDate = state.selectedDate?.millisecondsSinceEpoch ?? 0
        ..reminders = state.remindersValue;

      try {
        final bool isSuccess = await ref
            .read(homeControllerProvider.notifier)
            .addTodo(todo, taskId!);
        if (isSuccess) {
          // 不在这里清理表单，让对话框处理
          return true;
        }
      } catch (e) {
        FormControllerMixin.logger.e('Error submitting todo: $e');
        showErrorToast(l10n.addTodoFailed);
      }
    }
    return false;
  }

  @override
  bool isDataEmpty() {
    return super.isDataEmpty() &&
        state.selectedDate == null &&
        state.selectedPriority == TodoPriority.lowLevel &&
        state.remindersValue == 0 &&
        state.selectedStatus == TodoStatus.todo;
  }

  void saveCache() {
    FormControllerMixin.logger.d('Saving form cache');
    _dialogCache[dialogId] = {
      'title': titleController.text,
      'description': descriptionController.text,
      'tagsWithColor': state.selectedTags.map((tag) => tag.toJson()).toList(),
      'date': state.selectedDate,
      'priority': state.selectedPriority.index,
      'reminders': state.remindersValue,
    };
  }

  void restoreCacheIfAny() {
    FormControllerMixin.logger.d('Restoring form cache if available');
    final cache = _dialogCache[dialogId];
    if (cache == null) return;

    titleController.text = cache['title'] as String? ?? '';
    descriptionController.text = cache['description'] as String? ?? '';

    List<TagWithColor> restoredTags;
    // 处理标签缓存 - 兼容旧格式
    if (cache['tagsWithColor'] != null) {
      final tagsWithColorJson = cache['tagsWithColor'] as List<dynamic>;
      restoredTags = tagsWithColorJson
          .map((tagJson) =>
              TagWithColor.fromJson(tagJson as Map<String, dynamic>))
          .toList();
    } else {
      // 兼容旧格式的字符串标签
      final stringTags =
          List<String>.from((cache['tags'] as List?) ?? const []);
      restoredTags =
          stringTags.map((tag) => TagWithColor.fromString(tag)).toList();
    }

    final priorityIndex =
        cache['priority'] as int? ?? TodoPriority.lowLevel.index;

    final DateTime? date = cache['date'] as DateTime?;

    state = state.copyWith(
      selectedTags: restoredTags,
      selectedPriority: TodoPriority.values[priorityIndex],
      remindersValue: cache['reminders'] as int? ?? 0,
      selectedDate: date,
      clearSelectedDate: date == null,
      // 状态未参与缓存，默认保持为待办状态
      selectedStatus: TodoStatus.todo,
    );
  }

  void clearForm() {
    FormControllerMixin.logger.d('Clearing todo form');
    clearFormControllers();
    taskId = null;
    _dialogCache.remove(dialogId);
    exitEditing();
    state = AddTodoFormState(
      remindersText: "${l10n.enter}${l10n.time}",
    );
  }

  void initForEditing(String taskId, Todo todo) {
    this.taskId = taskId;

    // 从 HomeController 的任务列表中获取最新的 todo 数据
    Todo latestTodo = todo;
    try {
      final homeCtrl = ref.read(homeControllerProvider.notifier);
      final task = homeCtrl.tasks.firstWhereOrNull(
        (task) => task.uuid == taskId,
      );
      if (task != null && task.todos != null) {
        final foundTodo = task.todos!.firstWhereOrNull(
          (t) => t.uuid == todo.uuid,
        );
        if (foundTodo != null) {
          latestTodo = foundTodo;
        }
      }
    } catch (e) {
      // 如果获取失败，使用传入的 todo
    }

    // 设置表单数据
    titleController.text = latestTodo.title;
    descriptionController.text = latestTodo.description;

    final List<TagWithColor> tags;
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (latestTodo.tagsWithColor.isNotEmpty) {
      // 创建深拷贝，避免直接修改原始数据
      tags = latestTodo.tagsWithColor
          .map((tag) => TagWithColor(name: tag.name, color: tag.color))
          .toList();
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      tags =
          latestTodo.tags.map((tag) => TagWithColor.fromString(tag)).toList();
    }

    // 使用编辑状态管理
    final editState = {
      'title': latestTodo.title,
      'description': latestTodo.description,
      'tags': List<String>.from(latestTodo.tags),
      'tagsWithColor':
          latestTodo.tagsWithColor.map((tag) => tag.toJson()).toList(),
      'priority': latestTodo.priority,
      'reminders': latestTodo.reminders,
      'dueDate': latestTodo.dueDate,
      'status': latestTodo.status,
    };

    initEditing(latestTodo, editState);

    state = state.copyWith(
      selectedTags: tags,
      isEditing: true,
      selectedPriority: latestTodo.priority,
      remindersValue: latestTodo.reminders,
      selectedStatus: latestTodo.status,
      selectedDate: latestTodo.dueDate > 0
          ? DateTime.fromMillisecondsSinceEpoch(latestTodo.dueDate)
          : null,
      clearSelectedDate: latestTodo.dueDate <= 0,
      // 重置脏标记，避免初始化时误判为已修改
      isDirty: false,
    );
  }

  @override
  bool checkForChanges(Map<String, dynamic> originalState) {
    bool titleChanged =
        !compareStrings(titleController.text, originalState['title']);
    bool descriptionChanged = !compareStrings(
        descriptionController.text, originalState['description']);

    // 比较带颜色的标签
    bool tagsChanged = false;
    if (originalState['tagsWithColor'] != null) {
      final originalTags = (originalState['tagsWithColor'] as List<dynamic>)
          .map((tag) => TagWithColor.fromJson(tag as Map<String, dynamic>))
          .toList();
      tagsChanged = selectedTags.length != originalTags.length ||
          !selectedTags.every((tag) => originalTags.any((originalTag) =>
              originalTag.name == tag.name &&
              originalTag.colorValue == tag.colorValue));
    }

    bool priorityChanged = state.selectedPriority != originalState['priority'];
    bool remindersChanged = state.remindersValue != originalState['reminders'];
    bool statusChanged = state.selectedStatus != originalState['status'];
    bool dateChanged = false;

    // 特殊处理日期比较
    if (state.selectedDate == null) {
      dateChanged = originalState['dueDate'] != 0;
    } else {
      dateChanged = state.selectedDate!.millisecondsSinceEpoch !=
          originalState['dueDate'];
    }

    // 调试日志
    if (titleChanged) {
      FormControllerMixin.logger.d(
          'Title changed: ${titleController.text} != ${originalState['title']}');
    }
    if (descriptionChanged) {
      FormControllerMixin.logger.d(
          'Description changed: ${descriptionController.text} != ${originalState['description']}');
    }
    if (tagsChanged) {
      FormControllerMixin.logger.d(
          'Tags changed: $selectedTags != ${originalState['tagsWithColor']}');
    }
    if (priorityChanged) {
      FormControllerMixin.logger.d(
          'Priority changed: ${state.selectedPriority} != ${originalState['priority']}');
    }
    if (remindersChanged) {
      FormControllerMixin.logger.d(
          'Reminders changed: ${state.remindersValue} != ${originalState['reminders']}');
    }
    if (statusChanged) {
      FormControllerMixin.logger.d(
          'Status changed: ${state.selectedStatus} != ${originalState['status']}');
    }
    if (dateChanged) {
      FormControllerMixin.logger.d(
          'Date changed: ${state.selectedDate?.millisecondsSinceEpoch} != ${originalState['dueDate']}');
    }

    return titleChanged ||
        descriptionChanged ||
        tagsChanged ||
        priorityChanged ||
        remindersChanged ||
        statusChanged ||
        dateChanged;
  }

  @override
  void restoreToOriginalState(Map<String, dynamic> originalState) {
    titleController.text = originalState['title'] as String;
    descriptionController.text = originalState['description'] as String;

    final List<TagWithColor> tags;
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (originalState['tagsWithColor'] != null) {
      final tagsWithColorJson = originalState['tagsWithColor'] as List<dynamic>;
      tags = tagsWithColorJson
          .map((tagJson) =>
              TagWithColor.fromJson(tagJson as Map<String, dynamic>))
          .toList();
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      tags = (originalState['tags'] as List<String>)
          .map((tag) => TagWithColor.fromString(tag))
          .toList();
    }

    final dueDate = originalState['dueDate'] as int;
    state = state.copyWith(
      selectedTags: tags,
      selectedPriority: originalState['priority'] as TodoPriority,
      remindersValue: originalState['reminders'] as int,
      selectedStatus: originalState['status'] as TodoStatus,
      selectedDate: dueDate > 0
          ? DateTime.fromMillisecondsSinceEpoch(dueDate)
          : null,
      clearSelectedDate: dueDate <= 0,
    );
  }

  bool get hasChanges {
    if (state.isEditing) {
      return hasUnsavedChanges();
    } else {
      return !isDataEmpty();
    }
  }

  // ---- state 字段的便捷 setter（供对话框 UI 调用）----
  void setSelectedDate(DateTime? date) =>
      state = state.copyWith(selectedDate: date, clearSelectedDate: date == null);
  void setSelectedPriority(TodoPriority priority) =>
      state = state.copyWith(selectedPriority: priority);
  void setRemindersValue(int value) =>
      state = state.copyWith(remindersValue: value);
  void setSelectedStatus(TodoStatus status) =>
      state = state.copyWith(selectedStatus: status);

  /// 编辑某个已选标签（替换索引处的标签）。
  void editTagAt(int index, TagWithColor tag) {
    if (index < 0 || index >= selectedTags.length) return;
    final newTags = List<TagWithColor>.from(selectedTags);
    newTags[index] = tag;
    state = state.copyWith(selectedTags: newTags);
  }
}
