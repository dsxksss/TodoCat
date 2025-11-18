import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/widgets/label_btn.dart';

/// 同名项处理方式枚举
enum DuplicateNameAction {
  merge,      // 合并
  rename,      // 重命名（添加工作空间后缀）
  allow,       // 允许同名
  cancel,      // 取消
}

/// 同名项处理对话框
class DuplicateNameDialog extends StatelessWidget {
  final String itemName;
  final String itemType;
  final String sourceWorkspaceName;
  final String targetWorkspaceName;
  final Function(DuplicateNameAction action) onActionSelected;

  const DuplicateNameDialog({
    super.key,
    required this.itemName,
    required this.itemType,
    required this.sourceWorkspaceName,
    required this.targetWorkspaceName,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 430,
      height: context.isPhone ? 0.7.sh : 500,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
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
                  'duplicateNameTitle'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LabelBtn(
                  label: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    SmartDialog.dismiss(tag: duplicateNameDialogTag);
                    onActionSelected(DuplicateNameAction.cancel);
                  },
                  padding: EdgeInsets.zero,
                  ghostStyle: true,
                ),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 提示信息
                  Text(
                    'duplicateNameMessage'.tr
                        .replaceAll('{itemType}', itemType.tr)
                        .replaceAll('{itemName}', itemName)
                        .replaceAll('{source}', sourceWorkspaceName)
                        .replaceAll('{target}', targetWorkspaceName),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 选项按钮
                  Column(
                    children: [
                      // 合并选项
                      _buildActionButton(
                        context: context,
                        icon: Icons.merge_type,
                        iconColor: Colors.blueAccent.shade400,
                        title: 'duplicateNameMerge'.tr,
                        description: 'duplicateNameMergeDesc'.tr,
                        onTap: () {
                          SmartDialog.dismiss(tag: duplicateNameDialogTag);
                          onActionSelected(DuplicateNameAction.merge);
                        },
                      ),
                      const SizedBox(height: 12),
                      // 重命名选项
                      _buildActionButton(
                        context: context,
                        icon: Icons.drive_file_rename_outline,
                        iconColor: Colors.orangeAccent.shade400,
                        title: 'duplicateNameRename'.tr,
                        description: 'duplicateNameRenameDesc'.tr
                            .replaceAll('{itemName}', itemName)
                            .replaceAll('{source}', sourceWorkspaceName),
                        onTap: () {
                          SmartDialog.dismiss(tag: duplicateNameDialogTag);
                          onActionSelected(DuplicateNameAction.rename);
                        },
                      ),
                      const SizedBox(height: 12),
                      // 允许同名选项
                      _buildActionButton(
                        context: context,
                        icon: Icons.check_circle_outline,
                        iconColor: Colors.greenAccent.shade700,
                        title: 'duplicateNameAllow'.tr,
                        description: 'duplicateNameAllowDesc'.tr,
                        onTap: () {
                          SmartDialog.dismiss(tag: duplicateNameDialogTag);
                          onActionSelected(DuplicateNameAction.allow);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示同名项处理对话框
/// [itemName] 要移动的项名称
/// [itemType] 项类型（'task' 或 'todo'）
/// [sourceWorkspaceName] 源工作空间名称
/// [targetWorkspaceName] 目标工作空间名称
/// [onActionSelected] 用户选择处理方式的回调
void showDuplicateNameDialog({
  required String itemName,
  required String itemType,
  required String sourceWorkspaceName,
  required String targetWorkspaceName,
  required Function(DuplicateNameAction action) onActionSelected,
}) {
  DialogService.showFormDialog(
    tag: duplicateNameDialogTag,
    dialog: DuplicateNameDialog(
      itemName: itemName,
      itemType: itemType,
      sourceWorkspaceName: sourceWorkspaceName,
      targetWorkspaceName: targetWorkspaceName,
      onActionSelected: onActionSelected,
    ),
  );
}

/// 构建操作按钮
Widget _buildActionButton({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String description,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.theme.hoverColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

