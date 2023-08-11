import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';

void main() => runApp(DevicePreview(
      enabled: kReleaseMode, // 是否关闭设备适配查看器
      builder: (context) => const App(),
    ));
