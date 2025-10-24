import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_cat/controllers/base/base_form_controller.dart';
import 'package:todo_cat/controllers/mixins/edit_state_mixin.dart';

class AddTodoDialogController extends BaseFormController with EditStateMixin {
  static final Map<String, Map<String, dynamic>> _dialogCache = {};
  final String dialogId = DateTime.now().millisecondsSinceEpoch.toString();

  String? taskId;
  final selectedPriority = TodoPriority.lowLevel.obs;
  final remindersValue = 0.obs;
  final remindersText = "".obs;
  final selectedDate = Rx<DateTime?>(null);
  final selectedStatus = TodoStatus.todo.obs;

  @override
  void onInit() {
    super.onInit();
    ever(isEditing, (_) {
      // 当编辑状态改变时，确保数据正确更新
      if (isEditing.value && getEditingItem<Todo>() != null) {
        _updateFormData();
      }
    });
  }

  void _updateFormData() {
    final todo = getEditingItem<Todo>()!;
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (todo.tagsWithColor.isNotEmpty) {
      selectedTags.value = todo.tagsWithColor;
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      selectedTags.value = todo.tags.map((tag) => 
          TagWithColor.fromString(tag)).toList();
    }
    
    selectedPriority.value = todo.priority;
    remindersValue.value = todo.reminders;
    selectedStatus.value = todo.status;

    if (todo.dueDate > 0) {
      selectedDate.value = DateTime.fromMillisecondsSinceEpoch(todo.dueDate);
    }
  }

  Future<bool> submitForm() async {
    if (!validateForm()) return false;

    if (isEditing.value && getEditingItem<Todo>() != null && taskId != null) {
      final currentTodo = getEditingItem<Todo>()!;
      final updatedTodo = Todo()
        ..uuid = currentTodo.uuid
        ..title = titleController.text
        ..description = descriptionController.text
        ..createdAt = currentTodo.createdAt
        ..tagsWithColor = selectedTags.toList()
        ..priority = selectedPriority.value
        ..status = selectedStatus.value
        ..finishedAt = selectedStatus.value == TodoStatus.done
            ? (currentTodo.finishedAt > 0
                ? currentTodo.finishedAt
                : DateTime.now().millisecondsSinceEpoch)
            : 0
        ..dueDate = selectedDate.value?.millisecondsSinceEpoch ?? 0
        ..reminders = remindersValue.value;

      try {
        final task = Get.find<HomeController>()
            .tasks
            .firstWhere((task) => task.uuid == taskId);

        task.todos ??= [];

        final todoIndex = task.todos!.indexWhere(
          (todo) => todo.uuid == currentTodo.uuid,
        );

        if (todoIndex != -1) {
          task.todos![todoIndex] = updatedTodo;
          await Get.find<HomeController>().updateTask(taskId!, task);
          // 不在这里清理表单，让对话框处理
          return true;
        }
      } catch (e) {
        BaseFormController.logger.e('Error updating todo: $e');
      }
    } else {
      if (taskId == null || taskId!.isEmpty) {
        BaseFormController.logger.e('No task ID provided for new todo');
        showErrorToast('selectTaskFirst'.tr);
        return false;
      }

      try {
        final task = Get.find<HomeController>()
            .tasks
            .firstWhereOrNull((task) => task.uuid == taskId);

        if (task == null) {
          BaseFormController.logger.e('Task not found: $taskId');
          showErrorToast('taskNotFound'.tr);
          return false;
        }
      } catch (e) {
        BaseFormController.logger.e('Error finding task: $e');
        showErrorToast('taskNotFound'.tr);
        return false;
      }

      final todo = Todo()
        ..uuid = const Uuid().v4()
        ..title = titleController.text
        ..description = descriptionController.text
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tagsWithColor = selectedTags.toList()
        ..priority = selectedPriority.value
        ..status = TodoStatus.todo
        ..finishedAt = 0
        ..dueDate = selectedDate.value?.millisecondsSinceEpoch ?? 0
        ..reminders = remindersValue.value;

      try {
        final bool isSuccess =
            await Get.find<HomeController>().addTodo(todo, taskId!);
        if (isSuccess) {
          // 不在这里清理表单，让对话框处理
          return true;
        }
      } catch (e) {
        BaseFormController.logger.e('Error submitting todo: $e');
        showErrorToast('addTodoFailed'.tr);
      }
    }
    return false;
  }

  @override
  bool isDataEmpty() {
    return super.isDataEmpty() &&
        selectedDate.value == null &&
        selectedPriority.value == TodoPriority.lowLevel &&
        remindersValue.value == 0 &&
        selectedStatus.value == TodoStatus.todo;
  }

  void saveCache() {
    BaseFormController.logger.d('Saving form cache');
    _dialogCache[dialogId] = {
      'title': titleController.text,
      'description': descriptionController.text,
      'tagsWithColor': selectedTags.map((tag) => tag.toJson()).toList(),
      'date': selectedDate.value,
      'priority': selectedPriority.value.index,
      'reminders': remindersValue.value,
    };
  }

