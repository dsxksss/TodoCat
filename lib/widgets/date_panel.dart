import 'package:flutter/material.dart';

class DatePanel extends StatelessWidget {
  const DatePanel({
    super.key,
    required this.onDateSelected,
    this.selectedDate,
  });

  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.lightBlue,
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
      ),
      child: CalendarDatePicker(
        initialDate: selectedDate ?? now,
        currentDate: now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
        onDateChanged: (date) {
          final currentTime = TimeOfDay.now();
          final selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            currentTime.hour,
            currentTime.minute,
          );
          onDateSelected(selectedDateTime);
        },
        selectableDayPredicate: (date) => true,
      ),
    );
  }
}
