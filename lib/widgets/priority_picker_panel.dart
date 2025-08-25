import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class PriorityPickerPanel extends StatelessWidget {
  PriorityPickerPanel({
    super.key,
    required this.onPrioritySelected,
    this.initialPriority = TodoPriority.lowLevel,
  });

  final Function(TodoPriority) onPrioritySelected;
  final TodoPriority initialPriority;
  final selectedPriority = TodoPriority.lowLevel.obs;

  @override
  Widget build(BuildContext context) {
    selectedPriority.value = initialPriority;
    
    return Container(
      width: 280,
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
                  "priority".tr,
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
                        onPrioritySelected(selectedPriority.value);
                        SmartDialog.dismiss();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _buildPriorityOption(
                  context,
                  TodoPriority.lowLevel,
                  "lowPriority".tr,
                  Colors.green,
                  Icons.flag_outlined,
                ),
                const SizedBox(height: 10),
                _buildPriorityOption(
                  context,
                  TodoPriority.mediumLevel,
                  "mediumPriority".tr,
                  Colors.orange,
                  Icons.flag_outlined,
                ),
                const SizedBox(height: 10),
                _buildPriorityOption(
                  context,
                  TodoPriority.highLevel,
                  "highPriority".tr,
                  Colors.red,
                  Icons.flag,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(
    BuildContext context,
    TodoPriority priority,
    String label,
    Color color,
    IconData icon,
  ) {
    return Obx(() => GestureDetector(
          onTap: () => selectedPriority.value = priority,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selectedPriority.value == priority
                  ? color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedPriority.value == priority
                    ? color
                    : context.theme.dividerColor,
                width: selectedPriority.value == priority ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selectedPriority.value == priority
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selectedPriority.value == priority
                        ? color
                        : context.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                if (selectedPriority.value == priority)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 18,
                  ),
              ],
            ),
          ),
        ));
  }
}