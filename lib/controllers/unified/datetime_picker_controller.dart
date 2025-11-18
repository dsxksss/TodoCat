import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/core/utils/date_time.dart';
import 'package:logger/logger.dart';

/// 统一的日期时间选择控制器
/// 集成了原来分散在DatePickerController和TimePickerController中的功能
class DateTimePickerController extends GetxController {
  static final _logger = Logger();
  
  // 当前选中的日期时间
  final selectedDateTime = Rx<DateTime?>(null);
  final defaultDateTime = DateTime.now().obs;
  
  // 日期相关
  final monthDays = <int>[].obs;
  final selectedDay = 0.obs;
  final firstDayOfWeek = 0.obs;
  final daysInMonth = 0.obs;
  final startPadding = 0.obs;
  final totalDays = 35.obs;
  
  // 时间相关
  final isAM = true.obs;
  final selectedHour = 11.obs;
  final selectedMinute = 0.obs;
  
  // 控制器
  final TextEditingController hEditingController = TextEditingController();
  final TextEditingController mEditingController = TextEditingController();
  final amPmController = FixedExtentScrollController(initialItem: 0);
  final hourController = FixedExtentScrollController(initialItem: 11);
  final minuteController = FixedExtentScrollController(initialItem: 0);

  // 计算属性
  bool get isCurrentMonth =>
      selectedDateTime.value?.year == DateTime.now().year &&
      selectedDateTime.value?.month == DateTime.now().month;

  bool get isSelectedDayValid =>
      selectedDay.value > 0 && selectedDay.value <= daysInMonth.value;

  TimeOfDay get currentTime => TimeOfDay(
    hour: isAM.value
        ? (selectedHour.value == 11 ? 0 : selectedHour.value + 1)
        : (selectedHour.value == 11 ? 12 : selectedHour.value + 13),
    minute: selectedMinute.value,
  );

  @override
  void onInit() {
    super.onInit();
    _logger.i('Initializing DateTimePickerController');
    _initializeDateTime();
    _setupListeners();
  }

  void _initializeDateTime() {
    selectedDateTime.value = null;
    _updateMonthData();
    _updateTimeInputs(defaultDateTime.value.hour, defaultDateTime.value.minute);
  }

  void _setupListeners() {
    // 监听选中日期变化，但避免循环调用
    ever(selectedDay, (_) {
      _logger.d('Selected day changed to: $selectedDay');
      // 不再自动触发 _updateDateTime，由外部显式调用
    });

    // 监听时间变化
    ever(selectedHour, (_) => _updateDateTimeFromTime());
    ever(selectedMinute, (_) => _updateDateTimeFromTime());
    ever(isAM, (_) => _updateDateTimeFromTime());
  }

  void _updateMonthData() {
    if (selectedDateTime.value == null) {
      final now = DateTime.now();
      monthDays.value = getMonthDays(now.year, now.month);
      firstDayOfWeek.value = firstDayWeek(now);
    } else {
      monthDays.value = getMonthDays(
        selectedDateTime.value!.year,
        selectedDateTime.value!.month,
      );
      firstDayOfWeek.value = firstDayWeek(selectedDateTime.value!);
    }
    
    daysInMonth.value = monthDays.length;
    startPadding.value = (firstDayOfWeek.value - 1) % 7;
    totalDays.value = daysInMonth.value + startPadding.value;
  }

  void _updateTimeInputs(int hours, int minutes) {
    hEditingController.text = hours.toString();
    mEditingController.text = minutes.toString();
  }

  void _updateTimeFromDateTime() {
    if (selectedDateTime.value == null) return;
    
    final dateTime = selectedDateTime.value!;
    final hour = dateTime.hour;
    isAM.value = hour < 12;
    
    if (isAM.value) {
      selectedHour.value = hour == 0 ? 11 : hour - 1;
    } else {
      selectedHour.value = hour == 12 ? 11 : hour - 13;
    }
    
    selectedMinute.value = dateTime.minute;
    _updateTimeControllers();
  }

  void _updateDateTimeFromTime() {
    if (selectedDateTime.value == null) return;
    
    final time = currentTime;
    final newDateTime = DateTime(
      selectedDateTime.value!.year,
      selectedDateTime.value!.month,
      selectedDateTime.value!.day,
      time.hour,
      time.minute,
    );
    
    selectedDateTime.value = newDateTime;
  }

  void _updateTimeControllers() {
    amPmController.jumpToItem(isAM.value ? 0 : 1);
    hourController.jumpToItem(selectedHour.value);
    minuteController.jumpToItem(selectedMinute.value);
  }

  /// 设置日期时间
  void setDateTime(DateTime? dateTime) {
    _logger.d('Setting datetime to: $dateTime');
    selectedDateTime.value = dateTime;
    
    if (dateTime != null) {
      // 更新相关状态
      selectedDay.value = dateTime.day;
      _updateMonthData();
      _updateTimeFromDateTime();
    }
  }

  /// 设置时间
  void setTime(TimeOfDay time) {
    _logger.d('Setting time to: $time');
    if (selectedDateTime.value != null) {
      final newDateTime = DateTime(
        selectedDateTime.value!.year,
        selectedDateTime.value!.month,
        selectedDateTime.value!.day,
        time.hour,
        time.minute,
      );
      selectedDateTime.value = newDateTime;
    } else {
      final now = DateTime.now();
      selectedDateTime.value = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
    }
  }

  /// 更新日期时间
  void _updateDateTime({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
  }) {
    final current = selectedDateTime.value ?? DateTime.now();
    
    try {
      final newDateTime = DateTime(
        year ?? current.year,
        month ?? current.month,
        day ?? current.day,
        hour ?? current.hour,
        minute ?? current.minute,
      );
      selectedDateTime.value = newDateTime;
    } catch (e) {
      _logger.e('Error updating datetime: $e');
    }
  }

  /// 重置到默认时间
  void resetToDefault() {
    _logger.d('Resetting datetime to default');
    _updateDateTime(
      year: defaultDateTime.value.year,
      month: defaultDateTime.value.month,
      day: defaultDateTime.value.day,
      hour: 0,
      minute: 0,
    );
    _updateTimeInputs(0, 0);
  }

  /// 重置时间
  void resetTime() {
    isAM.value = true;
    selectedHour.value = 11;
    selectedMinute.value = 0;
    _updateTimeControllers();
    _updateDateTimeFromTime();
  }

  /// 清空选择
  void clear() {
    _logger.d('Clearing datetime selection');
    selectedDateTime.value = null;
    selectedDay.value = 0;
    resetTime();
  }

  @override
  void onClose() {
    _logger.d('Cleaning up DateTimePickerController resources');
    hEditingController.dispose();
    mEditingController.dispose();
    amPmController.dispose();
    hourController.dispose();
    minuteController.dispose();
    super.onClose();
  }
}