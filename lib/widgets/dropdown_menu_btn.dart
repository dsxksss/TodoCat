import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class DropdownManuBtn extends StatelessWidget {
  const DropdownManuBtn({
    super.key,
    required Widget child,
    required Widget content,
    SmartDialogController? controller,
    required String id,
    void Function()? onDismiss,
    bool disable = false,
  })  : _onDismiss = onDismiss,
        _controller = controller,
        _disable = disable,
        _content = content,
        _child = child,
        _id = id;

  final String _id;
  final Widget _child;
  final Widget _content;
  final bool _disable;
  final SmartDialogController? _controller;
  final void Function()? _onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onClickScale: 0.8,
      disable: _disable,
      clickScaleDuration: 100.ms,
      onHoverAnimationEnabled: false,
      onPressed: () {
        SmartDialog.showAttach(
          onDismiss: _onDismiss,
          tag: _id,
          targetContext: context,
          debounce: true,
          keepSingle: true,
          usePenetrate: true,
          animationTime: 100.ms,
          controller: _controller,
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
          builder: (_) => _content,
        );
      },
      child: _child,
    );
  }
}
