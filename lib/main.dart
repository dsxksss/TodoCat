import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_cat/app.dart';
import 'package:todo_cat/data/db.dart';
import 'package:todo_cat/window/init_window.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  await initDB();
  Get.put(AppController());

  // google fonts don't use network getting
  GoogleFonts.config.allowRuntimeFetching = false;

  // 确保flutterBinding初始化成功
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 设置桌面平台window属性
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    initWindow();
  }

  runApp(DevicePreview(
    enabled: false,
    builder: (_) => const App(),
  ));

  if (Platform.isAndroid || Platform.isIOS) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }
}
