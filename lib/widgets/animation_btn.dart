import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class AnimationBtn extends StatelessWidget {
  AnimationBtn({
    super.key,
    required this.child,
    this.onPressed,
    this.onHoverScale,
    this.onClickScale,
    this.hoverBgColor,
    this.hoverScaleDuration,
    this.clickScaleDuration,
    this.bgColorChangeDuration,
    this.onHoverAnimationEnabled = true,
    this.onHoverBgColorChangeEnabled = false,
    this.onClickAnimationEnabled = true,
  });

  final Widget child;
  final Function? onPressed;

  final double? onHoverScale;
  final Duration? hoverScaleDuration;
  final Duration? bgColorChangeDuration;
  final bool onHoverAnimationEnabled;
  final bool onHoverBgColorChangeEnabled;

  final double? onClickScale;
  final Duration? clickScaleDuration;
  final bool onClickAnimationEnabled;

  final Color? hoverBgColor;

  final Duration defaultDuration = 150.ms;
  final onHover = false.obs;
  final onHoverbgColorChange = false.obs;
  final onClick = false.obs;
  final isAnimating = false.obs;

  void playHoverAnimation() {
    if (onHoverAnimationEnabled) onHover.value = true;
    if (onHoverBgColorChangeEnabled) onHoverbgColorChange.value = true;
  }

  void playClickAnimation() {
    if (onClickAnimationEnabled) onClick.value = true;
  }

  void closeAllAnimation() {
    onHover.value = false;
    onHoverbgColorChange.value = false;
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
          await Future.delayed((clickScaleDuration ?? defaultDuration) - 50.ms);
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
          () => child
              // Hover animation
              .animate(target: onHover.value ? 1 : 0)
              .scaleXY(
                end: onHoverScale ?? 1.05,
                duration: hoverScaleDuration ?? defaultDuration,
                curve: Curves.easeIn,
              )
              .animate(target: onHoverbgColorChange.value ? 1 : 0)
              .tint(
                color: hoverBgColor ?? Colors.grey.shade500,
                duration: bgColorChangeDuration ?? defaultDuration,
              )
              // Click animation
              .animate(target: onClick.value ? 1 : 0)
              .scaleXY(
                end: onClickScale ?? 0.9,
                duration: clickScaleDuration ?? defaultDuration,
                curve: Curves.easeOut,
              ),
        ),
      ),
    );
  }
}
