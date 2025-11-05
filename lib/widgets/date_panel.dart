import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _updateSelectedDate();
  }

  @override
  void didUpdateWidget(DatePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _updateSelectedDate();
    }
  }
  
  void _updateSelectedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (widget.selectedDate != null) {
      final dateOnly = DateTime(
        widget.selectedDate!.year,
        widget.selectedDate!.month,
        widget.selectedDate!.day,
      );
      
      // 如果选中的日期是过去的，则使用今天
      if (dateOnly.isBefore(today)) {
        _selectedDate = today;
        // 保持当前月份显示
        _currentMonth = DateTime(now.year, now.month, 1);
      } else {
        _selectedDate = dateOnly;
        // 只有当选中日期不是过去日期时，才跳转到对应月份
        _currentMonth = DateTime(dateOnly.year, dateOnly.month, 1);
      }
    } else {
      _selectedDate = null;
      // 默认显示当前月份
      _currentMonth = DateTime(now.year, now.month, 1);
    }
  }

  void _onDateTap(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 不允许选择过去的日期
    if (date.isBefore(today)) {
      return;
    }
    
    setState(() {
      _selectedDate = date;
    });
    
    // 结合时间信息
    final time = widget.selectedDate != null 
        ? TimeOfDay(hour: widget.selectedDate!.hour, minute: widget.selectedDate!.minute)
        : TimeOfDay.now();
    
    DateTime selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    
    // 如果选择的是今天，但时间比当前时间要早，则设置为当前时间
    if (date.isAtSameMomentAs(today) && selectedDateTime.isBefore(now)) {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        now.hour,
        now.minute,
      );
    }
    
    widget.onDateSelected(selectedDateTime);
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = _currentMonth;
    final lastDay = DateTime(firstDay.year, firstDay.month + 1, 0);
    final daysInMonth = lastDay.day;
    
    // 获取这个月第一天是星期几（0=周一，6=周日）
    int firstWeekday = firstDay.weekday - 1;
    
    List<DateTime> days = [];
    
    // 添加上个月的日期来填充第一周
    final prevMonth = DateTime(firstDay.year, firstDay.month - 1, 0);
    for (int i = firstWeekday - 1; i >= 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, prevMonth.day - i));
    }
    
    // 添加当前月的日期
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(firstDay.year, firstDay.month, day));
    }
    
    // 添加下个月的日期来填充最后一周
    final remainingDays = 42 - days.length; // 6周 × 7天
    for (int day = 1; day <= remainingDays; day++) {
      days.add(DateTime(firstDay.year, firstDay.month + 1, day));
    }
    
    return days;
  }

  Widget _buildDayCell(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSelected = _selectedDate?.isAtSameMomentAs(date) ?? false;
    final isToday = date.isAtSameMomentAs(today);
    final isCurrentMonth = date.month == _currentMonth.month;
    final isPastDate = date.isBefore(today);
    
    return GestureDetector(
      onTap: () => _onDateTap(date),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected 
              ? const Color(0xFF3B82F6)
              : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: const Color(0xFF3B82F6), width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : isPastDate
                      ? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.3)
                      : isCurrentMonth
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final monthNames = [
      'january'.tr, 'february'.tr, 'march'.tr, 'april'.tr,
      'may'.tr, 'june'.tr, 'july'.tr, 'august'.tr,
      'september'.tr, 'october'.tr, 'november'.tr, 'december'.tr
    ];
    
    final weekDays = [
      'monday'.tr, 'tuesday'.tr, 'wednesday'.tr, 'thursday'.tr,
      'friday'.tr, 'saturday'.tr, 'sunday'.tr
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 月份导航
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentMonth.year} ${monthNames[_currentMonth.month - 1]}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _goToPreviousMonth,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: _goToNextMonth,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 星期标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDays.map((day) => SizedBox(
              width: 44,
              child: Center(
                child: Text(
                  day, // 直接显示翻译后的字符串
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // 日期网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) => _buildDayCell(days[index]),
          ),
        ],
      ),
    );
  }
}
