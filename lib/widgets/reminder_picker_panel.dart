import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ReminderPickerPanel extends StatelessWidget {
  ReminderPickerPanel({
    super.key,
    required this.onReminderSelected,
    this.initialReminder = 0,
  });

  final Function(int) onReminderSelected;
  final int initialReminder;
  final selectedReminder = 0.obs;

  final List<Map<String, dynamic>> reminderOptions = [
    {"value": 0, "label": "noReminder", "description": "不设置提醒"},
    {"value": 5, "label": "5minutes", "description": "提前5分钟"},
    {"value": 15, "label": "15minutes", "description": "提前15分钟"},
    {"value": 30, "label": "30minutes", "description": "提前30分钟"},
    {"value": 60, "label": "1hour", "description": "提前1小时"},
    {"value": 120, "label": "2hours", "description": "提前2小时"},
    {"value": 1440, "label": "1day", "description": "提前1天"},
  ];

  @override
  Widget build(BuildContext context) {
    selectedReminder.value = initialReminder;
    
    return Container(
      width: 300,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: context.theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                  "reminderTime".tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    LabelBtn(
                      ghostStyle: true,
                      label: Text(
                        "cancel".tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      onPressed: () => SmartDialog.dismiss(),
                    ),
                    const SizedBox(width: 8),
                    LabelBtn(
                      label: Text(
                        "confirm".tr,
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
                      onPressed: () {
                        onReminderSelected(selectedReminder.value);
                        SmartDialog.dismiss();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  ...reminderOptions.map((option) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildReminderOption(
                          context,
                          option["value"] as int,
                          option["label"] as String,
                          option["description"] as String,
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderOption(
    BuildContext context,
    int value,
    String label,
    String description,
  ) {
    return Obx(() => GestureDetector(
          onTap: () => selectedReminder.value = value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selectedReminder.value == value
                  ? const Color(0xFF3B82F6).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedReminder.value == value
                    ? const Color(0xFF3B82F6)
                    : context.theme.dividerColor,
                width: selectedReminder.value == value ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  value == 0 ? Icons.notifications_off : Icons.notifications_active,
                  color: selectedReminder.value == value
                      ? const Color(0xFF3B82F6)
                      : context.theme.iconTheme.color,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selectedReminder.value == value
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selectedReminder.value == value
                              ? const Color(0xFF3B82F6)
                              : context.theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                    ],
                  ),
                ),
                if (selectedReminder.value == value)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF3B82F6),
                    size: 18,
                  ),
              ],
            ),
          ),
        ));
  }
}