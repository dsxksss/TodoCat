import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

enum TodoCatToastStyleType {
  info,
  success,
  error,
  warning,
}

List getIconData(TodoCatToastStyleType type) {
  switch (type) {
    case TodoCatToastStyleType.success:
      return [FontAwesomeIcons.circleCheck, Colors.greenAccent];
    case TodoCatToastStyleType.warning:
      return [FontAwesomeIcons.triangleExclamation, Colors.orangeAccent];
    case TodoCatToastStyleType.error:
      return [FontAwesomeIcons.circleExclamation, Colors.redAccent];
    default:
      return [FontAwesomeIcons.circleInfo, Colors.blueAccent];
  }
}

void showToast(
  String message, {
  Duration? displayTime,
  Duration? animationTime,
  AlignmentGeometry? alignment,
  bool fadeAnimation = false,
  Widget Function(BuildContext)? builder,
  EdgeInsetsGeometry? margin,
  TodoCatToastStyleType? toastStyleType,
  Widget Function(AnimationController, Widget, AnimationParam)?
      animationBuilder,
  String? tag,
  bool? keepSingle,
  bool? backDismiss,
}) {
  List<Effect<dynamic>> getToastAnimationEffect(
      AnimationController controller) {
    final List<Effect<dynamic>> animationEffect = [
      MoveEffect(
        begin: const Offset(0, 150),
        duration: controller.duration,
        curve: Curves.easeInOutBack,
      ),
      FadeEffect(
        duration: controller.duration,
        curve: Curves.easeInOutBack,
      ),
    ];
    if (toastStyleType == TodoCatToastStyleType.error ||
        toastStyleType == TodoCatToastStyleType.warning) {
      animationEffect.addAll([
        const ThenEffect(),
        ShakeEffect(
          hz: 4,
          offset: const Offset(8, 0),
          rotation: 0,
          duration: controller.duration,
        ),
      ]);
    }
    return animationEffect;
  }

  SmartDialog.show(
    displayTime: displayTime ?? 3000.ms,
    animationTime: animationTime ?? 600.ms,
    tag: tag,
    keepSingle: keepSingle ?? true,
    alignment: alignment ?? Alignment.bottomCenter,
    maskColor: Colors.transparent,
    maskWidget: Container(),
    clickMaskDismiss: false,
    backDismiss: backDismiss ?? false,
    animationBuilder: animationBuilder ??
        (controller, child, _) => child.animate(
              controller: controller,
              effects: getToastAnimationEffect(controller),
            ),
    builder: builder ??
        (context) {
          final iconData =
              getIconData(toastStyleType ?? TodoCatToastStyleType.info);
          return Container(
            margin: margin ?? const EdgeInsets.only(bottom: 100),
            width: 250,
            height: 60,
            decoration: BoxDecoration(
              color: context.theme.dialogBackgroundColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: context.theme.dividerColor,
                  blurRadius: context.isDarkMode ? 1 : 5,
                )
              ],
            ),
            child: Center(
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Icon(
                    iconData[0],
                    color: iconData[1],
                  ),
                  const SizedBox(width: 20),
                  Text(message),
                ],
              ),
            ),
          );
        },
  );
}
