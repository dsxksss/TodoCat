import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
class AnimationBtn extends StatefulWidget {
  const AnimationBtn({
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

  @override
  State<AnimationBtn> createState() => _AnimationBtnState();
}

class _AnimationBtnState extends State<AnimationBtn> {
  final Duration _defaultDuration = 150.ms;
  bool _onHover = false;
  bool _onHoverbgColorChange = false;
  bool _onClick = false;
  bool _onClickDisableAnimat = false;

  /// 播放悬停动画
  void _playHoverAnimation() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      if (widget.onHoverAnimationEnabled) {
        setState(() => _onHover = true);
      }
      if (widget.onHoverBgColorChangeEnabled) {
        setState(() => _onHoverbgColorChange = true);
      }
    }
  }

  /// 播放禁用动画
  void _playDisableAnimation() async {
    setState(() => _onClickDisableAnimat = true);
    await Future.delayed(_defaultDuration + 120.ms);
    if (mounted) {
      setState(() => _onClickDisableAnimat = false);
    }
  }

  /// 播放点击动画
  void _playClickAnimation() {
    if (widget.onClickAnimationEnabled) {
      setState(() => _onClick = true);
    }
  }

  /// 关闭所有动画
  void _closeAllAnimation() {
    if (!mounted) return;
    setState(() {
      _onHover = false;
      _onHoverbgColorChange = false;
      _onClick = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _playHoverAnimation(),
      onExit: (_) => _closeAllAnimation(),
      child: GestureDetector(
        // 使用 opaque 行为，确保整个区域（包括边缘）都可以响应点击
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (!widget.disable) {
            _playClickAnimation();
            await Future.delayed(
                (widget.clickScaleDuration ?? _defaultDuration) - 50.ms);
            _closeAllAnimation();
            widget.onPressed();
          } else {
            _playDisableAnimation();
          }
        },
        onLongPressDown: (_) async {
          if (!widget.disable) {
            _playClickAnimation();
            await Future.delayed(const Duration(seconds: 1));
            _closeAllAnimation();
          }
        },
        onLongPressUp: () {
          _closeAllAnimation();
          if (!widget.disable) widget.onPressed();
        },
        child: widget.child
            // 悬停动画
            .animate(target: _onHover ? 1 : 0)
            .scaleXY(
              end: widget.onHoverScale,
              duration: widget.hoverScaleDuration ?? _defaultDuration,
              curve: Curves.easeIn,
            )
            .animate(target: _onHoverbgColorChange ? 1 : 0)
            .tint(
              color: widget.hoverBgColor ?? Colors.grey.shade500,
              duration: widget.bgColorChangeDuration ?? _defaultDuration,
            )
            // 点击动画
            .animate(target: _onClick ? 1 : 0)
            .scaleXY(
              end: widget.onClickScale,
              duration: widget.clickScaleDuration ?? _defaultDuration,
              curve: Curves.easeOut,
            )
            .animate(target: _onClickDisableAnimat ? 1 : 0)
            .tint(
              color: Colors.red.withValues(alpha: 0.9),
              duration: widget.disableAnimatDuration ?? _defaultDuration,
            )
            .shakeX(
              hz: 4,
              amount: 2,
              duration: widget.disableAnimatDuration ?? _defaultDuration,
            ),
      ),
    );
  }
}
