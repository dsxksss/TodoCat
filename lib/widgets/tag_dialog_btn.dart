import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_cat/widgets/label_btn.dart';

class TagDialogBtn extends StatelessWidget {
  const TagDialogBtn({
    super.key,
    required Widget title,
    required Widget icon,
    EdgeInsets? margin,
  })  : _margin = margin,
        _title = title,
        _icon = icon;

  final Widget _title;
  final Widget _icon;
  final EdgeInsets? _margin;

  @override
  Widget build(BuildContext context) {
    return LabelBtn(
      interval: 5,
      margin: _margin,
      reverse: true,
      onClickScale: 0.97,
      onHoverAnimationEnabled: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ghostStyle: true,
      label: _title,
      icon: _icon,
    );
  }
}
