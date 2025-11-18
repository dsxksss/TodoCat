import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

/// LabelBtn 是一个带有标签和可选图标的按钮组件，支持多种动画效果。
///
/// 参数:
/// - [label]: 按钮上的标签组件，必填。
/// - [onPressed]: 按钮点击时触发的回调函数，必填。
/// - [interval]: 标签和图标之间的间距，可选。
/// - [padding]: 按钮的内边距，可选。
/// - [margin]: 按钮的外边距，可选。
/// - [icon]: 按钮上的图标组件，可选。
/// - [disable]: 按钮是否禁用状态，可选。
/// - [ghostStyle]: 是否启用幽灵按钮样式，默认值为 false。
/// - [reverse]: 是否反转标签和图标的位置，默认值为 false。
/// - [bgColor]: 按钮背景颜色，可选。
/// - [decoration]: 按钮的装饰，可选。
/// - [onHoverAnimationEnabled]: 是否启用悬停动画，默认值为 true。
/// - [onClickAnimationEnabled]: 是否启用点击动画，默认值为 true。
/// - [onHoverBgColorChangeEnabled]: 是否启用悬停背景颜色变化，默认值为 false。
/// - [onHoverScale]: 悬停时按钮的缩放比例，可选，默认为 1.05。
/// - [onClickScale]: 点击时按钮的缩放比例，可选，默认为 0.9。
/// - [hoverBgColor]: 悬停时按钮的背景颜色，可选。
/// - [hoverScaleDuration]: 悬停缩放动画的持续时间，可选。
/// - [clickScaleDuration]: 点击缩放动画的持续时间，可选。
/// - [bgColorChangeDuration]: 背景颜色变化动画的持续时间，可选。
/// - [disableAnimatDuration]: 禁用动画的持续时间，可选。
class LabelBtn extends StatelessWidget {
  const LabelBtn({
    super.key,
    required this.label,
    required this.onPressed,
    this.interval,
    this.padding,
    this.margin,
    this.icon,
    this.disable,
    this.ghostStyle = false,
    this.reverse = false,
    this.bgColor,
    this.decoration,
    this.onHoverAnimationEnabled,
    this.onClickAnimationEnabled,
    this.onHoverBgColorChangeEnabled,
    this.onHoverScale,
    this.onClickScale,
    this.hoverBgColor,
    this.hoverScaleDuration,
    this.clickScaleDuration,
    this.bgColorChangeDuration,
    this.disableAnimatDuration,
  });

  // 按钮上的标签组件
  final Widget label;

  // 是否启用幽灵按钮样式，默认值为 false
  final bool ghostStyle;

  // 是否反转标签和图标的位置，默认值为 false
  final bool reverse;

  // 按钮的内边距
  final EdgeInsets? padding;

  // 按钮的外边距
  final EdgeInsets? margin;

  // 按钮上的图标组件
  final Widget? icon;

  // 按钮背景颜色
  final Color? bgColor;

  // 按钮点击时触发的回调函数
  final VoidCallback onPressed;

  // 按钮的装饰
  final Decoration? decoration;

  // 是否启用悬停动画，默认值为 true
  final bool? onHoverAnimationEnabled;

  // 是否启用点击动画，默认值为 true
  final bool? onClickAnimationEnabled;

  // 是否启用悬停背景颜色变化，默认值为 false
  final bool? onHoverBgColorChangeEnabled;

  // 悬停时按钮的缩放比例
  final double? onHoverScale;

  // 点击时按钮的缩放比例
  final double? onClickScale;

  // 悬停时按钮的背景颜色
  final Color? hoverBgColor;

  // 标签和图标之间的间距
  final double? interval;

  // 悬停缩放动画的持续时间
  final Duration? hoverScaleDuration;

  // 点击缩放动画的持续时间
  final Duration? clickScaleDuration;

  // 背景颜色变化动画的持续时间
  final Duration? bgColorChangeDuration;

  // 禁用动画的持续时间
  final Duration? disableAnimatDuration;

  // 按钮是否禁用状态
  final bool? disable;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onPressed: onPressed,
      onHoverScale: onHoverScale ?? 1.05,
      onClickScale: onClickScale ?? 0.9,
      disable: disable ?? false,
      onHoverAnimationEnabled: onHoverAnimationEnabled ?? true,
      onClickAnimationEnabled: onClickAnimationEnabled ?? true,
      onHoverBgColorChangeEnabled: onHoverBgColorChangeEnabled ?? false,
      hoverBgColor: hoverBgColor,
      hoverScaleDuration: hoverScaleDuration,
      clickScaleDuration: clickScaleDuration,
      bgColorChangeDuration: bgColorChangeDuration,
      disableAnimatDuration: disableAnimatDuration,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: margin,
        decoration: ghostStyle
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  width: 0.8,
                  color: context.theme.dividerColor,
                ),
              )
            : decoration ??
                BoxDecoration(
                  color: bgColor ?? Colors.blue.shade700, // 统一使用蓝色，与指示气泡一致
                  borderRadius: BorderRadius.circular(5),
                ),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: reverse
              ? [
                  if (icon != null) icon ?? const SizedBox(),
                  if (icon != null) SizedBox(width: interval ?? 10),
                  label,
                ]
              : [
                  label,
                  if (icon != null) SizedBox(width: interval ?? 10),
                  if (icon != null) icon ?? const SizedBox(),
                ],
        ),
      ),
    );
  }
}
