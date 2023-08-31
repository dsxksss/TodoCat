import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/pages/home/widgets/tag.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({super.key, required this.todo});
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 23.sp,
              ),
            ),
            if (todo.tags.isNotEmpty)
              SizedBox(
                height: 10.w,
              ),
            if (todo.tags.isNotEmpty)
              SizedBox(
                height: 30.w,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...todo.tags
                        .sublist(0, todo.tags.length > 3 ? 3 : null)
                        .map(
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
            ),
            SizedBox(
              height: 20.w,
            )
          ],
        ),
      ),
    );
  }
}