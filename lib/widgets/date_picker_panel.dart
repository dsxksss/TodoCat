import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/utils/date_time.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/date_panel.dart';
import 'package:todo_cat/widgets/time_panel.dart';

class DatePickerPanel extends StatelessWidget {
  DatePickerPanel({super.key, required this.dialogTag});
  final String dialogTag;
  final RxBool isTimePanelOpen = false.obs;
  final DatePickerController _datePickerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => animate(target: isTimePanelOpen.value ? 1 : 0).custom(
        duration: 200.ms,
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) => Obx(() => Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      SmartDialog.dismiss(tag: dialogTag);
                    },
                    child: Container(color: Colors.transparent),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                        height: lerpDouble(
                          _datePickerController.totalDays.value <= 35
                              ? 360
                              : 400,
                          _datePickerController.totalDays.value <= 35
                              ? 430
                              : 470,
                          value,
                        ),
                        width: 340,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: context.theme.dialogBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false, dragDevices: {
                            //必须设置此事件，不然无法滚动
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          }),
                          child: ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${timestampToDate(
                                      _datePickerController.currentDate.value
                                          .millisecondsSinceEpoch,
                                    )} - ${getTimeString(_datePickerController.currentDate.value)}",
                                  ),
                                  AnimationBtn(
                                    onHoverAnimationEnabled: false,
                                    onPressed: () => isTimePanelOpen.value =
                                        !isTimePanelOpen.value,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        child: Icon(
                                          Icons.access_time,
                                          color: isTimePanelOpen.value
                                              ? Colors.grey
                                              : null,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              DatePanel(),
                              Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Divider(height: 2),
                                  ),
                                  TimePanel()
                                ],
                              )
                                  .animate(
                                      target: isTimePanelOpen.value ? 1 : 0)
                                  .fadeIn()
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
