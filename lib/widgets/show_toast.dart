import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/label_btn.dart';

enum TodoCatToastStyleType {
  info,
  success,
  error,
  warning,
}

List _getIconData(TodoCatToastStyleType type) {
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

List<Effect<dynamic>> _getToastAnimationEffect(
    AnimationController controller, TodoCatToastStyleType? toastStyleType) {
  final List<Effect<dynamic>> animationEffect = [
    MoveEffect(
      begin: Platform.isAndroid || Platform.isIOS
          ? const Offset(0, -150)
          : const Offset(0, 150),
      duration: controller.duration,
      curve: Curves.easeInOutBack,
    ),
    FadeEffect(
      duration: controller.duration,
      curve: Curves.easeInOutBack,
    ),
  ];
  return animationEffect;
}

void showToast(
  String message, {
  bool confirmMode = false,
  bool alwaysShow = false,
  Function? onYesCallback,
  Function? onNoCallback,
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
    displayTime:
        alwaysShow ? const Duration(days: 365) : displayTime ?? 3000.ms,
    animationTime: animationTime ?? 600.ms,
    tag: tag,
    keepSingle: keepSingle ?? true,
    alignment: alignment ??
        (Platform.isAndroid || Platform.isIOS
            ? Alignment.topCenter
            : Alignment.bottomCenter),
    maskColor: Colors.transparent,
    maskWidget: Container(),
    clickMaskDismiss: false,
    backDismiss: backDismiss ?? false,
    animationBuilder: animationBuilder ??
        (controller, child, _) => child.animate(
              controller: controller,
              effects: _getToastAnimationEffect(controller, toastStyleType),
            ),
    builder: builder ??
        (context) {
          final iconData =
              _getIconData(toastStyleType ?? TodoCatToastStyleType.info);
          return Container(
            width: 300,
            height: confirmMode ? 110 : 60,
            margin: margin ??
                (Platform.isAndroid || Platform.isIOS
                    ? const EdgeInsets.only(top: 110)
                    : const EdgeInsets.only(bottom: 100)),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize:
                        confirmMode ? MainAxisSize.min : MainAxisSize.max,
                    mainAxisAlignment: confirmMode
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      if (confirmMode) const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            iconData[0],
                            color: iconData[1],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (confirmMode)
                    Positioned(
                      bottom: 10,
                      right: 5,
                      child: Row(
                        children: [
                          LabelBtn(
                            label: Text("yes".tr),
                            ghostStyle: true,
                            onPressed: () {
                              if (onYesCallback != null) {
                                SmartDialog.dismiss(tag: tag);
                                onYesCallback();
                              } else {
                                SmartDialog.dismiss(tag: tag);
                              }
                            },
                          ),
                          const SizedBox(width: 20),
                          LabelBtn(
                            label: Text("no".tr),
                            ghostStyle: true,
                            onPressed: () {
                              if (onNoCallback != null) {
                                SmartDialog.dismiss(tag: tag);
                                onNoCallback();
                              } else {
                                SmartDialog.dismiss(tag: tag);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
  );
}
