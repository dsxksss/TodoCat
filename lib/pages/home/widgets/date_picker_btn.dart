import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/widgets/app_date_picker_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DatePickerBtn extends StatelessWidget {
  const DatePickerBtn({
    super.key,
    this.validator,
    required this.fieldTitle,
    required this.text,
    required this.value,
  });

  final String fieldTitle;
  final RxString text;
  final RxInt value;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(fieldTitle),
        ),
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
                        text.value,
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
              onPressed: () {
                text.value = "${"enter".tr}${"time".tr}";
                value.value = 0;
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Text(
                      "clear".tr,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      FontAwesomeIcons.trashCan,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            AnimationBtn(
              onPressed: () => showDatePickerDialog(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Text(
                      "selectReminderTime".tr,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      FontAwesomeIcons.clock,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void showDatePickerDialog() {
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
