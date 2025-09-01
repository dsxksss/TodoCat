import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/todo_detail_ctr.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/core/utils/date_time.dart';
import 'package:todo_cat/pages/home/components/tag.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/todocat_scaffold.dart';

class TodoDetailPage extends StatelessWidget {
  final String todoId;
  final String taskId;

  const TodoDetailPage({
    super.key,
    required this.todoId,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TodoDetailController(
      todoId: todoId,
      taskId: taskId,
    ));

    return TodoCatScaffold(
      title: 'todoDetail'.tr,
      rightWidgets: _buildRightWidgets(controller),
      body: Obx(() {
        final todo = controller.todo.value;
        if (todo == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题部分
              _buildTitleSection(context, todo),
              const SizedBox(height: 20),
              
              // 描述部分
              if (todo.description.isNotEmpty) ...[
                _buildDescriptionSection(context, todo),
                const SizedBox(height: 20),
              ],
              
              // 状态和优先级
              _buildStatusSection(context, todo, controller),
              const SizedBox(height: 20),
              
              // 标签部分
              if (todo.tags.isNotEmpty) ...[
                _buildTagsSection(context, todo),
                const SizedBox(height: 20),
              ],
              
              // 时间信息
              _buildTimeSection(context, todo),
              
              // 提醒信息
              if (todo.reminders > 0) ...[
                const SizedBox(height: 20),
                _buildReminderSection(context, todo),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTitleSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.clipboard,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'title'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todo.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildDescriptionSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.fileLines,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'description'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todo.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate(delay: 50.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildStatusSection(BuildContext context, Todo todo, TodoDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.circleInfo,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'status'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(todo.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(todo.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    controller.getStatusText(todo.status),
                    style: TextStyle(
                      color: _getStatusColor(todo.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.flag,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'priority'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(todo.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getPriorityColor(todo.priority),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    controller.getPriorityText(todo.priority),
                    style: TextStyle(
                      color: _getPriorityColor(todo.priority),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildTagsSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.tags,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'tags'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: todo.tags.map((tagText) {
                  // 为不同的标签使用不同的颜色
                  final colors = [
                    Colors.blueAccent,
                    Colors.greenAccent,
                    Colors.orangeAccent,
                    Colors.purpleAccent,
                    Colors.tealAccent,
                    Colors.pinkAccent,
                  ];
                  final colorIndex = tagText.hashCode % colors.length;
                  
                  // 限制标签文本长度，防止溢出
                  String displayText = tagText;
                  if (tagText.length > 15) {
                    displayText = '${tagText.substring(0, 12)}...';
                  }
                  
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.45, // 限制单个标签最大宽度为容器的45%
                    ),
                    child: Tag(
                      tag: displayText,
                      color: colors[colorIndex.abs()],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildTimeSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.clock,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'timeInfo'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'createdAt'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timestampToDate(todo.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (todo.finishedAt > 0) ...[
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dueDate'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timestampToDate(todo.finishedAt),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildReminderSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.bell,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'reminderTime'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${todo.reminders} ${'minute'.tr}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 200.ms);
  }

  List<Widget> _buildRightWidgets(TodoDetailController controller) {
    return [
      Obx(() {
        if (controller.todo.value == null) return const SizedBox.shrink();
        
        return SizedBox(
          width: 40,
          height: 40,
          child: AnimationBtn(
            onPressed: () => controller.editTodo(),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Get.theme.dividerColor,
                  width: 0.5,
                ),
              ),
              child: const Icon(
                FontAwesomeIcons.penToSquare,
                size: 16,
              ),
            ),
          ),
        );
      }),
      Obx(() {
        if (controller.todo.value == null) return const SizedBox.shrink();
        
        return SizedBox(
          width: 40,
          height: 40,
          child: AnimationBtn(
            onPressed: () {
              showToast(
                "sureDeleteTodo".tr,
                alwaysShow: true,
                confirmMode: true,
                toastStyleType: TodoCatToastStyleType.error,
                onYesCallback: () => controller.deleteTodo(),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.shade300,
                  width: 0.5,
                ),
              ),
              child: Icon(
                FontAwesomeIcons.trashCan,
                size: 16,
                color: Colors.red.shade400,
              ),
            ),
          ),
        );
      }),
    ];
  }

  Color _getStatusColor(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Colors.orange;
      case TodoStatus.inProgress:
        return Colors.blue;
      case TodoStatus.done:
        return Colors.green;
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return const Color.fromRGBO(46, 204, 147, 1);
      case TodoPriority.mediumLevel:
        return const Color.fromARGB(255, 251, 136, 94);
      case TodoPriority.highLevel:
        return const Color.fromARGB(255, 251, 98, 98);
    }
  }
}