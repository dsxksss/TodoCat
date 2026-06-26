import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/core/utils/responsive.dart';

import 'package:todo_cat/core/utils/l10n.dart';
/// 创建工作空间对话框
class CreateWorkspaceDialog extends ConsumerStatefulWidget {
  const CreateWorkspaceDialog({super.key});

  @override
  ConsumerState<CreateWorkspaceDialog> createState() =>
      _CreateWorkspaceDialogState();
}

class _CreateWorkspaceDialogState extends ConsumerState<CreateWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createWorkspace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final workspaceCtrl = ref.read(workspaceControllerProvider.notifier);

      // 创建工作空间，但不自动切换（autoSwitch: false）
      final workspaceId = await workspaceCtrl.createWorkspace(
        _nameController.text.trim(),
        autoSwitch: false,
      );

      if (mounted) {
        if (workspaceId != null) {
          // 先关闭对话框，避免在切换工作空间时对话框还在显示
          SmartDialog.dismiss(tag: createWorkspaceDialogTag);
          // 关闭工作空间选择器的下拉菜单
          SmartDialog.dismiss(tag: 'workspace_selector');

          showSuccessNotification(l10n.workspaceCreated);
          // 对话框已关闭，现在切换工作空间
          await workspaceCtrl.switchWorkspace(workspaceId);
        } else {
          showErrorNotification(l10n.workspaceCreateFailed);
          setState(() {
            _isCreating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorNotification(l10n.workspaceCreateFailed);
        setState(() {
          _isCreating = false;
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
              title: l10n.createWorkspace,
              onCancel: () => SmartDialog.dismiss(tag: createWorkspaceDialogTag),
              onConfirm: _isCreating ? null : _createWorkspace,
              confirmText: _isCreating ? l10n.creating : l10n.create,
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
                      fieldTitle: l10n.workspaceName,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.workspaceNameRequired;
                        }
                        return null;
                      },
                      editingController: _nameController,
                      onFieldSubmitted: (_) {
                        if (!_isCreating) {
                          _createWorkspace();
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

/// 显示创建工作空间对话框
void showCreateWorkspaceDialog() {
  DialogService.showFormDialog(
    tag: createWorkspaceDialogTag,
    dialog: const CreateWorkspaceDialog(),
  );
}

