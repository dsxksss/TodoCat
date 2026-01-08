import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/base/base_form_controller.dart';
import 'package:todo_cat/controllers/todo_dialog_ctr.dart';
import 'package:todo_cat/widgets/todo_dialog.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class TodoDetailController extends BaseFormController {
  final String todoId;
  final String taskId;
  final Todo? previewTodo;

  final todo = Rx<Todo?>(null);
  final HomeController _homeController = Get.find();
  bool _isDisposed = false;
  bool _isNavigatingBack = false;

  TodoDetailController({
    required this.todoId,
    required this.taskId,
    this.previewTodo,
  });

  @override
  void onInit() {
    super.onInit();

    if (previewTodo != null) {
      todo.value = previewTodo;
      return;
    }

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

  bool get isPreview => previewTodo != null;

  void _loadTodoDetail() {
    if (_isDisposed || _isNavigatingBack || isPreview) {
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
            BaseFormController.logger
                .w('Todo not found: $todoId in task $taskId');
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
      tag: 'edit_todo_detail_dialog',
      dialog: const TodoDialog(dialogTag: 'edit_todo_detail_dialog'),
      useFixedSize: false, // TodoDialog 需要动态调整宽度以支持预览窗口
    );

    // 由于已经有自动监听机制，不需要手动刷新
  }

  void deleteTodo() async {
    if (todo.value == null) return;

    BaseFormController.logger.d('Deleting todo: $todoId');

    // 设置标志，防止自动监听器触发 Get.back()
    _isNavigatingBack = true;

    // 执行删除操作
    await _homeController.deleteTodo(taskId, todoId);

    BaseFormController.logger.d('Todo deleted, closing dialog/page...');

    // 添加短暂延迟，确保确认toast完全关闭后再关闭页面
    await Future.delayed(const Duration(milliseconds: 150));

    // 删除成功后关闭对话框或页面
    try {
      // 对话框tag格式：'todo_detail_dialog_${todoId}'
      final dialogTag = 'todo_detail_dialog_$todoId';

      // 尝试关闭SmartDialog（对话框模式）
      SmartDialog.dismiss(tag: dialogTag);
      BaseFormController.logger.d('Dialog dismissed with tag: $dialogTag');

      // 如果是页面模式（/todo-detail路由），也需要关闭页面
      if (Get.currentRoute == '/todo-detail') {
        Get.back();
        BaseFormController.logger.d('Page also closed with Get.back()');
      }

      // 清理controller
      if (Get.isRegistered<TodoDetailController>(tag: dialogTag)) {
        Get.delete<TodoDetailController>(tag: dialogTag);
      }
    } catch (e) {
      BaseFormController.logger.e('Error closing dialog/page: $e');
    }
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
