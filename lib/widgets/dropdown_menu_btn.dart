import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DropdownManuBtn extends StatelessWidget {
  const DropdownManuBtn({
    super.key,
    required this.child,
    required this.content,
    this.controller,
    required this.id,
    this.onDismiss,
    this.disable = false,
  });

  final String id;
  final Widget child;
  final Widget content;
  final bool disable;
  final SmartDialogController? controller;
  final void Function()? onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onClickScale: 0.8,
      disable: disable,
      clickScaleDuration: 100.ms,
      onHoverAnimationEnabled: false,
      onPressed: () {
        SmartDialog.showAttach(
          onDismiss: onDismiss,
          tag: id,
          targetContext: context,
          debounce: true,
          keepSingle: true,
          usePenetrate: true,
          animationTime: 100.ms,
          controller: controller,
          alignment: Alignment.bottomRight,
          animationBuilder: (controller, child, animationParam) => child
              .animate(controller: controller)
              .fade(duration: controller.duration)
              .scaleXY(
                begin: 0.9,
                end: 1,
                curve: Curves.easeInOut,
                duration: controller.duration,
              ),
          builder: (_) => content,
        );
      },
      child: child,
    );
  }
}
