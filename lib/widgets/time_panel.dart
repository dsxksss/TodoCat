import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:async';

class TimePanel extends StatefulWidget {
  const TimePanel({
    super.key,
    required this.onTimeSelected,
    this.initialTime,
  });

  final Function(TimeOfDay) onTimeSelected;
  final TimeOfDay? initialTime;

  @override
  State<TimePanel> createState() => TimePanelState();
}

class TimePanelState extends State<TimePanel> {
  late bool isAM;
  late int selectedHour;
  late int selectedMinute;
  double _dragStartY = 0;
  int _dragStartValue = 0;
  bool _isInitialized = false;
  Timer? _debounceTimer; // 防抖计时器

  late final FixedExtentScrollController _amPmController;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    isAM = true;
    selectedHour = 11;
    selectedMinute = 0;
    _initializeTime();
    _initializeControllers();
  }

  void _initializeControllers() {
    _amPmController = FixedExtentScrollController(initialItem: isAM ? 0 : 1);
    _hourController = FixedExtentScrollController(initialItem: selectedHour);
    _minuteController =
        FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _amPmController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTime != oldWidget.initialTime) {
      final oldHour = selectedHour;
      final oldMinute = selectedMinute;
      final oldIsAM = isAM;

      _initializeTime();

      if (oldHour != selectedHour ||
          oldMinute != selectedMinute ||
          oldIsAM != isAM) {
        _updateControllers();
      }
    }
  }

  void _updateControllers() {
    _amPmController.jumpToItem(isAM ? 0 : 1);
    _hourController.jumpToItem(selectedHour);
    _minuteController.jumpToItem(selectedMinute);
  }

  void _initializeTime() {
    if (widget.initialTime != null) {
      final hour = widget.initialTime!.hour;
      isAM = hour < 12;
      if (isAM) {
        selectedHour = hour == 0 ? 11 : hour - 1;
      } else {
        selectedHour = hour == 12 ? 11 : hour - 13;
      }
      selectedMinute = widget.initialTime!.minute;
    } else {
      if (!_isInitialized) {
        final now = TimeOfDay.now();
        final hour = now.hour;
        isAM = hour < 12;
        if (isAM) {
          selectedHour = hour == 0 ? 11 : hour - 1;
        } else {
          selectedHour = hour == 12 ? 11 : hour - 13;
        }
        selectedMinute = now.minute;
        _isInitialized = true;
      }
    }
  }

  void updateToTime(TimeOfDay time) {
    setState(() {
      final hour = time.hour;
      isAM = hour < 12;
      if (isAM) {
        selectedHour = hour == 0 ? 11 : hour - 1;
      } else {
        selectedHour = hour == 12 ? 11 : hour - 13;
      }
      selectedMinute = time.minute;
      _updateControllers();
    });
  }

  void _updateTime() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final hour = isAM
          ? (selectedHour == 11 ? 0 : selectedHour + 1)
          : (selectedHour == 11 ? 12 : selectedHour + 13);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTimeSelected(TimeOfDay(hour: hour, minute: selectedMinute));
      });
    });
  }

  Widget _buildPickerWithDrag({
    required Widget picker,
    required Function(int) onValueChanged,
    required int currentValue,
    required int maxValue,
    required FixedExtentScrollController controller,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        onVerticalDragStart: (details) {
          _dragStartY = details.localPosition.dy;
          _dragStartValue = currentValue;
        },
        onVerticalDragUpdate: (details) {
          final deltaY = details.localPosition.dy - _dragStartY;
          const sensitivity = 20.0;
          final deltaValue = (deltaY / sensitivity).round();
          var newValue = _dragStartValue - deltaValue;
          newValue = newValue.clamp(0, maxValue - 1);

          controller.jumpToItem(newValue);
          onValueChanged(newValue);
        },
        child: picker,
      ),
    );
  }

  void resetTime() {
    setState(() {
      isAM = true;
      selectedHour = 11;
      selectedMinute = 0;
      _updateControllers();
    });
  }

  void fullReset() {
    setState(() {
      isAM = true;
      selectedHour = 11;
      selectedMinute = 0;
      _updateControllers();
      widget.onTimeSelected(const TimeOfDay(hour: 0, minute: 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // AM/PM 选择器
          Expanded(
            child: _buildPickerWithDrag(
              picker: CupertinoPicker(
                backgroundColor: context.theme.dialogTheme.backgroundColor,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Colors.grey.withValues(alpha:0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                magnification: 1.0,
                squeeze: 1.2,
                useMagnifier: false,
                itemExtent: 32,
                scrollController: _amPmController,
                onSelectedItemChanged: (index) {
                  setState(() {
                    isAM = index == 0;
                    _updateTime();
                  });
                },
                children: ['AM', 'PM']
                    .map((e) => Center(
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              onValueChanged: (value) {
                setState(() {
                  isAM = value == 0;
                  _updateTime();
                });
              },
              currentValue: isAM ? 0 : 1,
              maxValue: 2,
              controller: _amPmController,
            ),
          ),
          // 小时选择器
          Expanded(
            child: _buildPickerWithDrag(
              picker: CupertinoPicker(
                backgroundColor: context.theme.dialogTheme.backgroundColor,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Colors.grey.withValues(alpha:0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                magnification: 1.0,
                squeeze: 1.2,
                useMagnifier: false,
                itemExtent: 32,
                scrollController: _hourController,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedHour = index;
                    _updateTime();
                  });
                },
                children: List.generate(
                  12,
                  (index) => Center(
                    child: Text(
                      '${(index + 1)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              ),
              onValueChanged: (value) {
                setState(() {
                  selectedHour = value;
                  _updateTime();
                });
              },
              currentValue: selectedHour,
              maxValue: 12,
              controller: _hourController,
            ),
          ),
          // 分钟选择器
          Expanded(
            child: _buildPickerWithDrag(
              picker: CupertinoPicker(
                backgroundColor: context.theme.dialogTheme.backgroundColor,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Colors.grey.withValues(alpha:0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                magnification: 1.0,
                squeeze: 1.2,
                useMagnifier: false,
                itemExtent: 32,
                scrollController: _minuteController,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedMinute = index;
                    _updateTime();
                  });
                },
                children: List.generate(
                    60,
                    (index) => Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        )),
              ),
              onValueChanged: (value) {
                setState(() {
                  selectedMinute = value;
                  _updateTime();
                });
              },
              currentValue: selectedMinute,
              maxValue: 60,
              controller: _minuteController,
            ),
          ),
        ],
      ),
    );
  }
}
