import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StatusPickerPanel extends StatelessWidget {
  const StatusPickerPanel({
    super.key,
    required this.initialStatus,
    required this.onStatusSelected,
  });

  final TodoStatus initialStatus;
  final Function(TodoStatus) onStatusSelected;

  IconData _getStatusIcon(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return FontAwesomeIcons.hourglassStart;
      case TodoStatus.inProgress:
        return FontAwesomeIcons.hourglassEnd;
      case TodoStatus.done:
        return FontAwesomeIcons.checkDouble;
    }
  }

  Color _getStatusColor(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Colors.grey[600]!;
      case TodoStatus.inProgress:
        return Colors.orange;
      case TodoStatus.done:
        return Colors.green;
    }
  }

  String _getStatusLabel(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return "statusTodo".tr;
      case TodoStatus.inProgress:
        return "statusInProgress".tr;
      case TodoStatus.done:
        return "statusDone".tr;
    }
  }

  Widget _buildStatusOption(TodoStatus status, bool isSelected) {
    final color = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: LabelBtn(
        ghostStyle: !isSelected,
        bgColor: isSelected ? color : null,
        decoration: !isSelected ? BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            width: 1,
            color: color,
          ),
        ) : null,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusLabel(status),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: () {
          onStatusSelected(status);
          SmartDialog.dismiss();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.dividerColor,
          width: 0.3,
        ),
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
                  width: 0.3,
                  color: context.theme.dividerColor,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "selectStatus".tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                LabelBtn(
                  label: Icon(
                    Icons.close,
                    size: 20,
                    color: context.theme.textTheme.bodyMedium?.color,
                  ),
                  onPressed: () => SmartDialog.dismiss(),
                  padding: EdgeInsets.zero,
                  ghostStyle: true,
                ),
              ],
            ),
          ),
          // 状态选项列表
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: TodoStatus.values
                  .map((status) => _buildStatusOption(
                        status,
                        status == initialStatus,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}