import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void initSmartDialogConfiguration() {
  SmartDialog.config.attach =
      SmartConfigAttach(attachAlignmentType: SmartAttachAlignmentType.inside);
}
