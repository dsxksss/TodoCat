import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_cat/controllers/base_dialog_ctr.dart';

class AddTodoDialogController extends BaseDialogController {
  static final Map<String, Map<String, dynamic>> _dialogCache = {};
  final String dialogId = DateTime.now().millisecondsSinceEpoch.toString();

  Todo? todoToEdit;
  String? taskId;
  final selectedPriority = TodoPriority.lowLevel.obs;
  final remindersValue = 0.obs;
  final remindersText = "".obs;

  Map<String, dynamic>? _originalState;

  @override
  void onInit() {
    super.onInit();
    _originalState = null;
    ever(isEditing, (_) {
      // 当编辑状态改变时，确保数据正确更新
      if (isEditing.value && todoToEdit != null) {
        _updateFormData();
      }
    });
  }

  void _updateFormData() {
    titleController.text = todoToEdit!.title;
    descriptionController.text = todoToEdit!.description;
    selectedTags.value = List<String>.from(todoToEdit!.tags);
    selectedPriority.value = todoToEdit!.priority;
    remindersValue.value = todoToEdit!.reminders;

    if (todoToEdit!.finishedAt > 0) {
      selectedDate.value =
          DateTime.fromMillisecondsSinceEpoch(todoToEdit!.finishedAt);
    }
  }

  Future<bool> submitForm() async {
    if (!formKey.currentState!.validate()) return false;

    if (isEditing.value && todoToEdit != null && taskId != null) {
      final updatedTodo = Todo()
        ..uuid = todoToEdit!.uuid
        ..title = titleController.text
        ..description = descriptionController.text
        ..createdAt = todoToEdit!.createdAt
        ..tags = selectedTags.toList()
        ..priority = selectedPriority.value
        ..status = todoToEdit!.status
        ..finishedAt = selectedDate.value?.millisecondsSinceEpoch ?? 0
        ..reminders = remindersValue.value;

      try {
        final task = Get.find<HomeController>()
            .tasks
            .firstWhere((task) => task.uuid == taskId);

        task.todos ??= [];

        final todoIndex = task.todos!.indexWhere(
          (todo) => todo.uuid == todoToEdit!.uuid,
        );

        if (todoIndex != -1) {
          task.todos![todoIndex] = updatedTodo;
          await Get.find<HomeController>().updateTask(taskId!, task);
          clearForm();
          return true;
        }
      } catch (e) {
        BaseDialogController.logger.e('Error updating todo: $e');
      }
    } else {
      if (taskId == null || taskId!.isEmpty) {
        BaseDialogController.logger.e('No task ID provided for new todo');
        showToast(
          'selectTaskFirst'.tr,
          toastStyleType: TodoCatToastStyleType.error,
        );
        return false;
      }

      try {
        final task = Get.find<HomeController>()
            .tasks
            .firstWhereOrNull((task) => task.uuid == taskId);

        if (task == null) {
          BaseDialogController.logger.e('Task not found: $taskId');
          showToast(
            'taskNotFound'.tr,
            toastStyleType: TodoCatToastStyleType.error,
          );
          return false;
        }
      } catch (e) {
        BaseDialogController.logger.e('Error finding task: $e');
        showToast(
          'taskNotFound'.tr,
          toastStyleType: TodoCatToastStyleType.error,
        );
        return false;
      }

      final todo = Todo()
        ..uuid = const Uuid().v4()
        ..title = titleController.text
        ..description = descriptionController.text
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tags = selectedTags.toList()
        ..priority = selectedPriority.value
        ..status = TodoStatus.todo
        ..finishedAt = selectedDate.value?.millisecondsSinceEpoch ?? 0
        ..reminders = remindersValue.value;

      try {
        final bool isSuccess =
            await Get.find<HomeController>().addTodo(todo, taskId!);
        if (isSuccess) {
          clearForm();
          return true;
        }
      } catch (e) {
        BaseDialogController.logger.e('Error submitting todo: $e');
        showToast(
          'addTodoFailed'.tr,
          toastStyleType: TodoCatToastStyleType.error,
        );
      }
    }
    return false;
  }

  bool isDataNotEmpty() {
    return titleController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        selectedTags.isNotEmpty ||
        selectedDate.value != null ||
        selectedPriority.value != TodoPriority.lowLevel ||
        remindersValue.value != 0;
  }

