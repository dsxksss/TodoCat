import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:TodoCat/data/schemas/custom_template.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/services/repositorys/custom_template.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:TodoCat/widgets/label_btn.dart';
import 'package:TodoCat/services/dialog_service.dart';
import 'package:TodoCat/keys/dialog_keys.dart';

/// 保存为模板对话框
class SaveTemplateDialog extends StatefulWidget {
  final List<Task> tasks;
  
  const SaveTemplateDialog({
    super.key,
    required this.tasks,
  });

  @override
  State<SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState extends State<SaveTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = await CustomTemplateRepository.getInstance();
      
      // 检查名称是否已存在
      final exists = await repository.exists(_nameController.text.trim());
      if (exists) {
        if (mounted) {
          showErrorNotification('templateAlreadyExists'.tr);
          setState(() {
            _isSaving = false;
          });
        }
        return;
      }

      // 创建模板
      final template = CustomTemplate.fromTasks(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        tasks: widget.tasks,
        isSystem: false,
      );

      await repository.save(template);

      if (mounted) {
        showSuccessNotification('templateSaved'.tr);
        SmartDialog.dismiss(tag: saveTemplateDialogTag);
      }
    } catch (e) {
      if (mounted) {
        showErrorNotification('Error: $e');
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 1.sw : 430,
      height: context.isPhone ? 0.6.sh : 500,
      decoration: BoxDecoration(
        color: context.theme.dialogBackgroundColor,
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
                    'saveAsTemplate'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => SmartDialog.dismiss(tag: saveTemplateDialogTag),
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
                    // 模板名称
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'templateName'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'enterTemplateName'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'templateNameRequired'.tr;
                            }
                            return null;
                          },
                          enabled: !_isSaving,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 模板描述（可选）
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'description'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'optional'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          enabled: !_isSaving,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 任务列表预览
                    Text(
                      '${"tasks".tr}: ${widget.tasks.length}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
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
                    disable: _isSaving,
                    onPressed: () => SmartDialog.dismiss(tag: saveTemplateDialogTag),
                  ),
                  const SizedBox(width: 8),
                  LabelBtn(
                    label: Text(
                      _isSaving ? 'saving'.tr : 'save'.tr,
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
                    disable: _isSaving,
                    onPressed: () => _saveTemplate(),
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

/// 显示保存模板对话框
void showSaveTemplateDialog(List<Task> tasks) {
  DialogService.showFormDialog(
    tag: saveTemplateDialogTag,
    dialog: SaveTemplateDialog(tasks: tasks),
  );
}

