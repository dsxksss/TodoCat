import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Tag extends StatelessWidget {
  const Tag({super.key, required this.tag, required this.color});
  final String tag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(
          8.r,
        ),
      ),
      child: Center(
        child: Text(
          tag,
          style: TextStyle(
              color: color, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
