import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  const Tag({super.key, required this.tag, required this.color});
  final String tag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(
          4,
        ),
      ),
      child: Center(
        child: Text(
          tag,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
