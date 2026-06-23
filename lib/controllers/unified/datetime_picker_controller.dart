import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_cat/core/utils/date_time.dart';
import 'package:logger/logger.dart';

part 'datetime_picker_controller.g.dart';

/// 统一的日期时间选择控制器的不可变状态。
///
/// 集成了原来分散在 DatePickerController 和 TimePickerController 中的字段，
/// 原本各 `.obs` 字段在此合并为一个不可变对象（配合 [copyWith] 使用）。
class DateTimePickerState {
  const DateTimePickerState({
    this.selectedDateTime,
    required this.defaultDateTime,
    this.monthDays = const <int>[],
    this.selectedDay = 0,
    this.firstDayOfWeek = 0,
    this.daysInMonth = 0,
    this.startPadding = 0,
    this.totalDays = 35,
    this.isAM = true,
    this.selectedHour = 11,
    this.selectedMinute = 0,
  });

  /// 当前选中的日期时间
  final DateTime? selectedDateTime;

  /// 默认日期时间（用于重置）
  final DateTime defaultDateTime;

  // 日期相关
  final List<int> monthDays;
  final int selectedDay;
  final int firstDayOfWeek;
  final int daysInMonth;
  final int startPadding;
  final int totalDays;

  // 时间相关
  final bool isAM;
  final int selectedHour;
  final int selectedMinute;

  DateTimePickerState copyWith({
    DateTime? selectedDateTime,
    bool clearSelectedDateTime = false,
    DateTime? defaultDateTime,
    List<int>? monthDays,
    int? selectedDay,
    int? firstDayOfWeek,
    int? daysInMonth,
    int? startPadding,
    int? totalDays,
    bool? isAM,
    int? selectedHour,
    int? selectedMinute,
  }) {
    return DateTimePickerState(
      selectedDateTime: clearSelectedDateTime
          ? null
          : (selectedDateTime ?? this.selectedDateTime),
      defaultDateTime: defaultDateTime ?? this.defaultDateTime,
      monthDays: monthDays ?? this.monthDays,
      selectedDay: selectedDay ?? this.selectedDay,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      daysInMonth: daysInMonth ?? this.daysInMonth,
      startPadding: startPadding ?? this.startPadding,
      totalDays: totalDays ?? this.totalDays,
      isAM: isAM ?? this.isAM,
      selectedHour: selectedHour ?? this.selectedHour,
      selectedMinute: selectedMinute ?? this.selectedMinute,
    );
  }
}

/// 统一的日期时间选择控制器（原 GetxController -> Riverpod Notifier）。
///
/// `state` 即 [DateTimePickerState]。原来的 `ever(...)` 监听器
/// （当 selectedHour / selectedMinute / isAM 变化时重算 selectedDateTime）
/// 改为在对应 setter 方法内部显式调用 [_updateDateTimeFromTime]。
@Riverpod(keepAlive: true)
class DateTimePickerController extends _$DateTimePickerController {
  static final _logger = Logger();

  // 控制器（保留为实例字段，由 ref.onDispose 释放）
  final TextEditingController hEditingController = TextEditingController();
  final TextEditingController mEditingController = TextEditingController();
  final amPmController = FixedExtentScrollController(initialItem: 0);
  final hourController = FixedExtentScrollController(initialItem: 11);
  final minuteController = FixedExtentScrollController(initialItem: 0);

  @override
  DateTimePickerState build() {
    _logger.i('Initializing DateTimePickerController');

    ref.onDispose(() {
      _logger.d('Cleaning up DateTimePickerController resources');
      hEditingController.dispose();
      mEditingController.dispose();
      amPmController.dispose();
      hourController.dispose();
      minuteController.dispose();
    });

    final initial = DateTimePickerState(defaultDateTime: DateTime.now());
    // 初始化输入框 & 月份数据
    _updateTimeInputs(
      initial.defaultDateTime.hour,
      initial.defaultDateTime.minute,
    );
    return _withMonthData(initial);
  }

  // 计算属性
  bool get isCurrentMonth =>
      state.selectedDateTime?.year == DateTime.now().year &&
      state.selectedDateTime?.month == DateTime.now().month;

  bool get isSelectedDayValid =>
      state.selectedDay > 0 && state.selectedDay <= state.daysInMonth;

  TimeOfDay get currentTime => TimeOfDay(
        hour: state.isAM
            ? (state.selectedHour == 11 ? 0 : state.selectedHour + 1)
            : (state.selectedHour == 11 ? 12 : state.selectedHour + 13),
        minute: state.selectedMinute,
      );

