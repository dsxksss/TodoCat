import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SelectPriorityPanel extends StatelessWidget {
  const SelectPriorityPanel({
    super.key,
    required this.tabs,
    required this.titile,
    this.onTap,
  });

  final List<Widget> tabs;
  final String titile;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titile),
        const SizedBox(
          height: 5,
        ),
        DefaultTabController(
          length: tabs.length,
          animationDuration: 400.ms,
          child: TabBar(
            onTap: onTap,
            indicatorColor: Colors.lightBlue,
            unselectedLabelColor: const Color.fromARGB(199, 117, 117, 117),
            tabs: tabs,
          ),
        ),
      ],
    );
  }
}
