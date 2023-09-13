import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/widgets/app_date_picker_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DatePanel extends StatefulWidget {
  const DatePanel({super.key});

  @override
  State<DatePanel> createState() => _DatePanelState();
}

class _DatePanelState extends State<DatePanel> {
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
    fontSize: 14,
    color: Colors.grey,
  );

  @override
  void initState() {
    super.initState();
  }

// 在 build 方法中添加日期渲染的部分
  Widget _buildDateGrid() {
    return GridView.builder(
      itemCount: _ctrl.totalDays.value as int,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        if (index < _ctrl.startPadding.value) {
          return const Text('');
        } else if (index < _ctrl.totalDays.value) {
          // 渲染当前月的日期
          final day = index - _ctrl.startPadding.value + 1;

          return AnimationBtn(
            onHoverBgColorChangeEnabled: true,
            onHoverAnimationEnabled: false,
            hoverBgColor: Colors.blueGrey.withOpacity(0.3),
            onPressed: () {
              _ctrl.selectedDay.value = day as int;
            },
            child: Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: day == _ctrl.selectedDay.value
                      ? Colors.lightBlue
                      : context.theme.dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          day == _ctrl.selectedDay.value ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Text('');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: context.theme.dialogBackgroundColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimationBtn(
                onPressed: () {
                  if (_ctrl.currentDate.value.month > 1) {
                    _ctrl.changeDate(month: _ctrl.currentDate.value.month - 1);
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
              Obx(
                () => Text(
                  "${_ctrl.currentDate.value.year} year ${_ctrl.currentDate.value.month} month",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              AnimationBtn(
                onPressed: () {
                  if (_ctrl.currentDate.value.month < 12) {
                    _ctrl.changeDate(month: _ctrl.currentDate.value.month + 1);
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
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [..._weekTags.map((e) => Text(e.tr, style: _dateStyle))],
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(height: 300, child: Obx(() => _buildDateGrid())),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