  void saveCache() {
    BaseDialogController.logger.d('Saving form cache');
    _dialogCache[dialogId] = {
      'title': titleController.text,
      'description': descriptionController.text,
      'tags': selectedTags.toList(),
      'date': selectedDate.value,
      'priority': selectedPriority.value.index,
      'reminders': remindersValue.value,
    };
  }

  @override
  void clearForm() {
    BaseDialogController.logger.d('Clearing todo form');
    super.clearForm();
    todoToEdit = null;
    taskId = null;
    isEditing.value = false;
    selectedPriority.value = TodoPriority.lowLevel;
    remindersText.value = "${"enter".tr}${"time".tr}";
    remindersValue.value = 0;
    selectedDate.value = null;
    _dialogCache.remove(dialogId);
    _originalState = null;
  }

  void initForEditing(String taskId, Todo todo) {
    this.taskId = taskId;
    todoToEdit = todo;
    isEditing.value = true;

    // 保存原有状态
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    selectedTags.value = List<String>.from(todo.tags);
    selectedPriority.value = todo.priority;
    remindersValue.value = todo.reminders;

    if (todo.finishedAt > 0) {
      selectedDate.value = DateTime.fromMillisecondsSinceEpoch(todo.finishedAt);
    } else {
      selectedDate.value = null;
    }

    // 记录原始状态用于比较
    _originalState = {
      'title': todo.title,
      'description': todo.description,
      'tags': List<String>.from(todo.tags),
      'priority': todo.priority,
      'reminders': todo.reminders,
      'finishedAt': todo.finishedAt,
    };

    BaseDialogController.logger.d('Original state saved: $_originalState');
  }

  bool hasChanges() {
    if (!isEditing.value || _originalState == null) return false;

    // 只有当实际有改变时才返回 true
    bool titleChanged = titleController.text != _originalState!['title'];
    bool descriptionChanged =
        descriptionController.text != _originalState!['description'];
    bool tagsChanged =
        !listEquals(selectedTags, _originalState!['tags'] as List<String>);
    bool priorityChanged =
        selectedPriority.value != _originalState!['priority'];
    bool remindersChanged =
        remindersValue.value != _originalState!['reminders'];
    bool dateChanged = false;

    // 特殊处理日期比较
    if (selectedDate.value == null) {
      dateChanged = _originalState!['finishedAt'] != 0;
    } else {
      dateChanged = selectedDate.value!.millisecondsSinceEpoch !=
          _originalState!['finishedAt'];
    }

    // 调试日志
    if (titleChanged) {
      BaseDialogController.logger.d(
          'Title changed: ${titleController.text} != ${_originalState!['title']}');
    }
    if (descriptionChanged) {
      BaseDialogController.logger.d(
          'Description changed: ${descriptionController.text} != ${_originalState!['description']}');
    }
    if (tagsChanged) {
      BaseDialogController.logger
          .d('Tags changed: $selectedTags != ${_originalState!['tags']}');
    }
    if (priorityChanged) {
      BaseDialogController.logger.d(
          'Priority changed: ${selectedPriority.value} != ${_originalState!['priority']}');
    }
    if (remindersChanged) {
      BaseDialogController.logger.d(
          'Reminders changed: ${remindersValue.value} != ${_originalState!['reminders']}');
    }
    if (dateChanged) {
      BaseDialogController.logger.d(
          'Date changed: ${selectedDate.value?.millisecondsSinceEpoch} != ${_originalState!['finishedAt']}');
    }

    return titleChanged ||
        descriptionChanged ||
        tagsChanged ||
        priorityChanged ||
        remindersChanged ||
        dateChanged;
  }

  void restoreOriginalState() {
    if (!isEditing.value || _originalState == null) return;

    titleController.text = _originalState!['title'] as String;
    descriptionController.text = _originalState!['description'] as String;
    selectedTags.value =
        List<String>.from(_originalState!['tags'] as List<String>);
    selectedPriority.value = _originalState!['priority'] as TodoPriority;
    remindersValue.value = _originalState!['reminders'] as int;

    final finishedAt = _originalState!['finishedAt'] as int;
    if (finishedAt > 0) {
      selectedDate.value = DateTime.fromMillisecondsSinceEpoch(finishedAt);
    } else {
      selectedDate.value = null;
    }
  }

  // ... 其他特定于办事项的方法
}
