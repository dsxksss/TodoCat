import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/widgets/label_btn.dart';

import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/responsive.dart';

class DataExportConfirmDialog extends StatelessWidget {
  final Map<String, dynamic> preview;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DataExportConfirmDialog({
    super.key,
    required this.preview,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 400,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.confirmExport,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    LabelBtn(
                      ghostStyle: true,
                      label: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      onPressed: onCancel,
                    ),
                    const SizedBox(width: 8),
                    LabelBtn(
                      label: Text(
                        l10n.confirm,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      onPressed: onConfirm,
                    ),
                  ],
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
                  l10n.exportDataPreview,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDataItem(l10n.tasksCount, '${preview['tasksCount']}', context),
                const SizedBox(height: 8),
                _buildDataItem(l10n.todosCount, '${preview['todosCount']}', context),
                const SizedBox(height: 8),
                _buildDataItem(l10n.appConfig, preview['hasAppConfig'] ? l10n.yes : l10n.no, context),
                const SizedBox(height: 8),
                _buildDataItem(l10n.estimatedSize, '${preview['dataSize']} KB', context),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.theme.primaryColor.withValues(alpha:0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: context.theme.iconTheme.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.exportDataNotice,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.theme.textTheme.bodySmall?.color?.withValues(alpha:0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String value, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: context.theme.textTheme.bodyMedium?.color?.withValues(alpha:0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: context.theme.textTheme.bodyMedium?.color?.withValues(alpha:0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}