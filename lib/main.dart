import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/app/app.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 初始化hive本地数据库
  await Hive.initFlutter();

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  Size minWindowSize = const Size(1280, 720);
  WindowOptions windowOptions = WindowOptions(
    size: minWindowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.setMinimumSize(minWindowSize);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(DevicePreview(
    enabled: kReleaseMode, // 是否关闭设备适配查看器
    builder: (context) => const App(),
  ));

  Hive.close();
}
