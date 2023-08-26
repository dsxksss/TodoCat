import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/app/app.dart';
import 'package:todo_cat/init_window.dart';

void main() async {
  final logger = Logger(
    // printer: PrettyPrinter(),
    output: FileOutput(
      file: File("TodoCatLog.txt"),
    ),
  );

  try {
    // 初始化hive本地数据库
    await Hive.initFlutter();
    // 确保flutterBinding初始化成功
    WidgetsFlutterBinding.ensureInitialized();

    logger.e("log:");

    // 设置桌面平台window属性
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      initWindow();
    }

    runApp(DevicePreview(
      enabled: false,
      builder: (_) => const App(),
    ));

    Hive.close();
  } catch (error) {
    logger.e("log:", error: error);
  }
}
