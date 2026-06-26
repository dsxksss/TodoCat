import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/controllers/unified/datetime_picker_controller.dart';
import 'package:todo_cat/core/utils/responsive.dart';
import 'package:todo_cat/widgets/date_panel.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/widgets/time_panel.dart';

import 'package:todo_cat/core/utils/l10n.dart';

class DatePickerPanel extends ConsumerStatefulWidget {
  const DatePickerPanel({
    super.key,
    required this.dialogTag,
    required this.onDateSelected,
    this.initialSelectedDate, // 新增初始选中日期参数
  });

  final String dialogTag;
  final Function(DateTime?) onDateSelected;
  final DateTime? initialSelectedDate; // 新增属性

  @override
  ConsumerState<DatePickerPanel> createState() => _DatePickerPanelState();
}

class _DatePickerPanelState extends ConsumerState<DatePickerPanel> {
  final GlobalKey<TimePanelState> _timeKey = GlobalKey<TimePanelState>();

  @override
  void initState() {
    super.initState();
    // 在initState中设置初始日期，避免构建阶段状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSelectedDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final initialDate = widget.initialSelectedDate!;
        final initialDateOnly =
            DateTime(initialDate.year, initialDate.month, initialDate.day);

        final controller = ref.read(dateTimePickerControllerProvider.notifier);
        // 如果初始日期是过去的，则使用今天
        if (initialDateOnly.isBefore(today)) {
          controller.setDateTime(now);
        } else {
          controller.setDateTime(widget.initialSelectedDate);
        }
      }
    });
  }

  /// 当前选中时间（由 selectedDateTime 推导，等价于原 DatePickerController.currentTime）。
  TimeOfDay? _currentTimeOf(DateTime? selectedDateTime) =>
      selectedDateTime != null
          ? TimeOfDay(
              hour: selectedDateTime.hour, minute: selectedDateTime.minute)
          : null;

  Widget _buildQuickDateButton(String label, int days) {
    return LabelBtn(
      ghostStyle: true,
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      onPressed: () {
        final now = DateTime.now();
        final targetDate = days == 0
            ? DateTime(now.year, now.month, now.day, now.hour, now.minute)
            : DateTime(now.year, now.month, now.day + days, 23, 59);
        ref
            .read(dateTimePickerControllerProvider.notifier)
            .setDateTime(targetDate);
        if (_timeKey.currentState != null) {
          _timeKey.currentState!.updateToTime(
            TimeOfDay(hour: targetDate.hour, minute: targetDate.minute),
          );
        }
        // 不再立即调用 onDateSelected，等待确认按钮
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDate =
        ref.watch(dateTimePickerControllerProvider).selectedDateTime;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                // 左侧：显示日期
                Text(
                  currentDate != null
                      ? currentDate.toString().split(".")[0]
                      : l10n.unknownDate,
                ),
                // 右上角：取消和确定按钮
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
                      onPressed: () {
                        // 取消按钮关闭对话框
                        SmartDialog.dismiss(tag: widget.dialogTag);
                      },
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
                        final selected = ref
                            .read(dateTimePickerControllerProvider)
                            .selectedDateTime;
                        if (selected != null) {
                          widget.onDateSelected(selected);
                        }
                        // 确认按钮关闭对话框
                        SmartDialog.dismiss(tag: widget.dialogTag);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 快捷日期按钮区域
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quickSelect,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft, // start对齐
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start, // 确保Wrap内部也start对齐
                    children: [
                      // "现在"按钮放在最左边
                      LabelBtn(
                        ghostStyle: true,
                        label: Text(
                          l10n.now,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        onPressed: () {
                          final now = DateTime.now();
                          if (_timeKey.currentState != null) {
                            _timeKey.currentState!.updateToTime(
                              TimeOfDay(hour: now.hour, minute: now.minute),
                            );
                          }
                          ref
                              .read(dateTimePickerControllerProvider.notifier)
                              .setDateTime(now);
                          // 不再立即调用 onDateSelected，等待确认按钮
                        },
                      ),
                      _buildQuickDateButton(l10n.today, 0),
                      _buildQuickDateButton(l10n.tomorrow, 1),
                      _buildQuickDateButton(l10n.threeDays, 3),
                      _buildQuickDateButton(l10n.oneWeek, 7),
                      _buildQuickDateButton(l10n.oneMonth, 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DatePanel(
            selectedDate: currentDate,
            onDateSelected: (date) {
              final currentTime = _currentTimeOf(currentDate);
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final selectedDay = DateTime(date.year, date.month, date.day);

              DateTime newDate;
              if (currentTime != null) {
                newDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  currentTime.hour,
                  currentTime.minute,
                );
              } else {
                newDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  now.hour,
                  now.minute,
                );
              }

              // 如果选择的是今天，但时间比当前时间要早，则设置为当前时间
              if (selectedDay.isAtSameMomentAs(today) && newDate.isBefore(now)) {
                newDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  now.hour,
                  now.minute,
                );
                // 同时更新TimePanel的显示
                if (_timeKey.currentState != null) {
                  _timeKey.currentState!.updateToTime(
                    TimeOfDay(hour: now.hour, minute: now.minute),
                  );
                }
              }

              ref
                  .read(dateTimePickerControllerProvider.notifier)
                  .setDateTime(newDate);
              // 不再立即调用 onDateSelected，等待确认按钮
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: TimePanel(
              key: _timeKey,
              initialTime: _currentTimeOf(currentDate),
              onTimeSelected: (time) {
                final notifier =
                    ref.read(dateTimePickerControllerProvider.notifier);
                notifier.setTime(time);
                // 确保日期不为null
                final base = ref
                        .read(dateTimePickerControllerProvider)
                        .selectedDateTime ??
                    DateTime.now();
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final selectedDay =
                    DateTime(base.year, base.month, base.day);

                DateTime newDateTime = DateTime(
                  base.year,
                  base.month,
                  base.day,
                  time.hour,
                  time.minute,
                );

                // 如果选择的是今天，但时间比当前时间要早，则设置为当前时间
                if (selectedDay.isAtSameMomentAs(today) &&
                    newDateTime.isBefore(now)) {
                  newDateTime = DateTime(
                    base.year,
                    base.month,
                    base.day,
                    now.hour,
                    now.minute,
                  );
                  // 同时更新TimePanel的显示
                  if (_timeKey.currentState != null) {
                    _timeKey.currentState!.updateToTime(
                      TimeOfDay(hour: now.hour, minute: now.minute),
                    );
                  }
                }

                notifier.setDateTime(newDateTime);
                // 不再立即调用 onDateSelected，等待确认按钮
              },
            ),
          ),
        ],
      ),
    );
  }
}
