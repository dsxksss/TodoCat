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

enum TaskTemplateType {
  empty,    // 空模板
  content,  // 有内容的模板
}

class TemplateSelectorDialog extends StatelessWidget {
  final Function(TaskTemplateType) onTemplateSelected;

  const TemplateSelectorDialog({
    Key? key,
    required this.onTemplateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 450,
      decoration: BoxDecoration(
        color: context.theme.dialogBackgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : BorderRadius.circular(10),
        // 移除阴影效果，避免亮主题下的亮光高亮
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: context.theme.dividerColor,
        //     blurRadius: context.isDarkMode ? 1 : 2,
        //   ),
        // ],
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
              ],
            ),
          ),
        ],
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
    return InkWell(
      onTap: () {
        _showConfirmDialog(context, type, title);
      },
      borderRadius: BorderRadius.circular(8),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FontUtils.getMediumStyle(
                      fontSize: 16,
                      color: context.theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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

  void _showConfirmDialog(BuildContext context, TaskTemplateType type, String title) {
    showToast(
      "confirmApplyTemplate".tr.replaceAll('{title}', title),
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.warning,
      onYesCallback: () {
        onTemplateSelected(type);
        SmartDialog.dismiss(tag: 'template_selector');
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
