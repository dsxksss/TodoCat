import 'package:todo_cat/window_options.dart';
import 'package:window_manager/window_manager.dart';

void initWindow() async {
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
