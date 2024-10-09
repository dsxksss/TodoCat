import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

/// AnimationBtn 是一个自定义的 Flutter 按钮组件，支持多种动画效果。
///
/// [child] 是按钮的子组件。
/// [onPressed] 是按钮点击时的回调函数。
/// [onHoverScale] 是鼠标悬停时的缩放比例。
/// [onClickScale] 是点击时的缩放比例。
/// [hoverBgColor] 是鼠标悬停时的背景颜色。
/// [hoverScaleDuration] 是鼠标悬停时的缩放动画持续时间。
/// [clickScaleDuration] 是点击时的缩放动画持续时间。
/// [bgColorChangeDuration] 是背景颜色变化的动画持续时间。
/// [disableAnimatDuration] 是禁用动画的持续时间。
/// [disable] 是按钮是否禁用。
/// [onHoverAnimationEnabled] 是是否启用悬停动画。
/// [onHoverBgColorChangeEnabled] 是是否启用悬停背景颜色变化动画。
/// [onClickAnimationEnabled] 是是否启用点击动画。
class AnimationBtn extends StatelessWidget {
  AnimationBtn({
    super.key,
    required this.child,
    required this.onPressed,
    this.onHoverScale = 1.05,
    this.onClickScale = 0.9,
    this.hoverBgColor,
    this.hoverScaleDuration,
    this.clickScaleDuration,
    this.bgColorChangeDuration,
    this.disableAnimatDuration,
    this.disable = false,
    this.onHoverAnimationEnabled = true,
    this.onHoverBgColorChangeEnabled = false,
    this.onClickAnimationEnabled = true,
  });

  final Widget child;
  final VoidCallback onPressed;
  final bool disable;

  final double onHoverScale;
  final Duration? hoverScaleDuration;
  final Duration? bgColorChangeDuration;
  final Duration? disableAnimatDuration;
  final bool onHoverAnimationEnabled;
  final bool onHoverBgColorChangeEnabled;

  final double onClickScale;
  final Duration? clickScaleDuration;
  final bool onClickAnimationEnabled;

  final Color? hoverBgColor;

  final Duration _defaultDuration = 150.ms;
  final _onHover = false.obs;
  final _onHoverbgColorChange = false.obs;
  final _onClick = false.obs;
  final _onClickDisableAnimat = false.obs;

  /// 播放悬停动画
  void _playHoverAnimation() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      if (onHoverAnimationEnabled) _onHover.value = true;
      if (onHoverBgColorChangeEnabled) _onHoverbgColorChange.value = true;
    }
  }

  /// 播放禁用动画
  void _playDisableAnimation() async {
    _onClickDisableAnimat.value = true;
    await (_defaultDuration + 120.ms)
        .delay(() => _onClickDisableAnimat.value = false);
  }

  /// 播放点击动画
  void _playClickAnimation() {
    if (onClickAnimationEnabled) _onClick.value = true;
  }

  /// 关闭所有动画
  void _closeAllAnimation() {
    _onHover.value = false;
    _onHoverbgColorChange.value = false;
    _onClick.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _playHoverAnimation(),
      onExit: (_) => _closeAllAnimation(),
      child: GestureDetector(
        onTap: () async {
          if (!disable) {
            _playClickAnimation();
            await ((clickScaleDuration ?? _defaultDuration) - 50.ms).delay();
            _closeAllAnimation();
            onPressed();
          } else {
            _playDisableAnimation();
          }
        },
        onLongPressDown: (_) async {
          if (!disable) {
            _playClickAnimation();
            await 1.delay(_closeAllAnimation);
          }
        },
        onLongPressUp: () {
          _closeAllAnimation();
          if (!disable) onPressed();
        },
        child: Obx(
          () => child
              // 悬停动画
              .animate(target: _onHover.value ? 1 : 0)
              .scaleXY(
                end: onHoverScale,
                duration: hoverScaleDuration ?? _defaultDuration,
                curve: Curves.easeIn,
              )
              .animate(target: _onHoverbgColorChange.value ? 1 : 0)
              .tint(
                color: hoverBgColor ?? Colors.grey.shade500,
                duration: bgColorChangeDuration ?? _defaultDuration,
              )
              // 点击动画
              .animate(target: _onClick.value ? 1 : 0)
              .scaleXY(
                end: onClickScale,
                duration: clickScaleDuration ?? _defaultDuration,
                curve: Curves.easeOut,
              )
              .animate(target: _onClickDisableAnimat.value ? 1 : 0)
              .tint(
                color: Colors.red.withOpacity(0.9),
                duration: disableAnimatDuration ?? _defaultDuration,
              )
              .shakeX(
                hz: 4,
                amount: 2,
                duration: disableAnimatDuration ?? _defaultDuration,
              ),
        ),
      ),
    );
  }
}
