import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/app/app.dart';
import 'package:todo_cat/window_options.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 初始化hive本地数据库
  await Hive.initFlutter();

  // 设置桌面平台window属性
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    windowManager.setMinimumSize(minWindowSize);
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(DevicePreview(
    enabled: kReleaseMode, // 是否关闭设备适配查看器
    builder: (context) => const App(),
  ));

  Hive.close();
}
