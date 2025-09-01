import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todo_cat/data/services/database.dart';
import 'package:flutter/services.dart';
import 'package:todo_cat/pages/app.dart';
import 'package:todo_cat/window/init_window.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // 确保flutterBinding初始化成功
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 全局异常捕获，静默处理已知的键盘事件错误
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    final stackTrace = details.stack;
    
    // 静默处理键盘和手写相关错误
    if (exception.toString().contains('setStylusHandwritingEnabled') ||
        exception.toString().contains('KeyDownEvent') ||
        exception.toString().contains('NoSuchMethodError') && 
        exception.toString().contains('EditorInfoCompat')) {
      debugPrint('Handled known input method error: ${exception.toString()}');
      return;
    }
    
    // 其他错误正常显示
    FlutterError.presentError(details);
  };

  // 初始化 Isar 数据库
  await Database.getInstance();

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

  runApp(
    const App(),
  );
}
