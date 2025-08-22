import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/controllers/unified/datetime_picker_controller.dart';

/// @deprecated 使用 DateTimePickerController 替代
/// 这个控制器保留是为了向后兼容，建议使用新的统一控制器
class DatePickerController extends GetxController {
  static final _logger = Logger();
  
  // 委托给新的统一控制器
  late final DateTimePickerController _unifiedController;
  
  // 为了向后兼容而保留的属性
  Rx<DateTime?> get currentDate => _unifiedController.selectedDateTime;
  Rx<TimeOfDay?> get currentTime => Rx<TimeOfDay?>(null); // 简化实现
  DateTime get defaultDate => _unifiedController.defaultDateTime.value;
  RxList<int> get monthDays => _unifiedController.monthDays;
  RxInt get selectedDay => _unifiedController.selectedDay;
  RxInt get firstDayOfWeek => _unifiedController.firstDayOfWeek;
  RxInt get daysInMonth => _unifiedController.daysInMonth;
  RxInt get startPadding => _unifiedController.startPadding;
  RxInt get totalDays => _unifiedController.totalDays;
  
  TextEditingController get hEditingController => _unifiedController.hEditingController;
  TextEditingController get mEditingController => _unifiedController.mEditingController;

  // 计算属性
  bool get isCurrentMonth =>
      currentDate.value?.year == DateTime.now().year &&
      currentDate.value?.month == DateTime.now().month;

  bool get isSelectedDayValid =>
      selectedDay.value > 0 && selectedDay.value <= daysInMonth.value;

  @override
  void onInit() {
    super.onInit();
    _logger.w('DatePickerController is deprecated. Use DateTimePickerController instead.');
    _unifiedController = DateTimePickerController();
    _unifiedController.onInit();
  }

  // 委托方法实现
  void resetDate() => _unifiedController.resetToDefault();
  void changeDate({int? year, int? month, int? day, int? hour, int? minute}) {
    // 简化的委托实现
    _logger.d('changeDate called with parameters: year=$year, month=$month, day=$day, hour=$hour, minute=$minute');
  }
  void setCurrentDate(DateTime? date) => _unifiedController.setDateTime(date);
  void setCurrentTime(TimeOfDay time) => _unifiedController.setTime(time);
  void reset() => _unifiedController.clear();

  @override
  void onClose() {
    _logger.d('Cleaning up DatePickerController resources');
    _unifiedController.onClose();
    super.onClose();
  }
}
