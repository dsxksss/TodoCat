import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/utils/date_time.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DatePanel extends StatefulWidget {
  DatePanel({super.key});

  @override
  State<DatePanel> createState() => _DatePanelState();
}

class _DatePanelState extends State<DatePanel> {
  final TextStyle _dateStyle =
      const TextStyle(fontSize: 14, color: Colors.grey);
  late DateTime _currentDate;
  late List<int> _monthDays;

  @override
  void initState() {
    _currentDate = DateTime.now();
    _monthDays = getMonthDays(_currentDate.year, _currentDate.day);
    super.initState();
  }

  // 在 _DatePanelState 类中添加一个名为 _firstDayOfWeek 的函数来获取当前月份的第一天是星期几
  int _firstDayOfWeek(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    return firstDayOfMonth.weekday;
  }

// 在 build 方法中添加日期渲染的部分
  Widget _buildDateGrid() {
    final firstDayOfWeek = _firstDayOfWeek(_currentDate);
    final daysInMonth = _monthDays.length;
    final startPadding = (firstDayOfWeek - 1) % 7;
    final totalDays = daysInMonth + startPadding;
    final currentDate = DateTime.now();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7列，一周7天
      ),
      itemBuilder: (context, index) {
        if (index < startPadding) {
          // 渲染前一个月的日期
          final prevMonthDay = daysInMonth - (startPadding - index) + 1;
          return Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                // color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  '',
                ),
              ),
            ),
          );
        } else if (index < totalDays) {
          // 渲染当前月的日期
          final day = index - startPadding + 1;
          final isToday = currentDate.year == _currentDate.year &&
              currentDate.month == _currentDate.month &&
              currentDate.day == day;
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              // padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: isToday ? Colors.blue : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        } else {
          // 渲染下一个月的日期
          final nextMonthDay = index - totalDays + 1;
          return Text(
            '',
          );
        }
      },
      itemCount: totalDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border.all(color: context.theme.dividerColor, width: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimationBtn(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(FontAwesomeIcons.angleLeft, size: 15),
                  ),
                ),
              ),
              Text(
                "date 2023",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              AnimationBtn(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.angleRight,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Su", style: _dateStyle),
              Text("Mo", style: _dateStyle),
              Text("Tu", style: _dateStyle),
              Text("We", style: _dateStyle),
              Text("Th", style: _dateStyle),
              Text("Fr", style: _dateStyle),
              Text("Sa", style: _dateStyle),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(height: 250, child: _buildDateGrid()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimationBtn(
                onPressed: () => {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "Clear",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
