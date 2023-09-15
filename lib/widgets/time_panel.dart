import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/controller.dart';

class TimePanel extends StatelessWidget {
  TimePanel({super.key});

  final DatePickerController _ctrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 350,
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
                      _ctrl.hController.animateToPage(
                        page,
                        duration: 200.ms,
                        curve: Curves.easeInOut,
                      );
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
                      _ctrl.mController.animateToPage(
                        page,
                        duration: 200.ms,
                        curve: Curves.easeInOut,
                      );
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
          Expanded(
            child: Center(
              child: SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 50,
                      child: PageView.builder(
                        itemCount: 24,
                        controller: _ctrl.hController,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (ctx, index) {
                          return Center(
                              child: Text(
                            '$index',
                            style: const TextStyle(fontSize: 25),
                          ));
                        },
                        onPageChanged: (int index) {
                          _ctrl.changeDate(hour: index);
                        },
                      ),
                    ),
                    const Text(
                      ":",
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(
                      width: 50,
                      child: PageView.builder(
                        itemCount: 60,
                        controller: _ctrl.mController,
                        scrollDirection: Axis.vertical,
                        pageSnapping: true,
                        // physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          return Center(
                              child: Text(
                            '$index',
                            style: const TextStyle(fontSize: 25),
                          ));
                        },
                        onPageChanged: (int index) {
                          _ctrl.changeDate(minute: index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
