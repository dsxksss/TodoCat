import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/utils/font_utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_cat/pages/home/components/task/task_card.dart';

enum TaskTemplateType {
  empty,    // 空模板
  content,  // 学生日程模板
  work,     // 工作管理模板
  fitness,  // 健身训练模板
  travel,   // 旅行计划模板
}

class TemplateSelectorDialog extends StatelessWidget {
  final Function(TaskTemplateType) onTemplateSelected;

  const TemplateSelectorDialog({
    Key? key,
    required this.onTemplateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.isPhone ? 1.sw : 450,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.dialogBackgroundColor,
          border: Border.all(width: 0.3, color: context.theme.dividerColor),
          borderRadius: context.isPhone
              ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )
              : BorderRadius.circular(10),
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.theme.dividerColor,
                  width: 0.3,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'selectTaskTemplate'.tr,
                  style: FontUtils.getBoldStyle(fontSize: 20),
                ),
                LabelBtn(
                  ghostStyle: true,
                  label: Text('cancel'.tr),
                  onPressed: () => SmartDialog.dismiss(tag: 'template_selector'),
                ),
              ],
            ),
          ),
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'selectTemplateType'.tr,
                  style: FontUtils.getTextStyle(
                    fontSize: 14,
                    color: context.theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTemplateOption(
                  context,
                  TaskTemplateType.empty,
                  'emptyTemplate'.tr,
                  'emptyTemplateDescription'.tr,
                  Icons.checklist_outlined,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildTemplateOption(
                  context,
                  TaskTemplateType.content,
                  'studentScheduleTemplate'.tr,
                  'studentScheduleTemplateDescription'.tr,
                  Icons.school_outlined,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildTemplateOption(
                  context,
                  TaskTemplateType.work,
                  'workManagementTemplate'.tr,
                  'workManagementTemplateDescription'.tr,
                  Icons.work_outline,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildTemplateOption(
                  context,
                  TaskTemplateType.fitness,
                  'fitnessTrainingTemplate'.tr,
                  'fitnessTrainingTemplateDescription'.tr,
                  Icons.fitness_center,
                  Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildTemplateOption(
                  context,
                  TaskTemplateType.travel,
                  'travelPlanTemplate'.tr,
                  'travelPlanTemplateDescription'.tr,
                  Icons.flight_takeoff,
                  Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildTemplateOption(
    BuildContext context,
    TaskTemplateType type,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return _TemplateOptionWithPreview(
      type: type,
      title: title,
      description: description,
      icon: icon,
      color: color,
      onTap: (shouldClosePreview) {
        _showConfirmDialog(context, type, title, shouldClosePreview);
      },
    );
  }

  void _showConfirmDialog(BuildContext context, TaskTemplateType type, String title, bool shouldClosePreview) {
    showToast(
      "confirmApplyTemplate".tr.replaceAll('{title}', title),
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.warning,
      onYesCallback: () {
        onTemplateSelected(type);
        SmartDialog.dismiss(tag: 'template_selector');
        if (shouldClosePreview) {
          SmartDialog.dismiss(tag: 'template_preview_$type');
        }
        showSuccessNotification("taskTemplateApplied".tr);
      },
    );
  }
}

/// 创建指定类型的任务模板
List<Task> createTaskTemplate(TaskTemplateType type) {
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  
  switch (type) {
    case TaskTemplateType.empty:
      return emptyTemplateTasks.map((task) {
        final newTask = Task()
          ..uuid = const Uuid().v4()
          ..title = task.title
          ..description = task.description
          ..createdAt = currentTime + emptyTemplateTasks.indexOf(task)
          ..tagsWithColor = task.tagsWithColor.map((tag) => tag.copyWith()).toList()
          ..status = task.status
          ..progress = task.progress
          ..reminders = task.reminders
          ..todos = [];
        
        return newTask;
      }).toList();
      
    case TaskTemplateType.content:
      return contentTemplateTasks.map((task) {
        final newTask = Task()
          ..uuid = const Uuid().v4()
          ..title = task.title
          ..description = task.description
          ..createdAt = currentTime + contentTemplateTasks.indexOf(task)
          ..tagsWithColor = task.tagsWithColor.map((tag) => tag.copyWith()).toList()
          ..status = task.status
          ..progress = task.progress
          ..reminders = task.reminders;
        
        // 复制todos并重新生成UUID和时间戳
        if (task.todos != null && task.todos!.isNotEmpty) {
          newTask.todos = task.todos!.map((todo) {
            return Todo()
              ..uuid = const Uuid().v4()
              ..title = todo.title
              ..description = todo.description
              ..createdAt = currentTime + contentTemplateTasks.indexOf(task) + task.todos!.indexOf(todo)
              ..tagsWithColor = todo.tagsWithColor.map((tag) => tag.copyWith()).toList()
              ..priority = todo.priority
              ..status = todo.status
              ..progress = todo.progress
              ..reminders = todo.reminders
              ..dueDate = todo.dueDate
              ..finishedAt = todo.finishedAt;
          }).toList();
        } else {
          newTask.todos = [];
        }
        
        return newTask;
      }).toList();
      
    case TaskTemplateType.work:
      return workTemplateTasks.map((task) {
        final newTask = Task()
          ..uuid = const Uuid().v4()
          ..title = task.title
          ..description = task.description
          ..createdAt = currentTime + workTemplateTasks.indexOf(task)
          ..tagsWithColor = task.tagsWithColor.map((tag) => tag.copyWith()).toList()
          ..status = task.status
          ..progress = task.progress
          ..reminders = task.reminders;
        
        // 复制todos并重新生成UUID和时间戳
        if (task.todos != null && task.todos!.isNotEmpty) {
          newTask.todos = task.todos!.map((todo) {
            return Todo()
              ..uuid = const Uuid().v4()
              ..title = todo.title
              ..description = todo.description
              ..createdAt = currentTime + workTemplateTasks.indexOf(task) + task.todos!.indexOf(todo)
              ..tagsWithColor = todo.tagsWithColor.map((tag) => tag.copyWith()).toList()
              ..priority = todo.priority
              ..status = todo.status
              ..progress = todo.progress
              ..reminders = todo.reminders
              ..dueDate = todo.dueDate
              ..finishedAt = todo.finishedAt;
          }).toList();
        } else {
          newTask.todos = [];
        }
        
        return newTask;
      }).toList();
      
    case TaskTemplateType.fitness:
      return fitnessTemplateTasks.map((task) {
        final newTask = Task()
          ..uuid = const Uuid().v4()
          ..title = task.title
          ..description = task.description
          ..createdAt = currentTime + fitnessTemplateTasks.indexOf(task)
          ..tagsWithColor = task.tagsWithColor.map((tag) => tag.copyWith()).toList()
          ..status = task.status
          ..progress = task.progress
          ..reminders = task.reminders;
        
        // 复制todos并重新生成UUID和时间戳
        if (task.todos != null && task.todos!.isNotEmpty) {
          newTask.todos = task.todos!.map((todo) {
            return Todo()
              ..uuid = const Uuid().v4()
              ..title = todo.title
              ..description = todo.description
              ..createdAt = currentTime + fitnessTemplateTasks.indexOf(task) + task.todos!.indexOf(todo)
              ..tagsWithColor = todo.tagsWithColor.map((tag) => tag.copyWith()).toList()
              ..priority = todo.priority
              ..status = todo.status
              ..progress = todo.progress
              ..reminders = todo.reminders
              ..dueDate = todo.dueDate
              ..finishedAt = todo.finishedAt;
          }).toList();
        } else {
          newTask.todos = [];
        }
        
        return newTask;
      }).toList();
      
    case TaskTemplateType.travel:
      return travelTemplateTasks.map((task) {
        final newTask = Task()
          ..uuid = const Uuid().v4()
          ..title = task.title
          ..description = task.description
          ..createdAt = currentTime + travelTemplateTasks.indexOf(task)
          ..tagsWithColor = task.tagsWithColor.map((tag) => tag.copyWith()).toList()
          ..status = task.status
          ..progress = task.progress
          ..reminders = task.reminders;
        
        // 复制todos并重新生成UUID和时间戳
        if (task.todos != null && task.todos!.isNotEmpty) {
          newTask.todos = task.todos!.map((todo) {
            return Todo()
              ..uuid = const Uuid().v4()
              ..title = todo.title
              ..description = todo.description
              ..createdAt = currentTime + travelTemplateTasks.indexOf(task) + task.todos!.indexOf(todo)
              ..tagsWithColor = todo.tagsWithColor.map((tag) => tag.copyWith()).toList()
              ..priority = todo.priority
              ..status = todo.status
              ..progress = todo.progress
              ..reminders = todo.reminders
              ..dueDate = todo.dueDate
              ..finishedAt = todo.finishedAt;
          }).toList();
        } else {
          newTask.todos = [];
        }
        
        return newTask;
      }).toList();
  }
}

/// 带预览的模板选项组件
class _TemplateOptionWithPreview extends StatefulWidget {
  final TaskTemplateType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Function(bool) onTap;

  const _TemplateOptionWithPreview({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TemplateOptionWithPreview> createState() => _TemplateOptionWithPreviewState();
}

class _TemplateOptionWithPreviewState extends State<_TemplateOptionWithPreview> {
  bool _isPreviewShowing = false;
  final GlobalKey _key = GlobalKey();

  void _showPreview() {
    if (_isPreviewShowing) return;
    
    _isPreviewShowing = true;
    
    SmartDialog.show(
      tag: 'template_preview_${widget.type}',
      alignment: Alignment.center,
      maskColor: Colors.black.withOpacity(0.3),
      clickMaskDismiss: true,
      useSystem: false, // 使用系统overlay，降低层级
      onDismiss: () {
        _isPreviewShowing = false;
      },
      builder: (_) => _buildPreviewOverlay(),
      animationBuilder: (controller, child, _) => ScaleTransition(
        scale: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: controller,
          child: child,
        ),
      ),
    );
  }

  void _hidePreview() {
    if (!_isPreviewShowing) return;
    
    SmartDialog.dismiss(tag: 'template_preview_${widget.type}');
    _isPreviewShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: () {
        if (!_isPreviewShowing) {
          _showPreview();
        } else {
          _hidePreview();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.theme.dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: context.theme.cardColor,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: FontUtils.getMediumStyle(
                      fontSize: 16,
                      color: context.theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: FontUtils.getTextStyle(
                      fontSize: 13,
                      color: context.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewOverlay() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: _buildPreview(),
        ),
      ],
    );
  }

  void _applyTemplate() {
    widget.onTap(true); // 从预览窗口应用，需要关闭预览窗口
  }

  Widget _buildPreview() {
    final templates = _getTemplateData();
    
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 1250, // 4个260宽的卡片 + 3个50的间距 + padding: 260*4 + 50*3 + 40 = 1250
        height: 640,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: context.theme.dialogBackgroundColor,
          border: Border.all(width: 1, color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.theme.dividerColor.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'templatePreview'.tr,
                    style: FontUtils.getBoldStyle(fontSize: 18),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LabelBtn(
                        label: Text('apply'.tr,style:const TextStyle(color: Colors.white)),
                        onPressed: _applyTemplate,
                        bgColor: Colors.lightBlue,
                      ),
                      const SizedBox(width: 12),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _hidePreview,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.theme.dividerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: context.theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 预览内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 50,
                  runSpacing: 30,
                  children: templates.map((task) => _buildPreviewTaskCard(task)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTaskCard(Task task) {
    return IgnorePointer(
      child: TaskCard(task: task),
    );
  }

  List<Task> _getTemplateData() {
    switch (widget.type) {
      case TaskTemplateType.empty:
        return emptyTemplateTasks;
      case TaskTemplateType.content:
        return contentTemplateTasks;
      case TaskTemplateType.work:
        return workTemplateTasks;
      case TaskTemplateType.fitness:
        return fitnessTemplateTasks;
      case TaskTemplateType.travel:
        return travelTemplateTasks;
    }
  }

}

/// 显示模板选择对话框
void showTemplateSelectorDialog(Function(TaskTemplateType) onTemplateSelected) {
  // 使用SmartDialog确保对话框显示在最顶层
  SmartDialog.show(
    tag: 'template_selector',
    alignment: Alignment.center,
    maskColor: Colors.black.withOpacity(0.5),
    clickMaskDismiss: true,
    useAnimation: true,
    animationTime: const Duration(milliseconds: 300),
    builder: (_) => TemplateSelectorDialog(onTemplateSelected: onTemplateSelected),
    animationBuilder: (controller, child, animationParam) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: controller,
          child: child,
        ),
      );
    },
  );
}
