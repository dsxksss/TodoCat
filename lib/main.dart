import 'dart:async';
import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_cat/app.dart';
import 'package:todo_cat/init_window.dart';

Future<void> saveSpecifiedTime(DateTime time) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('specifiedTime', time.toString());
}

Future<void> checkAndExecuteFunction() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? specifiedTime = prefs.getString('specifiedTime');

  if (specifiedTime != null) {
    DateTime time = DateTime.parse(specifiedTime);
    DateTime currentTime = DateTime.now();
    if (currentTime.isBefore(time)) {
      Timer timer = Timer(time.difference(currentTime), () {
        LocalNotification notification = LocalNotification(
          title: "TodoCat",
          body: "xxx任务快要过期,请及时完成!",
        );
        notification.show();
      });
    }
  }
}

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

    // 设置桌面平台window属性
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      initWindow();
      await localNotifier.setup(
        appName: 'TodoCat',
        // The parameter shortcutPolicy only works on Windows
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
    }
    await saveSpecifiedTime(DateTime.now().add(Duration(seconds: 10)));

    await checkAndExecuteFunction();
    runApp(DevicePreview(
      enabled: false,
      builder: (_) => const App(),
    ));
  } catch (error) {
    logger.f("运行失败!!! error:", error: error);
  }
}
