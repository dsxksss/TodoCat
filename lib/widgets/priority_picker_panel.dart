import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/core/utils/responsive.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:todo_cat/core/utils/l10n.dart';

class PriorityPickerPanel extends ConsumerStatefulWidget {
  const PriorityPickerPanel({
    super.key,
    required this.onPrioritySelected,
    this.initialPriority = TodoPriority.lowLevel,
  });

  final Function(TodoPriority) onPrioritySelected;
  final TodoPriority initialPriority;

  @override
  ConsumerState<PriorityPickerPanel> createState() =>
      _PriorityPickerPanelState();
}

class _PriorityPickerPanelState extends ConsumerState<PriorityPickerPanel> {
  late TodoPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialPriority;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
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
                  l10n.priority,
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
                        l10n.cancel,
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
                        l10n.confirm,
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
                        widget.onPrioritySelected(_selectedPriority);
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
                  l10n.lowPriority,
                  Colors.green,
                  Icons.flag_outlined,
                ),
                const SizedBox(height: 10),
                _buildPriorityOption(
                  context,
                  TodoPriority.mediumLevel,
                  l10n.mediumPriority,
                  Colors.orange,
                  Icons.flag_outlined,
                ),
                const SizedBox(height: 10),
                _buildPriorityOption(
                  context,
                  TodoPriority.highLevel,
                  l10n.highPriority,
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
    final isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : context.theme.dividerColor,
            width: isSelected ? 1.5 : 0.5,
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? color
                    : context.theme.textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
