import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/controller.dart';

class SelectPriorityBotton extends StatelessWidget {
  SelectPriorityBotton({
    super.key,
    required this.fieldTitle,
    this.validator,
  });
  final HomeController ctrl = Get.find();

  final String fieldTitle;
  final String? Function(String?)? validator;

  final List<TodoPriority> priorityItems = [
    TodoPriority.highLevel,
    TodoPriority.mediumLevel,
    TodoPriority.lowLevel,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            fieldTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DropdownButtonFormField2<String>(
          value: ctrl.selectedPriority.value.name,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true, // 是否填充背景色
            fillColor: const Color.fromRGBO(248, 250, 251, 1),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          hint: const Text(
            'Select Your Priority',
            style: TextStyle(fontSize: 14),
          ),
          items: priorityItems
              .map((item) => DropdownMenuItem(
                    value: item.name,
                    child: Text(
                      item.name.tr,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          validator: validator ??
              (value) {
                if (value == null) {
                  return '请选择选项';
                }
                return null;
              },
          onChanged: (value) {
            //Do something when selected item is changed.
          },
          onSaved: (value) {
            ctrl.selectedPriority.value = value as TodoPriority;
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.only(right: 8),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.black45,
            ),
            iconSize: 24,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
