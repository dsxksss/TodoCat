import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/widgets/date_panel.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/widgets/time_panel.dart';

class DatePickerPanel extends StatefulWidget {
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
  State<DatePickerPanel> createState() => _DatePickerPanelState();
}

class _DatePickerPanelState extends State<DatePickerPanel> {
  late DatePickerController _datePickerController;
  final GlobalKey<TimePanelState> _timeKey = GlobalKey<TimePanelState>();

  @override
  void initState() {
    super.initState();
    _datePickerController = Get.find<DatePickerController>();
    // 在initState中设置初始日期，避免构建阶段状态更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSelectedDate != null) {
        _datePickerController.setCurrentDate(widget.initialSelectedDate);
      }
    });
  }



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
        _datePickerController.setCurrentDate(targetDate);
        if (_timeKey.currentState != null) {
          _timeKey.currentState!.updateToTime(
            TimeOfDay(hour: targetDate.hour, minute: targetDate.minute),
          );
        }
        widget.onDateSelected(targetDate);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentDate = _datePickerController.currentDate.value;

      return Container(
        width: 340,
        decoration: BoxDecoration(
          color: context.theme.dialogBackgroundColor,
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
                  Text(
                    currentDate != null
                        ? currentDate.toString().split(".")[0]
                        : "unknownDate".tr,
                  ),
                  Row(
                    children: [
                      LabelBtn(
                        ghostStyle: true,
                        label: Text(
                          'now'.tr,
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
                          _datePickerController.setCurrentDate(now);
                          widget.onDateSelected(now);
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
                    "quickSelect".tr,
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
                        _buildQuickDateButton("today".tr, 0),
                        _buildQuickDateButton("tomorrow".tr, 1),
                        _buildQuickDateButton("threeDays".tr, 3),
                        _buildQuickDateButton("oneWeek".tr, 7),
                        _buildQuickDateButton("oneMonth".tr, 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DatePanel(
              selectedDate: currentDate,
              onDateSelected: (date) {
                final currentTime = _datePickerController.currentTime.value;
                if (currentTime != null) {
                  final newDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    currentTime.hour,
                    currentTime.minute,
                  );
                  _datePickerController.setCurrentDate(newDate);
                  widget.onDateSelected(newDate);
                } else {
                  final newDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    0,
                    0,
                  );
                  _datePickerController.setCurrentDate(newDate);
                  widget.onDateSelected(newDate);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: TimePanel(
                key: _timeKey,
                initialTime: _datePickerController.currentTime.value,
                onTimeSelected: (time) {
                  _datePickerController.setCurrentTime(time);
                  // 确保日期不为null
                  final currentDate = _datePickerController.currentDate.value ?? DateTime.now();
                  final newDateTime = DateTime(
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                    time.hour,
                    time.minute,
                  );
                  _datePickerController.setCurrentDate(newDateTime);
                  widget.onDateSelected(newDateTime);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
