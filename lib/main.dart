import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:todo_cat/app.dart';
import 'package:todo_cat/data/db.dart';
import 'package:todo_cat/window/init_window.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // 确保flutterBinding初始化成功
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initDB();

  // 设置桌面平台window属性
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    initWindow();
  }

  // 移除启动页面
  FlutterNativeSplash.remove();

  runApp(DevicePreview(
    enabled: false,
    builder: (_) => const App(),
  ));
}
