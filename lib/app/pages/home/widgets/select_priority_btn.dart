import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/pages/home/controller.dart';

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
          padding: EdgeInsets.only(bottom: 10.w),
          child: Text(
            fieldTitle,
            style: TextStyle(
              fontSize: 26.sp,
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
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.w),
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
          menuItemStyleData: MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
          ),
        ),
      ],
    );
  }
}
