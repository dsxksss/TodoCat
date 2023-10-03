import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class LabelBtn extends StatelessWidget {
  const LabelBtn({
    super.key,
    required Widget label,
    double? interval,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Widget? icon,
    bool? disable,
    bool? ghostStyle,
    bool? reverse,
    Function? onPressed,
    Color? bgColor,
    Decoration? decoration,
    bool? onHoverAnimationEnabled,
    bool? onClickAnimationEnabled,
    bool? onHoverBgColorChangeEnabled,
    double? onHoverScale,
    double? onClickScale,
    Color? hoverBgColor,
    Duration? hoverScaleDuration,
    Duration? clickScaleDuration,
    Duration? bgColorChangeDuration,
    Duration? disableAnimatDuration,
  })  : _label = label,
        _icon = icon,
        _ghostStyle = ghostStyle ?? false,
        _reverse = reverse ?? false,
        _padding = padding,
        _margin = margin,
        _interval = interval,
        _disableAnimatDuration = disableAnimatDuration,
        _bgColorChangeDuration = bgColorChangeDuration,
        _clickScaleDuration = clickScaleDuration,
        _hoverScaleDuration = hoverScaleDuration,
        _hoverBgColor = hoverBgColor,
        _onClickScale = onClickScale,
        _onHoverScale = onHoverScale,
        _bgColor = bgColor,
        _decoration = decoration,
        _onPressed = onPressed,
        _onHoverAnimationEnabled = onHoverAnimationEnabled,
        _onClickAnimationEnabled = onClickAnimationEnabled,
        _onHoverBgColorChangeEnabled = onHoverBgColorChangeEnabled,
        _disable = disable,
        assert(
          ghostStyle == null || decoration == null,
          "set ghostStyle field,beause you set bgColor!",
        );

  final Widget _label;
  final bool _ghostStyle;
  final bool _reverse;
  final EdgeInsets? _padding;
  final EdgeInsets? _margin;
  final Widget? _icon;
  final Color? _bgColor;
  final Function? _onPressed;
  final Decoration? _decoration;
  final bool? _onHoverAnimationEnabled;
  final bool? _onClickAnimationEnabled;
  final bool? _onHoverBgColorChangeEnabled;
  final double? _onHoverScale;
  final double? _onClickScale;
  final Color? _hoverBgColor;
  final double? _interval;
  final Duration? _hoverScaleDuration;
  final Duration? _clickScaleDuration;
  final Duration? _bgColorChangeDuration;
  final Duration? _disableAnimatDuration;
  final bool? _disable;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onPressed: _onPressed,
      onHoverScale: _onHoverScale,
      onClickScale: _onClickScale,
      disable: _disable ?? false,
      onHoverAnimationEnabled: _onHoverAnimationEnabled ?? true,
      onClickAnimationEnabled: _onClickAnimationEnabled ?? true,
      onHoverBgColorChangeEnabled: _onHoverBgColorChangeEnabled ?? false,
      hoverBgColor: _hoverBgColor,
      hoverScaleDuration: _hoverScaleDuration,
      clickScaleDuration: _clickScaleDuration,
      bgColorChangeDuration: _bgColorChangeDuration,
      disableAnimatDuration: _disableAnimatDuration,
      child: Container(
        padding:
            _padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: _margin,
        decoration: _ghostStyle
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  width: 0.8,
                  color: context.theme.dividerColor,
                ),
              )
            : _decoration ??
                BoxDecoration(
                  color: _bgColor ?? Colors.lightBlue,
                  borderRadius: BorderRadius.circular(5),
                ),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: _reverse
              ? [
                  if (_icon != null) _icon ?? const SizedBox(),
                  if (_icon != null) SizedBox(width: _interval ?? 10),
                  _label,
                ]
              : [
                  _label,
                  if (_icon != null) SizedBox(width: _interval ?? 10),
                  if (_icon != null) _icon ?? const SizedBox(),
                ],
        ),
      ),
    );
  }
}
