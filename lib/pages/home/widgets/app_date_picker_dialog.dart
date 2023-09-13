import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/utils/date_time.dart';
import 'package:todo_cat/widgets/date_panel.dart';
import 'package:todo_cat/widgets/time_panel.dart';

class DatePickerController extends GetxController {
  late final currentDate = DateTime.now().obs;
  late final defaultDate = DateTime.now().obs;
  late final RxList<int> monthDays = <int>[].obs;
  final selectedDay = 0.obs;
  final firstDayOfWeek = 0.obs;
  final daysInMonth = 0.obs;
  final startPadding = RxNum(0);
  final totalDays = RxNum(0);

  @override
  void onInit() {
    monthDays.value = getMonthDays(
      currentDate.value.year,
      currentDate.value.month,
    );

    firstDayOfWeek.value = firstDayWeek(currentDate.value);
    daysInMonth.value = monthDays.length;
    startPadding.value = (firstDayOfWeek - 1) % 7;
    totalDays.value = daysInMonth.value + startPadding.value;

    selectedDay.value = defaultDate.value.day;

    ever(selectedDay, (callback) => changeDate(day: selectedDay.value));
    ever(currentDate, (callback) => selectedDay.value = currentDate.value.day);
    super.onInit();
  }

  void resetDate() {
    changeDate(
      year: defaultDate.value.year,
      month: defaultDate.value.month,
      day: defaultDate.value.day,
    );
  }

  void changeDate({int? year, int? month, int? day}) {
    currentDate.value = DateTime(
      year ?? currentDate.value.year,
      month ?? currentDate.value.month,
      day ?? currentDate.value.day,
    );
    monthDays.value = getMonthDays(
      currentDate.value.year,
      currentDate.value.month,
    );
    firstDayOfWeek.value = firstDayWeek(currentDate.value);
    daysInMonth.value = monthDays.length;
    startPadding.value = (firstDayOfWeek - 1) % 7;
    totalDays.value = daysInMonth.value + startPadding.value;
  }
}

class TodoCatDatePickerDialog extends StatefulWidget {
  const TodoCatDatePickerDialog({
    super.key,
  });

  @override
  State<TodoCatDatePickerDialog> createState() =>
      _TodoCatDatePickerDialogState();
}

class _TodoCatDatePickerDialogState extends State<TodoCatDatePickerDialog> {
  late final DatePickerController _ctrl;

  @override
  void initState() {
    Get.put(DatePickerController());
    _ctrl = Get.find();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 0.6.sw,
          height: 0.36.sw,
          padding: EdgeInsets.only(left: 20, right: 20, top: 15),
          decoration: BoxDecoration(
            color: context.theme.dialogBackgroundColor,
            border: Border.all(width: 0.80, color: context.theme.dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 5),
                      const Icon(FontAwesomeIcons.clock),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Obx(
                          () => Text(
                            "${timestampToDate(
                              _ctrl.currentDate.value.millisecondsSinceEpoch,
                            )} ${getWeekName(
                              _ctrl.currentDate.value,
                            ).tr}",
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        // 取消按钮按下时出现的颜色
                        style: const ButtonStyle(
                            overlayColor:
                                MaterialStatePropertyAll(Colors.transparent)),
                        onPressed: () {
                          _ctrl.resetDate();
                        },
                        child: Text("clear".tr),
                      ),
                      TextButton(
                        // 取消按钮按下时出现的颜色
                        style: const ButtonStyle(
                            overlayColor:
                                MaterialStatePropertyAll(Colors.transparent)),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text("done".tr),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DatePanel(),
                  Container(
                    height: 0.25.sw,
                    width: 1,
                    decoration: BoxDecoration(
                      color: context.theme.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  TimePanel(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
