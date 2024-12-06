import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/core/utils/date_time.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:todo_cat/widgets/date_panel.dart';
import 'package:todo_cat/widgets/time_panel.dart';

class DatePickerPanel extends StatelessWidget {
  DatePickerPanel({super.key, required this.dialogTag}) {
    _datePickerController = Get.find<DatePickerController>();
  }

  final String dialogTag;
  final RxBool isTimePanelOpen = false.obs;
  late final DatePickerController _datePickerController;

  static const _animationDuration = Duration(milliseconds: 200);
  static const _animationCurve = Curves.easeInOutCubic;

  static const _normalPanelHeight = 360.0;
  static const _extendedPanelHeight = 400.0;
  static const _normalPanelHeightWithTime = 430.0;
  static const _extendedPanelHeightWithTime = 470.0;
  static const _panelWidth = 340.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTimeOpen = isTimePanelOpen.value;
      final totalDays = _datePickerController.totalDays.value;
      final currentDate = _datePickerController.currentDate.value;
      final baseHeight =
          totalDays <= 35 ? _normalPanelHeight : _extendedPanelHeight;
      final timeHeight = totalDays <= 35
          ? _normalPanelHeightWithTime
          : _extendedPanelHeightWithTime;

      return AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              GestureDetector(
                onTap: () => SmartDialog.dismiss(tag: dialogTag),
                child: Container(color: Colors.transparent),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: isTimeOpen ? timeHeight : baseHeight,
                  width: _panelWidth,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: context.theme.dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      scrollbars: false,
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        _buildHeader(currentDate),
                        const SizedBox(height: 10),
                        DatePanel(),
                        if (isTimeOpen) _buildTimePanel(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(DateTime currentDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${timestampToDate(currentDate.millisecondsSinceEpoch)} - ${getTimeString(currentDate)}",
        ),
        AnimationBtn(
          onHoverAnimationEnabled: false,
          onPressed: () => isTimePanelOpen.toggle(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Obx(() => Icon(
                    Icons.access_time,
                    color: isTimePanelOpen.value ? Colors.grey : null,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePanel() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 2),
        ),
        TimePanel(),
      ],
    ).animate().fadeIn(
          duration: _animationDuration,
          curve: _animationCurve,
        );
  }
}
