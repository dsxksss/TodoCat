import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:logger/logger.dart';

import 'package:todo_cat/widgets/platform_dialog_wrapper.dart';

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

    PlatformDialogWrapper.show(
      tag: tag,
      content: dialog,
      useSystem: useSystem,
      debounce: debounce,
      keepSingle: keepSingle,
      backType: backType,
      animationTime: animationTime,
      clickMaskDismiss: false,
    );
  }

  static void dismiss(String tag) {
    _logger.d('Dismissing dialog with tag: $tag');
    SmartDialog.dismiss(tag: tag);
  }
}
