import 'package:get/get.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/controllers/base/base_form_controller.dart';
import 'package:TodoCat/controllers/todo_dialog_ctr.dart';
import 'package:TodoCat/keys/dialog_keys.dart';
import 'package:TodoCat/widgets/todo_dialog.dart';
import 'package:TodoCat/services/dialog_service.dart';

class TodoDetailController extends BaseFormController {
  final String todoId;
  final String taskId;

  final todo = Rx<Todo?>(null);
  final HomeController _homeController = Get.find();
  bool _isDisposed = false;
  bool _isNavigatingBack = false;

  TodoDetailController({
    required this.todoId,
    required this.taskId,
  });

  @override
  void onInit() {
    super.onInit();
    _loadTodoDetail();

    // 监听HomeController的响应式任务列表变化，自动刷新详情
    ever(_homeController.reactiveTasks, (_) {
      if (!_isDisposed && !_isNavigatingBack) {
        _loadTodoDetail();
      }
    });
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }

  void _loadTodoDetail() {
    if (_isDisposed || _isNavigatingBack) {
      return;
    }

    try {
      // 使用 firstWhereOrNull 避免找不到元素时抛出异常
      final task = _homeController.tasks.firstWhereOrNull(
        (task) => task.uuid == taskId,
      );

      if (task == null) {
        if (!_isNavigatingBack) {
          BaseFormController.logger.w('Task not found: $taskId');
          _isNavigatingBack = true;
          Get.back();
        }
        return;
      }

      if (task.todos != null) {
        final foundTodo = task.todos!.firstWhereOrNull(
          (todo) => todo.uuid == todoId,
        );

        if (foundTodo != null) {
          todo.value = foundTodo;
        } else {
          if (!_isNavigatingBack) {
            BaseFormController.logger.w('Todo not found: $todoId in task $taskId');
            _isNavigatingBack = true;
            Get.back();
          }
        }
      } else {
        if (!_isNavigatingBack) {
          BaseFormController.logger.w('Task todos is null: $taskId');
          _isNavigatingBack = true;
          Get.back();
        }
      }
    } catch (e) {
      if (!_isNavigatingBack) {
        BaseFormController.logger.e('Error loading todo detail: $e');
        _isNavigatingBack = true;
        Get.back();
      }
    }
  }

  /// 手动刷新待办详情数据
  void refreshTodoDetail() {
    _loadTodoDetail();
  }

  void editTodo() {
    if (todo.value == null) return;

    final todoDialogController = Get.put(
      AddTodoDialogController(),
      tag: 'edit_todo_detail_dialog',
      permanent: true,
    );

    todoDialogController.initForEditing(taskId, todo.value!);

    DialogService.showFormDialog(
      tag: addTodoDialogTag,
      dialog: const TodoDialog(dialogTag: 'edit_todo_detail_dialog'),
    );

    // 由于已经有自动监听机制，不需要手动刷新
  }

  void deleteTodo() async {
    if (todo.value == null) return;

    await _homeController.deleteTodo(taskId, todoId);
    Get.back();
  }

  String getPriorityText(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return 'lowLevel'.tr;
      case TodoPriority.mediumLevel:
        return 'mediumLevel'.tr;
      case TodoPriority.highLevel:
        return 'highLevel'.tr;
    }
  }

  String getStatusText(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return 'todo'.tr;
      case TodoStatus.inProgress:
        return 'inProgress'.tr;
      case TodoStatus.done:
        return 'done'.tr;
    }
  }

  bool checkFieldChanges() {
    // 详细信息页面不需要检查表单更改
    return false;
  }

  void restoreFields() {
    // 详细信息页面不需要恢复表单字段
  }
}
