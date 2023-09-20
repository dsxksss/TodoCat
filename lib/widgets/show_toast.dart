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
  SmartDialog.show(
    displayTime: displayTime ?? 4000.ms,
    animationTime: animationTime ?? 1000.ms,
    tag: tag,
    keepSingle: keepSingle ?? true,
    alignment: alignment ?? Alignment.bottomCenter,
    maskColor: Colors.transparent,
    maskWidget: Container(),
    clickMaskDismiss: false,
    backDismiss: backDismiss ?? false,
    animationBuilder: animationBuilder ??
        (controller, child, _) => child
            .animate(controller: controller)
            .moveY(
              begin: 150,
              end: 0,
              duration: controller.duration,
              curve: Curves.easeInOutBack,
            )
            .fade(
              duration: fadeAnimation ? controller.duration : 0.ms,
              curve: Curves.easeInOutBack,
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
