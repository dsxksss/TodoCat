import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:TodoCat/widgets/label_btn.dart';
import 'package:TodoCat/services/dialog_service.dart';
import 'package:TodoCat/keys/dialog_keys.dart';
import 'package:TodoCat/controllers/workspace_ctr.dart';

/// 选择工作空间对话框
class SelectWorkspaceDialog extends StatelessWidget {
  final String currentWorkspaceId;
  final Function(String workspaceId) onWorkspaceSelected;

  const SelectWorkspaceDialog({
    super.key,
    required this.currentWorkspaceId,
    required this.onWorkspaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WorkspaceController>()) {
      return const SizedBox.shrink();
    }

    final workspaceCtrl = Get.find<WorkspaceController>();

    return Obx(() {
      final workspaces = workspaceCtrl.workspaces;
      
      if (workspaces.isEmpty) {
        return Container(
          width: context.isPhone ? 1.sw : 430,
          height: context.isPhone ? 0.4.sh : 200,
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
          child: Center(
            child: Text(
              'noWorkspaces'.tr,
              style: TextStyle(
                fontSize: 16,
                color: context.theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        );
      }

      return Container(
        width: context.isPhone ? 1.sw : 430,
        height: context.isPhone ? 0.6.sh : 400,
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
                    'selectTargetWorkspace'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  LabelBtn(
                    label: const Icon(Icons.close, size: 20),
                    onPressed: () => SmartDialog.dismiss(tag: selectWorkspaceDialogTag),
                    padding: EdgeInsets.zero,
                    ghostStyle: true,
                  ),
                ],
              ),
            ),
            // 工作空间列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: workspaces.length,
                itemBuilder: (context, index) {
                  final workspace = workspaces[index];
                  final isCurrent = workspace.uuid == currentWorkspaceId;
                  
                  return ListTile(
                    enabled: !isCurrent, // 禁用当前工作空间
                    leading: Icon(
                      isCurrent ? Icons.check_circle : Icons.folder_outlined,
                      color: isCurrent 
                          ? Colors.green 
                          : context.theme.iconTheme.color,
                    ),
                    title: Text(
                      workspace.uuid == 'default' 
                          ? 'defaultWorkspace'.tr 
                          : workspace.name,
                      style: TextStyle(
                        color: isCurrent 
                            ? Colors.grey 
                            : context.theme.textTheme.bodyLarge?.color,
                        fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    subtitle: isCurrent 
                        ? Text(
                            'currentWorkspace'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          )
                        : null,
                    onTap: isCurrent 
                        ? null 
                        : () {
                            onWorkspaceSelected(workspace.uuid);
                            SmartDialog.dismiss(tag: selectWorkspaceDialogTag);
                          },
                    hoverColor: isCurrent 
                        ? Colors.transparent 
                        : context.theme.hoverColor,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 显示选择工作空间对话框
void showSelectWorkspaceDialog({
  required String currentWorkspaceId,
  required Function(String workspaceId) onWorkspaceSelected,
}) {
  DialogService.showFormDialog(
    tag: selectWorkspaceDialogTag,
    dialog: SelectWorkspaceDialog(
      currentWorkspaceId: currentWorkspaceId,
      onWorkspaceSelected: onWorkspaceSelected,
    ),
  );
}

