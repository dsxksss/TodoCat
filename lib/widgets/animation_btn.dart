import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class AnimationBtn extends StatelessWidget {
  AnimationBtn({
    super.key,
    required Widget child,
    Function? onPressed,
    double? onHoverScale,
    double? onClickScale,
    Color? hoverBgColor,
    Duration? hoverScaleDuration,
    Duration? clickScaleDuration,
    Duration? bgColorChangeDuration,
    Duration? disableAnimatDuration,
    bool disable = false,
    bool onHoverAnimationEnabled = true,
    bool onHoverBgColorChangeEnabled = false,
    bool onClickAnimationEnabled = true,
  })  : _hoverBgColor = hoverBgColor,
        _onClickAnimationEnabled = onClickAnimationEnabled,
        _clickScaleDuration = clickScaleDuration,
        _onClickScale = onClickScale,
        _onHoverBgColorChangeEnabled = onHoverBgColorChangeEnabled,
        _onHoverAnimationEnabled = onHoverAnimationEnabled,
        _disableAnimatDuration = disableAnimatDuration,
        _bgColorChangeDuration = bgColorChangeDuration,
        _hoverScaleDuration = hoverScaleDuration,
        _onHoverScale = onHoverScale,
        _disable = disable,
        _onPressed = onPressed,
        _child = child;

  final Widget _child;
  final Function? _onPressed;
  final bool _disable;

  final double? _onHoverScale;
  final Duration? _hoverScaleDuration;
  final Duration? _bgColorChangeDuration;
  final Duration? _disableAnimatDuration;
  final bool _onHoverAnimationEnabled;
  final bool _onHoverBgColorChangeEnabled;

  final double? _onClickScale;
  final Duration? _clickScaleDuration;
  final bool _onClickAnimationEnabled;

  final Color? _hoverBgColor;

  final Duration _defaultDuration = 150.ms;
  final _onHover = false.obs;
  final _onHoverbgColorChange = false.obs;
  final _onClick = false.obs;
  final _onClickDisableAnimat = false.obs;

  void _playHoverAnimation() {
    if (!Platform.isAndroid || !Platform.isIOS) {
      if (_onHoverAnimationEnabled) _onHover.value = true;
      if (_onHoverBgColorChangeEnabled) _onHoverbgColorChange.value = true;
    }
  }

  void _playDisableAnimation() async {
    _onClickDisableAnimat.value = true;
    await Future.delayed(
      _defaultDuration + 120.ms,
      () => _onClickDisableAnimat.value = false,
    );
  }

  void _playClickAnimation() {
    if (_onClickAnimationEnabled) _onClick.value = true;
  }

  void _closeAllAnimation() {
    _onHover.value = false;
    _onHoverbgColorChange.value = false;
    _onClick.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        _playHoverAnimation();
      },
      onExit: (_) {
        _closeAllAnimation();
      },
      child: GestureDetector(
        onTap: () async {
          if (!_disable) {
            _playClickAnimation();
            await Future.delayed(
                (_clickScaleDuration ?? _defaultDuration) - 50.ms);
            _closeAllAnimation();
            if (_onPressed != null) _onPressed!();
          } else {
            _playDisableAnimation();
          }
        },
        onLongPressDown: (_) {
          if (!_disable) {
            _playClickAnimation();
          }
        },
        onLongPressUp: () {
          _closeAllAnimation();
          if (_onPressed != null && !_disable) _onPressed!();
        },
        child: Obx(
          () => _child
              // Hover animation
              .animate(target: _onHover.value ? 1 : 0)
              .scaleXY(
                end: _onHoverScale ?? 1.05,
                duration: _hoverScaleDuration ?? _defaultDuration,
                curve: Curves.easeIn,
              )
              .animate(target: _onHoverbgColorChange.value ? 1 : 0)
              .tint(
                color: _hoverBgColor ?? Colors.grey.shade500,
                duration: _bgColorChangeDuration ?? _defaultDuration,
              )
              // Click animation
              .animate(target: _onClick.value ? 1 : 0)
              .scaleXY(
                end: _onClickScale ?? 0.9,
                duration: _clickScaleDuration ?? _defaultDuration,
                curve: Curves.easeOut,
              )
              .animate(target: _onClickDisableAnimat.value ? 1 : 0)
              .tint(
                color: Colors.red.withOpacity(0.9),
                duration: _disableAnimatDuration ?? _defaultDuration,
              )
              .shakeX(
                hz: 4,
                amount: 2,
                duration: _disableAnimatDuration ?? _defaultDuration,
              ),
        ),
      ),
    );
  }
}
