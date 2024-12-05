import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/core/utils/date_time.dart';
import 'package:logger/logger.dart';

class DatePickerController extends GetxController {
  static final _logger = Logger();
  final currentDate = DateTime.now().obs;
  final defaultDate = DateTime.now().obs;
  final monthDays = <int>[].obs;
  final selectedDay = 0.obs;
  final firstDayOfWeek = 0.obs;
  final daysInMonth = 0.obs;
  final startPadding = 0.obs;
  final totalDays = 0.obs;

  final TextEditingController hEditingController = TextEditingController();
  final TextEditingController mEditingController = TextEditingController();

  // 计算属性
  bool get isCurrentMonth =>
      currentDate.value.year == DateTime.now().year &&
      currentDate.value.month == DateTime.now().month;

  bool get isSelectedDayValid =>
      selectedDay.value > 0 && selectedDay.value <= daysInMonth.value;

  @override
  void onInit() async {
    super.onInit();
    _logger.i('Initializing DatePickerController');
    _initializeDateData();
    await _initializeTimeData();

    // 监听选中日期变化
    ever(selectedDay, (_) {
      _logger.d('Selected day changed to: $selectedDay');
      if (isSelectedDayValid) {
        changeDate(day: selectedDay.value);
      }
    });

    // 监听当前日期变化
    ever(currentDate, (_) {
      _logger.d('Current date changed to: ${currentDate.value}');
      selectedDay.value = currentDate.value.day;
      _updateMonthData();
    });
  }

  void _initializeDateData() {
    _logger.d('Initializing date data');
    _updateMonthData();
    selectedDay.value = defaultDate.value.day;
  }

  void _updateMonthData() {
    monthDays.value = getMonthDays(
      currentDate.value.year,
      currentDate.value.month,
    );
    firstDayOfWeek.value = firstDayWeek(currentDate.value);
    daysInMonth.value = monthDays.length;
    startPadding.value = (firstDayOfWeek.value - 1) % 7;
    totalDays.value = daysInMonth.value + startPadding.value;
  }

  Future<void> _initializeTimeData() async {
    _logger.d('Initializing time data');
    await 2.delay(() {
      _updateTimeInputs(
        defaultDate.value.hour,
        defaultDate.value.minute,
      );
    });
  }

  void _updateTimeInputs(int hours, int minutes) {
    hEditingController.text = hours.toString();
    mEditingController.text = minutes.toString();
  }

  void resetDate() {
    _logger.d('Resetting date to default');
    changeDate(
      year: defaultDate.value.year,
      month: defaultDate.value.month,
      day: defaultDate.value.day,
      hour: 0,
      minute: 0,
    );
    _updateTimeInputs(0, 0);
  }

  void changeDate({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
  }) {
    _logger.d(
        'Changing date with parameters: year=$year, month=$month, day=$day, hour=$hour, minute=$minute');
    try {
      final newDate = DateTime(
        year ?? currentDate.value.year,
        month ?? currentDate.value.month,
        day ?? currentDate.value.day,
        hour ?? currentDate.value.hour,
        minute ?? currentDate.value.minute,
      );
      currentDate.value = newDate;
    } catch (e) {
      _logger.e('Error changing date: $e');
    }
  }

  @override
  void onClose() {
    _logger.d('Cleaning up DatePickerController resources');
    hEditingController.dispose();
    mEditingController.dispose();
    super.onClose();
  }
}
