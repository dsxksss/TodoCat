import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/home_ctr.dart';

class TimePanel extends StatelessWidget {
  TimePanel({super.key});

  final DatePickerController _ctrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter(
                      RegExp(r'^([0-9]|[0-1][0-9]|2[0-4])$'),
                      allow: true,
                    ),
                  ],
                  maxLength: 2,
                  controller: _ctrl.hEditingController,
                  onChanged: (value) {
                    int? page = int.tryParse(value);
                    if (page == null) {
                      return;
                    }
                    if (page <= 24 || page >= 0) {
                      _ctrl.changeDate(hour: page);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true, // 是否填充背景色
                    border: InputBorder.none,
                    counter: const Text(""),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    hintText: "0",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter(
                      RegExp(r'^([0-9]|[1-5][0-9]|60?)$'),
                      allow: true,
                    ),
                  ],
                  maxLength: 2,
                  controller: _ctrl.mEditingController,
                  onChanged: (value) {
                    int? page = int.tryParse(value);
                    if (page == null) {
                      return;
                    }
                    if (page <= 60 || page >= 0) {
                      _ctrl.changeDate(minute: page);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true, // 是否填充背景色
                    border: InputBorder.none,
                    counter: const Text(""),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    hintText: "0",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
