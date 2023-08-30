import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class AnimationBtn extends StatelessWidget {
  AnimationBtn({
    super.key,
    required this.child,
    this.onPressed,
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

  final double? onHoverScale;
  final Duration? onHoverDuration;
  final bool onHoverAnimationEnabled;

  final double? onClickScale;
  final Duration? onClickDuration;
  final bool onClickAnimationEnabled;

  final EdgeInsetsGeometry? padding;

  final Duration defaultDuration = 150.ms;
  final onHover = false.obs;
  final onClick = false.obs;
  final isAnimating = false.obs;

  void playHoverAnimation() {
    if (onHoverAnimationEnabled) onHover.value = true;
  }

  void playClickAnimation() {
    if (onClickAnimationEnabled) onClick.value = true;
  }

  void closeAllAnimation() {
    onHover.value = false;
    onClick.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        playHoverAnimation();
      },
      onExit: (_) {
        closeAllAnimation();
      },
      child: GestureDetector(
        onTap: () async {
          playClickAnimation();
          await Future.delayed((onClickDuration ?? defaultDuration) - 50.ms);
          closeAllAnimation();
          if (onPressed != null) onPressed!();
        },
        onLongPressDown: (_) {
          playClickAnimation();
        },
        onLongPressUp: () {
          closeAllAnimation();
          if (onPressed != null) onPressed!();
        },
        child: Obx(
          () => Container(
            padding: padding,
            child: child,
          )
              // Hover animation
              .animate(target: onHover.value ? 1 : 0)
              .scaleXY(
                end: onHoverScale ?? 1.05,
                duration: onHoverDuration ?? defaultDuration,
                curve: Curves.easeIn,
              )
              // Click animation
              .animate(target: onClick.value ? 1 : 0)
              .scaleXY(
                end: onClickScale ?? 0.9,
                duration: onClickDuration ?? defaultDuration,
                curve: Curves.easeOut,
              ),
        ),
      ),
    );
  }
}
