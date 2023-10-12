import 'dart:io';

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
  List<Effect<dynamic>> getToastAnimationEffect(
      AnimationController controller) {
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
              effects: getToastAnimationEffect(controller),
            ),
    builder: builder ??
        (context) {
          final iconData =
              _getIconData(toastStyleType ?? TodoCatToastStyleType.info);
          return Container(
            margin: margin ??
                (Platform.isAndroid || Platform.isIOS
                    ? const EdgeInsets.only(top: 110)
                    : const EdgeInsets.only(bottom: 100)),
            width: 250,
            height: confirmMode ? 90 : 60,
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
                    mainAxisAlignment: confirmMode
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      if (confirmMode) const SizedBox(height: 15),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            iconData[0],
                            color: iconData[1],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (confirmMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Row(
                        children: [
                          IconButton.outlined(
                            onPressed: () {
                              if (onYesCallback != null) {
                                SmartDialog.dismiss(tag: tag);
                                onYesCallback();
                              } else {
                                SmartDialog.dismiss(tag: tag);
                              }
                            },
                            icon: const Icon(
                              Icons.check_rounded,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 5),
                          IconButton.outlined(
                            onPressed: () {
                              if (onNoCallback != null) {
                                SmartDialog.dismiss(tag: tag);
                                onNoCallback();
                              } else {
                                SmartDialog.dismiss(tag: tag);
                              }
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.redAccent,
                            ),
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
