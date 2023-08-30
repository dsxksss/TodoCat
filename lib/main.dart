import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/app.dart';
import 'package:todo_cat/data/db.dart';
import 'package:todo_cat/window/init_window.dart';

void main() async {
  final logger = Logger(
    // printer: PrettyPrinter(),
    output: FileOutput(
      file: File("TodoCatLog.txt"),
    ),
  );

  try {
    await initDB();

    // 确保flutterBinding初始化成功
    WidgetsFlutterBinding.ensureInitialized();

    // 设置桌面平台window属性
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      initWindow();
      await localNotifier.setup(
        appName: 'TodoCat',
        // The parameter shortcutPolicy only works on Windows
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
    }
    runApp(DevicePreview(
      enabled: false,
      builder: (_) => const App(),
    ));
  } catch (error) {
    logger.f("运行失败!!! error:", error: error);
  }
}
