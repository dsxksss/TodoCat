import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:TodoCat/controllers/unified/datetime_picker_controller.dart';

/// @deprecated 使用 DateTimePickerController 替代
/// 这个控制器保留是为了向后兼容，建议使用新的统一控制器
class TimePickerController extends GetxController {
  static final _logger = Logger();
  
  // 委托给新的统一控制器
  late final DateTimePickerController _unifiedController;
  
  // 为了向后兼容而保留的属性
  RxBool get isAM => _unifiedController.isAM;
  RxInt get selectedHour => _unifiedController.selectedHour;
  RxInt get selectedMinute => _unifiedController.selectedMinute;
  final isInitialized = false.obs;

  FixedExtentScrollController get amPmController => _unifiedController.amPmController;
  FixedExtentScrollController get hourController => _unifiedController.hourController;
  FixedExtentScrollController get minuteController => _unifiedController.minuteController;

  @override
  void onInit() {
    super.onInit();
    _logger.w('TimePickerController is deprecated. Use DateTimePickerController instead.');
    _unifiedController = DateTimePickerController();
    _unifiedController.onInit();
    isInitialized.value = true;
  }

  @override
  void onClose() {
    _logger.d('Cleaning up TimePickerController resources');
    _unifiedController.onClose();
    super.onClose();
  }

  // 委托方法实现
  void updateToTime(TimeOfDay time) => _unifiedController.setTime(time);
  void resetTime() => _unifiedController.resetTime();
  TimeOfDay getCurrentTime() => _unifiedController.currentTime;
}
