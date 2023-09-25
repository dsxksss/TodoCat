import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SelectPriorityPanel extends StatelessWidget {
  const SelectPriorityPanel({
    super.key,
    required List<Widget> tabs,
    required String titile,
    void Function(int)? onTap,
  })  : _onTap = onTap,
        _titile = titile,
        _tabs = tabs;

  final List<Widget> _tabs;
  final String _titile;
  final void Function(int)? _onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_titile),
        const SizedBox(
          height: 5,
        ),
        DefaultTabController(
          length: _tabs.length,
          animationDuration: 400.ms,
          child: TabBar(
            onTap: _onTap,
            indicatorColor: Colors.lightBlue,
            unselectedLabelColor: const Color.fromARGB(199, 117, 117, 117),
            tabs: _tabs,
          ),
        ),
      ],
    );
  }
}
