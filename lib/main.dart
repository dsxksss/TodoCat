import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/app/app.dart';

void main() async {
  // 初始化hive本地数据库
  await Hive.initFlutter();

  runApp(DevicePreview(
    enabled: !kReleaseMode, // 是否关闭设备适配查看器
    builder: (context) => const App(),
  ));

  Hive.close();
}
