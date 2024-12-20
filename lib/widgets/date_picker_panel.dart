import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/widgets/date_panel.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/widgets/time_panel.dart';

class DatePickerPanel extends StatelessWidget {
  DatePickerPanel({
    super.key,
    required String dialogTag,
    required Function(DateTime?) onDateSelected,
  }) : _onDateSelected = onDateSelected {
    _datePickerController = Get.find<DatePickerController>();
  }

  final Function(DateTime?) _onDateSelected;
  late final DatePickerController _datePickerController;
  final GlobalKey<TimePanelState> _timeKey = GlobalKey<TimePanelState>();

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
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
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
                          _onDateSelected(now);
                        },
                      ),
                      8.horizontalSpace,
                      LabelBtn(
                        label: Text(
                          'noDateTime'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onPressed: () {
                          _datePickerController.reset();
                          if (_timeKey.currentState != null) {
                            _timeKey.currentState!.resetTime();
                          }
                          _onDateSelected(null);
                        },
                      ),
                    ],
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
                  _onDateSelected(newDate);
                } else {
                  final newDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    0,
                    0,
                  );
                  _datePickerController.setCurrentDate(newDate);
                  _onDateSelected(newDate);
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
                  _onDateSelected(_datePickerController.currentDate.value);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
