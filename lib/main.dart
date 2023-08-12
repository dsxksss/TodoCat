import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/app/app.dart';
import 'package:todo_cat/app/data/schemas/task.dart';

void main() async {
  // 初始化hive本地数据库
  // 注册Hive数据模板
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  runApp(DevicePreview(
    enabled: kReleaseMode, // 是否关闭设备适配查看器
    builder: (context) => const App(),
  ));

  Hive.close();
}
