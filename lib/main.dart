import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_cat/app.dart';
import 'package:todo_cat/data/db.dart';
import 'package:flutter/services.dart';
import 'package:todo_cat/window/init_window.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  await initDB();

  // GoogleFonts 不使用运行时获取
  GoogleFonts.config.allowRuntimeFetching = false;

  // 确保flutterBinding初始化成功
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 设置桌面平台window属性
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    initWindow();
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

  runApp(DevicePreview(
    enabled: false,
    builder: (_) => const App(),
  ));
}
