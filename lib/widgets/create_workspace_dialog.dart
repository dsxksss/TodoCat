import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';

/// 创建工作空间对话框
class CreateWorkspaceDialog extends StatefulWidget {
  const CreateWorkspaceDialog({super.key});

  @override
  State<CreateWorkspaceDialog> createState() => _CreateWorkspaceDialogState();
}

class _CreateWorkspaceDialogState extends State<CreateWorkspaceDialog> {
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
      if (Get.isRegistered<WorkspaceController>()) {
        final workspaceCtrl = Get.find<WorkspaceController>();
        final workspaceId = await workspaceCtrl.createWorkspace(_nameController.text.trim());
        
        if (mounted) {
          if (workspaceId != null) {
            showSuccessNotification('workspaceCreated'.tr);
            SmartDialog.dismiss(tag: createWorkspaceDialogTag);
            // 关闭工作空间选择器的下拉菜单
            SmartDialog.dismiss(tag: 'workspace_selector');
          } else {
            showErrorNotification('workspaceCreateFailed'.tr);
            setState(() {
              _isCreating = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorNotification('workspaceCreateFailed'.tr);
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
                    'createWorkspace'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  LabelBtn(
                    label: const Icon(Icons.close, size: 20),
                    onPressed: () => SmartDialog.dismiss(tag: createWorkspaceDialogTag),
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
                        if (!_isCreating) {
                          _createWorkspace();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // 底部按钮
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: context.theme.dividerColor,
                    width: 0.3,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LabelBtn(
                    ghostStyle: true,
                    label: Text(
                      'cancel'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    disable: _isCreating,
                    onPressed: () => SmartDialog.dismiss(tag: createWorkspaceDialogTag),
                  ),
                  const SizedBox(width: 8),
                  LabelBtn(
                    label: Text(
                      _isCreating ? 'creating'.tr : 'create'.tr,
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
                    disable: _isCreating,
                    onPressed: () => _createWorkspace(),
                  ),
                ],
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