  void restoreCacheIfAny() {
    BaseFormController.logger.d('Restoring form cache if available');
    final cache = _dialogCache[dialogId];
    if (cache == null) return;

    titleController.text = cache['title'] as String? ?? '';
    descriptionController.text = cache['description'] as String? ?? '';
    
    // 处理标签缓存 - 兼容旧格式
    if (cache['tagsWithColor'] != null) {
      final tagsWithColorJson = cache['tagsWithColor'] as List<dynamic>;
      selectedTags.value = tagsWithColorJson
          .map((tagJson) => TagWithColor.fromJson(tagJson as Map<String, dynamic>))
          .toList();
    } else {
      // 兼容旧格式的字符串标签
      final stringTags = List<String>.from((cache['tags'] as List?) ?? const []);
      selectedTags.value = stringTags.map((tag) => TagWithColor.fromString(tag)).toList();
    }

    final priorityIndex = cache['priority'] as int? ?? TodoPriority.lowLevel.index;
    selectedPriority.value = TodoPriority.values[priorityIndex];

    remindersValue.value = cache['reminders'] as int? ?? 0;

    final DateTime? date = cache['date'] as DateTime?;
    selectedDate.value = date;

    // 状态未参与缓存，默认保持为待办状态
    selectedStatus.value = TodoStatus.todo;
  }

  @override
  void clearForm() {
    BaseFormController.logger.d('Clearing todo form');
    super.clearForm();
    taskId = null;
    selectedPriority.value = TodoPriority.lowLevel;
    remindersText.value = "${'enter'.tr}${'time'.tr}";
    remindersValue.value = 0;
    selectedDate.value = null;
    selectedStatus.value = TodoStatus.todo;
    _dialogCache.remove(dialogId);
    exitEditing();
  }

  void initForEditing(String taskId, Todo todo) {
    this.taskId = taskId;

    // 设置表单数据
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (todo.tagsWithColor.isNotEmpty) {
      selectedTags.value = todo.tagsWithColor;
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      selectedTags.value = todo.tags.map((tag) => TagWithColor.fromString(tag)).toList();
    }
    selectedPriority.value = todo.priority;
    remindersValue.value = todo.reminders;
    selectedStatus.value = todo.status;

    if (todo.dueDate > 0) {
      selectedDate.value = DateTime.fromMillisecondsSinceEpoch(todo.dueDate);
    } else {
      selectedDate.value = null;
    }

    // 使用编辑状态管理
    final state = {
      'title': todo.title,
      'description': todo.description,
      'tags': List<String>.from(todo.tags),
      'tagsWithColor': todo.tagsWithColor.map((tag) => tag.toJson()).toList(),
      'priority': todo.priority,
      'reminders': todo.reminders,
      'dueDate': todo.dueDate,
      'status': todo.status,
    };

    initEditing(todo, state);
  }

  @override
  bool checkForChanges(Map<String, dynamic> originalState) {
    bool titleChanged =
        !compareStrings(titleController.text, originalState['title']);
    bool descriptionChanged = !compareStrings(
        descriptionController.text, originalState['description']);
    bool tagsChanged = !compareListEquality(
        selectedTags, originalState['tags'] as List<String>);
    bool priorityChanged = selectedPriority.value != originalState['priority'];
    bool remindersChanged = remindersValue.value != originalState['reminders'];
    bool statusChanged = selectedStatus.value != originalState['status'];
    bool dateChanged = false;

    // 特殊处理日期比较
    if (selectedDate.value == null) {
      dateChanged = originalState['dueDate'] != 0;
    } else {
      dateChanged = selectedDate.value!.millisecondsSinceEpoch !=
          originalState['dueDate'];
    }

    // 调试日志
    if (titleChanged) {
      BaseFormController.logger.d(
          'Title changed: ${titleController.text} != ${originalState['title']}');
    }
    if (descriptionChanged) {
      BaseFormController.logger.d(
          'Description changed: ${descriptionController.text} != ${originalState['description']}');
    }
    if (tagsChanged) {
      BaseFormController.logger
          .d('Tags changed: $selectedTags != ${originalState['tags']}');
    }
    if (priorityChanged) {
      BaseFormController.logger.d(
          'Priority changed: ${selectedPriority.value} != ${originalState['priority']}');
    }
    if (remindersChanged) {
      BaseFormController.logger.d(
          'Reminders changed: ${remindersValue.value} != ${originalState['reminders']}');
    }
    if (statusChanged) {
      BaseFormController.logger.d(
          'Status changed: ${selectedStatus.value} != ${originalState['status']}');
    }
    if (dateChanged) {
      BaseFormController.logger.d(
          'Date changed: ${selectedDate.value?.millisecondsSinceEpoch} != ${originalState['dueDate']}');
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
    // 优先使用带颜色的标签，如果没有则转换旧格式的标签
    if (originalState['tagsWithColor'] != null) {
      final tagsWithColorJson = originalState['tagsWithColor'] as List<dynamic>;
      selectedTags.value = tagsWithColorJson
          .map((tagJson) => TagWithColor.fromJson(tagJson as Map<String, dynamic>))
          .toList();
    } else {
      // 兼容旧格式：转换字符串标签为带颜色的标签
      selectedTags.value = (originalState['tags'] as List<String>)
          .map((tag) => TagWithColor.fromString(tag))
          .toList();
    }
    selectedPriority.value = originalState['priority'] as TodoPriority;
    remindersValue.value = originalState['reminders'] as int;
    selectedStatus.value = originalState['status'] as TodoStatus;

    final dueDate = originalState['dueDate'] as int;
    if (dueDate > 0) {
      selectedDate.value = DateTime.fromMillisecondsSinceEpoch(dueDate);
    } else {
      selectedDate.value = null;
    }
  }

  bool get hasChanges {
    if (isEditing.value) {
      return hasUnsavedChanges();
    } else {
      return !isDataEmpty();
    }
  }
}
