import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/pages/home/widgets/tag.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({super.key, required this.todo});
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 200.w,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.title,
              style: const TextStyle(
                color: Color.fromRGBO(26, 21, 84, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10.w,
            ),
            SizedBox(
              height: 30.w,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...todo.tags.sublist(0, todo.tags.length > 3 ? 3 : null).map(
                        (e) => Padding(
                          padding: EdgeInsets.only(right: 15.w),
                          child: Tag(tag: e, color: Colors.blueAccent),
                        ),
                      ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.w),
              child: const Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.playlist_add_check_outlined,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      "4/5",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_sharp,
                      size: 30.w,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      "2023.08.20",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
