import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:get/get.dart';

enum ConflictAction {
  skip,     // 跳过重复任务
  replace,  // 替换现有任务
  cancel,   // 取消导入
}

class ImportConflictDialog extends StatelessWidget {
  final List<String> conflictTasks;
  final VoidCallback onSkip;
  final VoidCallback onReplace;
  final VoidCallback onCancel;

  const ImportConflictDialog({
    super.key,
    required this.conflictTasks,
    required this.onSkip,
    required this.onReplace,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 450,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
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
              children: [
                Builder(
                  builder: (context) => Icon(
                    Icons.warning_amber_outlined,
                    size: 24,
                    color: context.theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'importConflictTitle'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  'conflictTasksDetected'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.theme.primaryColor.withValues(alpha:0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: conflictTasks.map((task) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• $task',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'selectHandlingMethod'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                // 选择按钮
                Column(
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.skip_next,
                      title: 'skipDuplicateTasks'.tr,
                      description: 'skipDuplicateTasksDesc'.tr,
                      onTap: onSkip,
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      context,
                      icon: Icons.swap_horiz,
                      title: 'replaceExistingTasks'.tr,
                      description: 'replaceExistingTasksDesc'.tr,
                      onTap: onReplace,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LabelBtn(
                          ghostStyle: true,
                          label: Text(
                            "cancel".tr,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          onPressed: onCancel,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.theme.dividerColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.theme.iconTheme.color?.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: context.theme.iconTheme.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.theme.textTheme.bodySmall?.color?.withValues(alpha:0.8),
                    ),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) => Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.theme.textTheme.bodyMedium?.color?.withValues(alpha:0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}