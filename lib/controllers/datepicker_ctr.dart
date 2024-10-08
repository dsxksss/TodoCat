import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/core/utils/date_time.dart';

class DatePickerController extends GetxController {
  late final currentDate = DateTime.now().obs; // 可观察的当前日期。
  late final defaultDate = DateTime.now().obs; // 可观察的默认日期。
  late final RxList<int> monthDays = <int>[].obs; // 可观察的当前月份的天数列表。
  final selectedDay = 0.obs; // 可观察的选中日期。
  final firstDayOfWeek = 0.obs; // 可观察的星期的第一天。
  final daysInMonth = 0.obs; // 可观察的当前月份的天数。
  final startPadding = RxNum(0); // 可观察的月份第一天的填充。
  final totalDays = RxNum(0); // 可观察的总天数。
  final TextEditingController hEditingController =
      TextEditingController(); // 小时输入控制器。
  final TextEditingController mEditingController =
      TextEditingController(); // 分钟输入控制器。

  // 初始化方法。
  @override
  void onInit() async {
    super.onInit();
    _initializeDateData(); // 初始化日期数据。
    await _initializeTimeData(); // 初始化时间数据。

    // 每当当前日期变化时更新选中日期。
    ever(selectedDay, (callback) => changeDate(day: selectedDay.value));
    // 将选中日期更新为当前日期的天数。
    ever(currentDate, (callback) => selectedDay.value = currentDate.value.day);
  }

  // 初始化日期数据。
  void _initializeDateData() {
    monthDays.value = getMonthDays(
        currentDate.value.year, currentDate.value.month); // 获取当前月份的天数。
    firstDayOfWeek.value = firstDayWeek(currentDate.value); // 获取星期的第一天。
    daysInMonth.value = monthDays.length; // 获取月份的天数。
    startPadding.value = (firstDayOfWeek - 1) % 7; // 计算开始填充。
    totalDays.value = daysInMonth.value + startPadding.value; // 计算总天数。
    selectedDay.value = defaultDate.value.day; // 将选中日期设置为默认日期的天数。
  }

  // 初始化时间数据。
  Future<void> _initializeTimeData() async {
    await 2.delay(() {
      hEditingController.text =
          defaultDate.value.hour.toString(); // 将小时输入设置为默认日期的小时。
      mEditingController.text =
          defaultDate.value.minute.toString(); // 将分钟输入设置为默认日期的分钟。
    });
  }

  // 重置日期为默认日期。
  void resetDate() {
    changeDate(
      year: defaultDate.value.year,
      month: defaultDate.value.month,
      day: defaultDate.value.day,
      hour: 0,
      minute: 0,
    );
    hEditingController.text = '0'; // 重置小时输入。
    mEditingController.text = '0'; // 重置分钟输入。
  }

  // 更改当前日期。
  void changeDate({int? year, int? month, int? day, int? hour, int? minute}) {
    currentDate.value = DateTime(
      year ?? currentDate.value.year,
      month ?? currentDate.value.month,
      day ?? currentDate.value.day,
      hour ?? currentDate.value.hour,
      minute ?? currentDate.value.minute,
    );
    _initializeDateData(); // 重新初始化日期数据。
  }
}
