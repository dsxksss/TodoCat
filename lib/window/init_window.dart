import 'package:todo_cat/window/window_options.dart';
import 'package:window_manager/window_manager.dart';

void initWindow() async {
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow(getOptions(), () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
