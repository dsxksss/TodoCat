import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/widgets/app_date_picker_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DatePickerBtn extends StatelessWidget {
  const DatePickerBtn({
    super.key,
    String? Function(String?)? validator,
    required String fieldTitle,
    required RxString text,
    required RxInt value,
  })  : _fieldTitle = fieldTitle,
        _value = value,
        _text = text;

  final RxString _text;
  final RxInt _value;
  final String _fieldTitle;

  @override
  Widget build(BuildContext context) {
    _text.value = _fieldTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                margin: const EdgeInsets.only(left: 2),
                decoration: BoxDecoration(
                  color: context.theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Obx(
                      () => Text(
                        _text.value,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            AnimationBtn(
              onPressed: _showDatePickerDialog,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(FontAwesomeIcons.clock),
              ),
            ),
            AnimationBtn(
              onPressed: () {
                _text.value = _fieldTitle;
                _value.value = 0;
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(FontAwesomeIcons.arrowRotateLeft),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void _showDatePickerDialog() {
  Get.generalDialog(
    barrierLabel: "showAddTodoDialog",
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: 250.ms,
    pageBuilder: (_, __, ___) {
      return GestureDetector(child: const TodoCatDatePickerDialog());
    },
  );
}
