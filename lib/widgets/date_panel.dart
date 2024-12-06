import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/datepicker_ctr.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DatePanel extends StatelessWidget {
  DatePanel({super.key});

  final DatePickerController _ctrl = Get.find();

  final List<String> _weekTags = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun'
  ];

  final TextStyle _dateStyle = const TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

// 在 build 方法中添加日期渲染的部分
  Widget _buildDateGrid() {
    return GridView.builder(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      itemCount: _ctrl.totalDays.value,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < _ctrl.startPadding.value) {
          // 渲染前一个月的日期
          final prevMonthDay =
              _ctrl.daysInMonth.value - _ctrl.startPadding.value - index + 1;
          return Center(
            child: Text(
              prevMonthDay.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        } else if (index < _ctrl.totalDays.value) {
          // 渲染当前月的日期
          final day = index - _ctrl.startPadding.value + 1;

          return AnimationBtn(
            onHoverBgColorChangeEnabled: true,
            onHoverAnimationEnabled: false,
            hoverBgColor: Colors.blueGrey.withOpacity(0.3),
            onPressed: () {
              _ctrl.selectedDay.value = day;
            },
            child: Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: day == _ctrl.selectedDay.value
                      ? context.isDarkMode
                          ? context.theme.dialogBackgroundColor
                          : const Color.fromRGBO(232, 238, 254, 1)
                      : context.theme.dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    width: 4,
                    color: day == _ctrl.selectedDay.value
                        ? const Color.fromRGBO(42, 100, 255, 1)
                        : context.theme.dialogBackgroundColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: day == _ctrl.selectedDay.value
                          ? context.isDarkMode
                              ? Colors.grey.shade300
                              : const Color.fromRGBO(42, 100, 255, 1)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          // 渲染下一个月的日期
          final nextMonthDay = index - _ctrl.totalDays.value + 1;
          return Center(
            child: Text(
              nextMonthDay.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                "${_ctrl.currentDate.value.year} ${"year".tr} ${_ctrl.currentDate.value.month} ${"month".tr}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Row(
              children: [
                AnimationBtn(
                  onPressed: () {
                    if (_ctrl.currentDate.value.month > 1) {
                      _ctrl.changeDate(
                          month: _ctrl.currentDate.value.month - 1);
                    }
                  },
                  onHoverAnimationEnabled: false,
                  onClickAnimationEnabled: false,
                  onHoverBgColorChangeEnabled: true,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(FontAwesomeIcons.angleLeft, size: 15),
                    ),
                  ),
                ),
                AnimationBtn(
                  onPressed: () {
                    if (_ctrl.currentDate.value.month < 12) {
                      _ctrl.changeDate(
                          month: _ctrl.currentDate.value.month + 1);
                    }
                  },
                  onHoverAnimationEnabled: false,
                  onClickAnimationEnabled: false,
                  onHoverBgColorChangeEnabled: true,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        FontAwesomeIcons.angleRight,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [..._weekTags.map((e) => Text(e.tr, style: _dateStyle))],
        ),
        const SizedBox(height: 10),
        Obx(() => _buildDateGrid()),
      ],
    );
  }
}
