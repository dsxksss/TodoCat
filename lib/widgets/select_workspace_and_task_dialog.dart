import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/services/dialog_service.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'package:todo_cat/data/schemas/task.dart';

/// 选择工作空间和任务对话框
class SelectWorkspaceAndTaskDialog extends StatefulWidget {
  final String currentTaskId;
  final String currentWorkspaceId;
  final Function(String workspaceId, String taskId) onSelected;

  const SelectWorkspaceAndTaskDialog({
    super.key,
    required this.currentTaskId,
    required this.currentWorkspaceId,
    required this.onSelected,
  });

  @override
  State<SelectWorkspaceAndTaskDialog> createState() => _SelectWorkspaceAndTaskDialogState();
}

class _SelectWorkspaceAndTaskDialogState extends State<SelectWorkspaceAndTaskDialog> {
  String? _selectedWorkspaceId;
  String? _selectedTaskId;
  List<Task> _tasks = [];
  bool _loadingTasks = false;

  @override
  void initState() {
    super.initState();
    _selectedWorkspaceId = widget.currentWorkspaceId;
    _loadTasksForWorkspace(widget.currentWorkspaceId);
  }

  Future<void> _loadTasksForWorkspace(String workspaceId) async {
    setState(() {
      _loadingTasks = true;
      _selectedTaskId = null;
    });

    try {
      final repository = await TaskRepository.getInstance();
      final tasks = await repository.readAll(workspaceId: workspaceId);
      
      setState(() {
        _tasks = tasks;
        _loadingTasks = false;
      });
    } catch (e) {
      setState(() {
        _tasks = [];
        _loadingTasks = false;
      });
    }
  }

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
          width: context.isPhone ? 1.sw : 500,
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
        width: context.isPhone ? 1.sw : 500,
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
                    'selectTargetTask'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  LabelBtn(
                    label: const Icon(Icons.close, size: 20),
                    onPressed: () => SmartDialog.dismiss(tag: selectWorkspaceAndTaskDialogTag),
                    padding: EdgeInsets.zero,
                    ghostStyle: true,
                  ),
                ],
              ),
            ),
            // 内容区域
            Expanded(
              child: Row(
                children: [
                  // 左侧：工作空间列表
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: context.theme.dividerColor,
                          width: 0.3,
                        ),
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: workspaces.length,
                      itemBuilder: (context, index) {
                        final workspace = workspaces[index];
                        final isSelected = workspace.uuid == _selectedWorkspaceId;
                        final isCurrent = workspace.uuid == widget.currentWorkspaceId;
                        
                        return ListTile(
                          selected: isSelected,
                          leading: Icon(
                            isSelected ? Icons.folder : Icons.folder_outlined,
                            color: isSelected 
                                ? Colors.blue 
                                : context.theme.iconTheme.color,
                          ),
                          title: Text(
                            workspace.uuid == 'default' 
                                ? 'defaultWorkspace'.tr 
                                : workspace.name,
                            style: TextStyle(
                              color: isSelected 
                                  ? Colors.blue 
                                  : context.theme.textTheme.bodyLarge?.color,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                          onTap: () {
                            setState(() {
                              _selectedWorkspaceId = workspace.uuid;
                            });
                            _loadTasksForWorkspace(workspace.uuid);
                          },
                          selectedTileColor: context.theme.hoverColor,
                        );
                      },
                    ),
                  ),
                  // 右侧：任务列表
                  Expanded(
                    child: _loadingTasks
                        ? Center(
                            child: CircularProgressIndicator(
                              color: context.theme.primaryColor,
                            ),
                          )
                        : _tasks.isEmpty
                            ? Center(
                                child: Text(
                                  'noTasksInWorkspace'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: context.theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _tasks.length,
                                itemBuilder: (context, index) {
                                  final task = _tasks[index];
                                  final isSelected = task.uuid == _selectedTaskId;
                                  final isCurrent = task.uuid == widget.currentTaskId;
                                  
                                  return ListTile(
                                    selected: isSelected,
                                    leading: Icon(
                                      isSelected ? Icons.check_circle : Icons.task_outlined,
                                      color: isSelected 
                                          ? Colors.green 
                                          : context.theme.iconTheme.color,
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        color: isSelected 
                                            ? Colors.green 
                                            : (isCurrent 
                                                ? Colors.grey 
                                                : context.theme.textTheme.bodyLarge?.color),
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: isCurrent 
                                        ? Text(
                                            'currentTask'.tr,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          )
                                        : null,
                                    enabled: !isCurrent, // 禁用当前任务
                                    onTap: isCurrent 
                                        ? null 
                                        : () {
                                            setState(() {
                                              _selectedTaskId = task.uuid;
                                            });
                                          },
                                    selectedTileColor: context.theme.hoverColor,
                                  );
                                },
                              ),
                  ),
                ],
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
                    onPressed: () => SmartDialog.dismiss(tag: selectWorkspaceAndTaskDialogTag),
                  ),
                  const SizedBox(width: 8),
                  LabelBtn(
                    label: Text(
                      'confirm'.tr,
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
                    disable: _selectedWorkspaceId == null || 
                             _selectedTaskId == null ||
                             _selectedTaskId == widget.currentTaskId,
                    onPressed: () {
                      if (_selectedWorkspaceId != null && 
                          _selectedTaskId != null &&
                          _selectedTaskId != widget.currentTaskId) {
                        widget.onSelected(_selectedWorkspaceId!, _selectedTaskId!);
                        SmartDialog.dismiss(tag: selectWorkspaceAndTaskDialogTag);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 显示选择工作空间和任务对话框
void showSelectWorkspaceAndTaskDialog({
  required String currentTaskId,
  required String currentWorkspaceId,
  required Function(String workspaceId, String taskId) onSelected,
}) {
  DialogService.showFormDialog(
    tag: selectWorkspaceAndTaskDialogTag,
    dialog: SelectWorkspaceAndTaskDialog(
      currentTaskId: currentTaskId,
      currentWorkspaceId: currentWorkspaceId,
      onSelected: onSelected,
    ),
  );
}

