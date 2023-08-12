import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/core/utils/extensions.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/pages/home/controller.dart';

class TaskCard extends StatelessWidget {
  TaskCard({super.key, required this.task});
  final HomeController ctrl = Get.find();
  final Task task;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.0.wp),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(
          Radius.circular(2.0.wp),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0.wp, vertical: 0.8.wp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  task.title,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 4.0.sp),
                ),
                IconButton(
                  onPressed: () => {},
                  icon: Icon(
                    Icons.more_horiz,
                    size: 2.5.wp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
