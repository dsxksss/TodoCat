import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/app/app.dart';
import 'package:todo_cat/env.dart';
import 'package:todo_cat/init_window.dart';

void main() async {
  final logger = Logger(
    // printer: PrettyPrinter(),
    output: FileOutput(
      // 指定日志文件的路径
      overrideExisting: true,
      file: File("logfile.txt"),
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
      enabled: isDebugMode, // 是否关闭设备适配查看器
      builder: (_) => const App(),
    ));

    Hive.close();
  } catch (error) {
    logger.e("log:", error: error);
  }
}
