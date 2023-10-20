import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/label_btn.dart';

class TagDialogBtn extends StatelessWidget {
  const TagDialogBtn({
    super.key,
    String? title,
    Widget? titleWidget,
    Widget? openDialog,
    required String tag,
    required Widget? icon,
    TextStyle? titleStyle,
    EdgeInsets? margin,
  })  : _margin = margin,
        _tag = tag,
        _title = title ?? "",
        _titleStyle = titleStyle,
        _titleWidget = titleWidget,
        _openDialog = openDialog,
        _icon = icon;

  final String _tag;
  final String _title;
  final Widget? _openDialog;
  final TextStyle? _titleStyle;
  final Widget? _titleWidget;
  final Widget? _icon;
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
      label: _titleWidget ??
          Text(
            _title,
            style: _titleStyle,
          ),
      icon: _icon,
      onPressed: () {
        if (_openDialog != null) {
          SmartDialog.show(
            tag: _tag,
            useSystem: false,
            debounce: true,
            keepSingle: true,
            backDismiss: false,
            animationTime: 150.ms,
            builder: (context) =>
                _openDialog ?? const Text("open unknow dialog!!!"),
            animationBuilder: (controller, child, _) => child
                .animate(controller: controller)
                .fade(duration: controller.duration)
                .scaleXY(
                  begin: 0.99,
                  duration: controller.duration,
                  curve: Curves.easeOutCubic,
                ),
          );
        }
      },
    );
  }
}
