import 'package:flutter/material.dart';

class DatePanel extends StatefulWidget {
  const DatePanel({
    super.key,
    required this.onDateSelected,
    this.selectedDate,
  });

  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;

  @override
  State<DatePanel> createState() => _DatePanelState();
}

class _DatePanelState extends State<DatePanel> {
  late Key _calendarKey;
  DateTime? _lastSelectedDate;

  @override
  void initState() {
    super.initState();
    _calendarKey = UniqueKey();
    _lastSelectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(DatePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当selectedDate变化时，强制重新构建
    if (widget.selectedDate != _lastSelectedDate) {
      _calendarKey = UniqueKey();
      _lastSelectedDate = widget.selectedDate;
    }
  }
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final selectedDate = widget.selectedDate;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF3B82F6), // 与add task button一致的蓝色
              onPrimary: Colors.white, // 选中文字为白色
              surface: Colors.transparent,
            ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        // 自定义日期选择样式
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.transparent,
          headerBackgroundColor: Colors.transparent,
          headerForegroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          weekdayStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w600,
          ),
          dayStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
          // 今天的样式
          todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF3B82F6); // 今天被选中时的背景色
            }
            return const Color(0xFF3B82F6).withOpacity(0.2); // 今天未被选中时的背景色
          }),
          todayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white; // 今天被选中时的文字色
            }
            return const Color(0xFF3B82F6); // 今天未被选中时的文字色
          }),
          // 非今天日期的样式（这是关键！）
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF3B82F6); // 选中背景色
            }
            return Colors.transparent;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white; // 选中文字颜色
            }
            return Theme.of(context).textTheme.bodyLarge?.color;
          }),
          dayOverlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFF3B82F6).withOpacity(0.2);
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFF3B82F6).withOpacity(0.1);
            }
            return Colors.transparent;
          }),
          // 确保日期按钮是圆形
          dayShape: WidgetStateProperty.all(
            const CircleBorder(), // 使用CircleBorder确保是正圆形
          ),
          todayBorder: const BorderSide(
            color: Color(0xFF3B82F6),
            width: 1,
          ),
        ),
      ),
      child: CalendarDatePicker(
        key: _calendarKey, // 使用独特的key强制重建
        initialDate: selectedDate ?? now,
        currentDate: now, // currentDate用于标记今天
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
        onDateChanged: (date) {
          final currentTime = selectedDate != null 
              ? TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute)
              : TimeOfDay.now();
          final selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            currentTime.hour,
            currentTime.minute,
          );
          widget.onDateSelected(selectedDateTime);
        },
        selectableDayPredicate: (date) => true,
      ),
    );
  }
}
