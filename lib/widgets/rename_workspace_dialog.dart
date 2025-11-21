import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/data/schemas/workspace.dart';

/// 重命名工作空间对话框
class RenameWorkspaceDialog extends StatefulWidget {
  final Workspace workspace;

  const RenameWorkspaceDialog({
    super.key,
    required this.workspace,
  });

  @override
  State<RenameWorkspaceDialog> createState() => _RenameWorkspaceDialogState();
}

class _RenameWorkspaceDialogState extends State<RenameWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isRenaming = false;

  @override
  void initState() {
    super.initState();
    // 初始化时填入当前工作空间名称
    _nameController = TextEditingController(text: widget.workspace.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _renameWorkspace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newName = _nameController.text.trim();
    // 如果名称没有变化，直接关闭对话框
    if (newName == widget.workspace.name) {
      SmartDialog.dismiss(tag: renameWorkspaceDialogTag);
      return;
    }

    setState(() {
      _isRenaming = true;
    });

    try {
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        final success = await workspaceCtrl.updateWorkspace(
          widget.workspace.uuid,
          newName,
        );
        
        if (mounted) {
          if (success) {
            showSuccessNotification('workspaceRenamed'.tr);
            SmartDialog.dismiss(tag: renameWorkspaceDialogTag);
            // 关闭工作空间选择器的下拉菜单
            SmartDialog.dismiss(tag: 'workspace_selector');
          } else {
            showErrorNotification('workspaceRenameFailed'.tr);
            setState(() {
              _isRenaming = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorNotification('workspaceRenameFailed'.tr);
        setState(() {
          _isRenaming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 430,
      height: context.isPhone ? 0.6.sh : 300,
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 标题栏
            DialogHeader(
              title: 'renameWorkspace'.tr,
              onCancel: () => SmartDialog.dismiss(tag: renameWorkspaceDialogTag),
              onConfirm: _isRenaming ? null : _renameWorkspace,
              confirmText: _isRenaming ? 'renaming'.tr : 'rename'.tr,
            ),
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 工作空间名称
                    TextFormFieldItem(
                      textInputAction: TextInputAction.done,
                      maxLength: 50,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: 'workspaceName'.tr,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'workspaceNameRequired'.tr;
                        }
                        return null;
                      },
                      editingController: _nameController,
                      onFieldSubmitted: (_) {
                        if (!_isRenaming) {
                          _renameWorkspace();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示重命名工作空间对话框
void showRenameWorkspaceDialog(Workspace workspace) {
  DialogService.showFormDialog(
    tag: renameWorkspaceDialogTag,
    dialog: RenameWorkspaceDialog(workspace: workspace),
  );
}

