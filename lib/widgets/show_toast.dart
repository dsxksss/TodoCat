import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void showToast(
  String message, {
  Duration? displayTime,
  Duration? animationTime,
  AlignmentGeometry? alignment,
  Widget Function(BuildContext)? builder,
}) {
  SmartDialog.show(
    displayTime: displayTime ?? 3000.ms,
    animationTime: animationTime ?? 200.ms,
    alignment: alignment ?? Alignment.topRight,
    maskColor: Colors.transparent,
    maskWidget: Container(),
    clickMaskDismiss: false,
    animationBuilder: (controller, child, _) => child
        .animate(controller: controller)
        .moveX(
          begin: 20,
          end: 0,
          duration: controller.duration,
        )
        .fade(duration: controller.duration),
    builder: builder ??
        (context) {
          return Container(
            margin: const EdgeInsets.only(top: 50, right: 50),
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
  );
}
