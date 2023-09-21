import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/utils/date_time.dart';
import 'package:todo_cat/widgets/date_panel.dart';
import 'package:todo_cat/widgets/time_panel.dart';

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
  late final AddTodoDialogController _dialogCtrl;

  @override
  void initState() {
    Get.put(DatePickerController());
    _ctrl = Get.find();
    _dialogCtrl = Get.find();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 800,
          height: 570,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
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
                            ).tr} ${getTimeString(_ctrl.currentDate.value)}",
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        style: const ButtonStyle(
                            overlayColor:
                                MaterialStatePropertyAll(Colors.transparent)),
                        onPressed: () {
                          _ctrl.resetDate();
                        },
                        child: Text("reset".tr),
                      ),
                      TextButton(
                        style: const ButtonStyle(
                            overlayColor:
                                MaterialStatePropertyAll(Colors.transparent)),
                        onPressed: () {
                          // 显示时间
                          _dialogCtrl.remindersText.value = "${timestampToDate(
                            _ctrl.currentDate.value.millisecondsSinceEpoch,
                          )} ${getWeekName(
                            _ctrl.currentDate.value,
                          ).tr} ${getTimeString(_ctrl.currentDate.value)}";

                          // 时间戳
                          _dialogCtrl.remindersValue.value =
                              _ctrl.currentDate.value.millisecondsSinceEpoch;
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
