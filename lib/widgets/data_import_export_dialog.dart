import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/data_export_import_ctr.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/label_btn.dart';

/// 数据导入导出选择对话框
class DataImportExportDialog extends StatelessWidget {
  const DataImportExportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<DataExportImportController>();

    return Container(
      width: context.isPhone ? 0.9.sw : 400,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.import_export,
                      size: 20,
                      color: context.theme.iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'dataManagement'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                LabelBtn(
                  label: Icon(
                    Icons.close,
                    size: 20,
                    color: context.theme.iconTheme.color,
                  ),
                  onPressed: () =>
                      SmartDialog.dismiss(tag: 'data_import_export_dialog'),
                  padding: EdgeInsets.zero,
                  ghostStyle: true,
                ),
              ],
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 导出数据选项
                _buildOption(
                  context: context,
                  icon: Icons.download_rounded,
                  title: 'exportData'.tr,
                  description: 'exportDataDescription'.tr,
                  onTap: () async {
                    SmartDialog.dismiss(tag: 'data_import_export_dialog');
                    if (!dataController.isExporting.value) {
                      await dataController.exportData();
                    }
                  },
                  isLoading: dataController.isExporting.value,
                ),
                const SizedBox(height: 16),
                // 导入数据选项
                _buildOption(
                  context: context,
                  icon: Icons.upload_rounded,
                  title: 'importData'.tr,
                  description: 'importDataDescription'.tr,
                  onTap: () async {
                    SmartDialog.dismiss(tag: 'data_import_export_dialog');
                    if (!dataController.isImporting.value) {
                      await dataController.importData();
                    }
                  },
                  isLoading: dataController.isImporting.value,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
            Icon(
              icon,
              size: 24,
              color: isLoading
                  ? Colors.grey
                  : context.theme.iconTheme.color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLoading
                          ? Colors.grey
                          : context.theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLoading
                          ? Colors.grey
                          : context.theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.chevron_right,
                color: context.theme.iconTheme.color,
              ),
          ],
        ),
      ),
    );
  }
}

