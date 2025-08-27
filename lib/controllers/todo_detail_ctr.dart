import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/base/base_form_controller.dart';
import 'package:todo_cat/controllers/todo_dialog_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/todo_dialog.dart';
import 'package:todo_cat/services/dialog_service.dart';

class TodoDetailController extends BaseFormController {
  final String todoId;
  final String taskId;

  final todo = Rx<Todo?>(null);
  final HomeController _homeController = Get.find();

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
      _loadTodoDetail();
    });
  }

  void _loadTodoDetail() {
    try {
      final task = _homeController.tasks.firstWhere(
        (task) => task.uuid == taskId,
      );

      if (task.todos != null) {
        final foundTodo = task.todos!.firstWhereOrNull(
          (todo) => todo.uuid == todoId,
        );

        if (foundTodo != null) {
          todo.value = foundTodo;
        } else {
          BaseFormController.logger.w('Todo not found: $todoId');
          Get.back();
        }
      } else {
        BaseFormController.logger.w('Task todos is null: $taskId');
        Get.back();
      }
    } catch (e) {
      BaseFormController.logger.e('Error loading todo detail: $e');
      Get.back();
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