  /// 基于给定 state 重新计算月份相关字段，返回新的 state（不修改 `state`）。
  DateTimePickerState _withMonthData(DateTimePickerState s) {
    final List<int> monthDays;
    final int firstDayOfWeek;
    if (s.selectedDateTime == null) {
      final now = DateTime.now();
      monthDays = getMonthDays(now.year, now.month);
      firstDayOfWeek = firstDayWeek(now);
    } else {
      monthDays = getMonthDays(
        s.selectedDateTime!.year,
        s.selectedDateTime!.month,
      );
      firstDayOfWeek = firstDayWeek(s.selectedDateTime!);
    }

    final daysInMonth = monthDays.length;
    final startPadding = (firstDayOfWeek - 1) % 7;
    final totalDays = daysInMonth + startPadding;

    return s.copyWith(
      monthDays: monthDays,
      firstDayOfWeek: firstDayOfWeek,
      daysInMonth: daysInMonth,
      startPadding: startPadding,
      totalDays: totalDays,
    );
  }

  void _updateTimeInputs(int hours, int minutes) {
    hEditingController.text = hours.toString();
    mEditingController.text = minutes.toString();
  }

  /// 根据 selectedDateTime 推算时间字段，返回新的 state（同时同步滚动控制器）。
  DateTimePickerState _withTimeFromDateTime(DateTimePickerState s) {
    if (s.selectedDateTime == null) return s;

    final dateTime = s.selectedDateTime!;
    final hour = dateTime.hour;
    final isAM = hour < 12;

    final int selectedHour;
    if (isAM) {
      selectedHour = hour == 0 ? 11 : hour - 1;
    } else {
      selectedHour = hour == 12 ? 11 : hour - 13;
    }

    final selectedMinute = dateTime.minute;
    _syncTimeControllers(
      isAM: isAM,
      selectedHour: selectedHour,
      selectedMinute: selectedMinute,
    );

    return s.copyWith(
      isAM: isAM,
      selectedHour: selectedHour,
      selectedMinute: selectedMinute,
    );
  }

  /// 原 `ever(selectedHour/selectedMinute/isAM)` 的逻辑：时间变化时重算 selectedDateTime。
  void _updateDateTimeFromTime() {
    if (state.selectedDateTime == null) return;

    final time = currentTime;
    final newDateTime = DateTime(
      state.selectedDateTime!.year,
      state.selectedDateTime!.month,
      state.selectedDateTime!.day,
      time.hour,
      time.minute,
    );

    state = state.copyWith(selectedDateTime: newDateTime);
  }

  void _syncTimeControllers({
    required bool isAM,
    required int selectedHour,
    required int selectedMinute,
  }) {
    amPmController.jumpToItem(isAM ? 0 : 1);
    hourController.jumpToItem(selectedHour);
    minuteController.jumpToItem(selectedMinute);
  }

  /// 设置日期时间
  void setDateTime(DateTime? dateTime) {
    _logger.d('Setting datetime to: $dateTime');

    var next = state.copyWith(
      selectedDateTime: dateTime,
      clearSelectedDateTime: dateTime == null,
    );

    if (dateTime != null) {
      // 更新相关状态
      next = next.copyWith(selectedDay: dateTime.day);
      next = _withMonthData(next);
      next = _withTimeFromDateTime(next);
    }

    state = next;
  }

  /// 设置时间
  void setTime(TimeOfDay time) {
    _logger.d('Setting time to: $time');
    if (state.selectedDateTime != null) {
      final newDateTime = DateTime(
        state.selectedDateTime!.year,
        state.selectedDateTime!.month,
        state.selectedDateTime!.day,
        time.hour,
        time.minute,
      );
      state = state.copyWith(selectedDateTime: newDateTime);
    } else {
      final now = DateTime.now();
      state = state.copyWith(
        selectedDateTime: DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        ),
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
    final current = state.selectedDateTime ?? DateTime.now();

    try {
      final newDateTime = DateTime(
        year ?? current.year,
        month ?? current.month,
        day ?? current.day,
        hour ?? current.hour,
        minute ?? current.minute,
      );
      state = state.copyWith(selectedDateTime: newDateTime);
    } catch (e) {
      _logger.e('Error updating datetime: $e');
    }
  }

  /// 重置到默认时间
  void resetToDefault() {
    _logger.d('Resetting datetime to default');
    _updateDateTime(
      year: state.defaultDateTime.year,
      month: state.defaultDateTime.month,
      day: state.defaultDateTime.day,
      hour: 0,
      minute: 0,
    );
    _updateTimeInputs(0, 0);
  }

  /// 重置时间
  void resetTime() {
    _syncTimeControllers(isAM: true, selectedHour: 11, selectedMinute: 0);
    state = state.copyWith(isAM: true, selectedHour: 11, selectedMinute: 0);
    _updateDateTimeFromTime();
  }

  /// 清空选择
  void clear() {
    _logger.d('Clearing datetime selection');
    state = state.copyWith(clearSelectedDateTime: true, selectedDay: 0);
    resetTime();
  }
}
