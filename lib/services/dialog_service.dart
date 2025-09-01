import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class DialogService {
  static final _logger = Logger();

  static void showFormDialog({
    required String tag,
    required Widget dialog,
    bool useSystem = false,
    bool debounce = true,
    bool keepSingle = true,
    SmartBackType backType = SmartBackType.normal,
    Duration animationTime = const Duration(milliseconds: 150),
  }) {
    _logger.d('Showing form dialog with tag: $tag');

    final context = Get.context!;

    SmartDialog.show(
      tag: tag,
      useSystem: useSystem,
      debounce: debounce,
      keepSingle: keepSingle,
      backType: backType,
      animationTime: animationTime,
      alignment: context.isPhone ? Alignment.bottomCenter : Alignment.center,
      builder: (_) => context.isPhone
          ? Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: dialog,
              ),
            )
          : dialog,
      clickMaskDismiss: false,
      animationBuilder: (controller, child, _) {
        final animation = child
            .animate(controller: controller)
            .fade(duration: controller.duration);

        return context.isPhone
            ? animation
                .scaleXY(
                  begin: 0.97,
                  duration: controller.duration,
                  curve: Curves.easeIn,
                )
                .moveY(
                  begin: 0.6.sh,
                  duration: controller.duration,
                  curve: Curves.easeOutCirc,
                )
            : animation.scaleXY(
                begin: 0.98,
                duration: controller.duration,
                curve: Curves.easeIn,
              );
      },
    );
  }

  static void dismiss(String tag) {
    _logger.d('Dismissing dialog with tag: $tag');
    SmartDialog.dismiss(tag: tag);
  }
}
