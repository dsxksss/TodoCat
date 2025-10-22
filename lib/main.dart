import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todo_cat/data/services/database.dart';
import 'package:flutter/services.dart';
import 'package:todo_cat/pages/app.dart';
import 'package:todo_cat/window/init_window.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

void main() async {
  // 确保flutterBinding初始化成功
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Isar 数据库
  await Database.getInstance();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    initWindow();

    // 初始化桌面端开机自启动插件（Windows/Linux/macOS）
    launchAtStartup.setup(
      appName: 'TodoCat',
      appPath: Platform.resolvedExecutable,
    );
  }

  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  runApp(
    const App(),
  );
}
