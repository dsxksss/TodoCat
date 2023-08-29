import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class AnimationBtn extends StatelessWidget {
  AnimationBtn({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPressed,
    this.padding,
    this.onHoverScale,
    this.onClickScale,
    this.onHoverDuration,
    this.onClickDuration,
    this.onHoverAnimationEnabled = true,
    this.onClickAnimationEnabled = true,
  });

  final Widget child;
  final Function? onPressed;
  final Function? onLongPressed;

  final double? onHoverScale;
  final Duration? onHoverDuration;
  final bool onHoverAnimationEnabled;

  final double? onClickScale;
  final Duration? onClickDuration;
  final bool onClickAnimationEnabled;

  final EdgeInsetsGeometry? padding;

  final onHover = false.obs;
  final onClick = false.obs;

  void playHoverAnimation() {
    if (onHoverAnimationEnabled) onHover.value = true;
  }

  void playClickAnimation() async {
    if (onClickAnimationEnabled) onClick.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) {
        playHoverAnimation();
      },
      onExit: (_) {
        onHover.value = false;
        onClick.value = false;
      },
      child: GestureDetector(
        onTap: () async {
          playClickAnimation();
          await Future.delayed(onClickDuration ?? 150.ms);

          onClick.value = false;
          onHover.value = false;
          if (onPressed != null) onPressed!();
        },
        onLongPressDown: (_) {
          playClickAnimation();
        },
        onLongPressUp: () {
          onClick.value = false;
          onHover.value = false;
          if (onLongPressed != null) onLongPressed!();
        },
        child: Obx(
          () => Animate(
            child: Container(
              padding: padding,
              child: child,
            )
                .animate(target: onHover.value ? 1 : 0)
                .scaleXY(
                  end: onHoverScale ?? 1.05,
                  duration: onHoverDuration ?? 150.ms,
                  curve: Curves.easeInOutQuad,
                )
                .animate(target: onClick.value ? 1 : 0)
                .scaleXY(
                  end: onClickScale ?? 0.9,
                  duration: onClickDuration ?? 150.ms,
                  curve: Curves.easeInOutQuad,
                ),
          ),
        ),
      ),
    );
  }
}
