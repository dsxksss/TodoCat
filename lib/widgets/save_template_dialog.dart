import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/custom_template.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/services/repositorys/custom_template.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/home/components/text_form_field_item.dart';

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
                    'saveAsTemplate'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  LabelBtn(
                    label: const Icon(Icons.close, size: 20),
                    onPressed: () => SmartDialog.dismiss(tag: saveTemplateDialogTag),
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
                    // 模板名称
                    TextFormFieldItem(
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: 'enterTemplateName'.tr,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'templateNameRequired'.tr;
                        }
                        return null;
                      },
                      editingController: _nameController,
                      onFieldSubmitted: (_) {},
                    ),
                    const SizedBox(height: 20),
                    // 模板描述（可选）
                    TextFormFieldItem(
                      textInputAction: TextInputAction.done,
                      maxLength: 200,
                      maxLines: 3,
                      minLines: 3,
                      radius: 6,
                      fieldTitle: 'description'.tr,
                      validator: (_) => null,
                      editingController: _descriptionController,
                      onFieldSubmitted: (_) {},
                    ),
                    const SizedBox(height: 20),
                    // 任务列表预览
                    Text(
                      '${"tasks".tr}: ${widget.tasks.length}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.theme.textTheme.bodyMedium?.color?.withValues(alpha:0.7),
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

