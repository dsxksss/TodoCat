import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

void showToast(String message,
    {Duration? displayTime,
    Duration? animationTime,
    AlignmentGeometry? alignment,
    Widget Function(BuildContext)? builder,
    EdgeInsetsGeometry? margin,
    Widget Function(AnimationController, Widget, AnimationParam)?
        animationBuilder,
    String? tag,
    bool? keepSingle}) {
  SmartDialog.show(
    displayTime: displayTime ?? 4000.ms,
    animationTime: animationTime ?? 1000.ms,
    tag: tag,
    keepSingle: keepSingle ?? true,
    alignment: alignment ?? Alignment.bottomCenter,
    maskColor: Colors.transparent,
    maskWidget: Container(),
    clickMaskDismiss: false,
    animationBuilder: animationBuilder ??
        (controller, child, _) => child
            .animate(controller: controller)
            .moveY(
              begin: 120,
              end: 0,
              duration: controller.duration,
              curve: Curves.easeInOutBack,
            )
            .fade(
              duration: controller.duration,
              curve: Curves.easeInOut,
            ),
    builder: builder ??
        (context) {
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
                  blurRadius: context.isDarkMode ? 2 : 5,
                )
              ],
            ),
            child: Center(
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  const Icon(FontAwesomeIcons.check),
                  const SizedBox(width: 20),
                  Text(message),
                ],
              ),
            ),
          );
        },
  );
}
