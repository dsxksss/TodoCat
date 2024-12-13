import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimePickerController extends GetxController {
  final isAM = true.obs;
  final selectedHour = 11.obs;
  final selectedMinute = 0.obs;
  final isInitialized = false.obs;

  final amPmController = FixedExtentScrollController(initialItem: 0);
  final hourController = FixedExtentScrollController(initialItem: 11);
  final minuteController = FixedExtentScrollController(initialItem: 0);

  @override
  void onClose() {
    amPmController.dispose();
    hourController.dispose();
    minuteController.dispose();
    super.onClose();
  }

  void updateToTime(TimeOfDay time) {
    final hour = time.hour;
    isAM.value = hour < 12;
    if (isAM.value) {
      selectedHour.value = hour == 0 ? 11 : hour - 1;
    } else {
      selectedHour.value = hour == 12 ? 11 : hour - 13;
    }
    selectedMinute.value = time.minute;
    _updateControllers();
  }

  void _updateControllers() {
    amPmController.jumpToItem(isAM.value ? 0 : 1);
    hourController.jumpToItem(selectedHour.value);
    minuteController.jumpToItem(selectedMinute.value);
  }

  void resetTime() {
    isAM.value = true;
    selectedHour.value = 11;
    selectedMinute.value = 0;
    _updateControllers();
  }

  TimeOfDay getCurrentTime() {
    final hour = isAM.value
        ? (selectedHour.value == 11 ? 0 : selectedHour.value + 1)
        : (selectedHour.value == 11 ? 12 : selectedHour.value + 13);
    return TimeOfDay(hour: hour, minute: selectedMinute.value);
  }
}
