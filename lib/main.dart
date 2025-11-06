import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:flutter/services.dart';
import 'package:TodoCat/pages/app.dart';
import 'package:TodoCat/window/init_window.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

void main() async {
  // 使用 runZonedGuarded 捕获所有异步错误
  runZonedGuarded(
    () async {
      // 确保flutterBinding初始化成功
      WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

      // 全局错误处理：捕获并忽略特定的 setState 错误
      // 这主要是为了处理第三方包（如 appflowy_board）内部的生命周期问题
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final exception = details.exception;
        // 检查是否是 "setState() called after dispose()" 错误
        if (exception is FlutterError) {
          final message = exception.message;
          if (message.contains('setState() called after dispose()') &&
              message.contains('ReorderFlexState')) {
            // 忽略 appflowy_board 内部的 setState after dispose 错误
            // 这是包内部的问题，不影响应用功能
            debugPrint('⚠️ Ignoring known setState after dispose error in appflowy_board');
            return;
          }
        }
        // 对于其他错误，使用原始处理器
        if (originalOnError != null) {
          originalOnError(details);
        } else {
          FlutterError.presentError(details);
        }
      };

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
    },
    (error, stack) {
      // 捕获所有异步异常（包括 Future 回调中的异常）
      final errorString = error.toString();
      
      // 检查是否是 setState after dispose 错误
      if (errorString.contains('setState() called after dispose()') &&
          errorString.contains('ReorderFlexState')) {
        // 静默忽略 appflowy_board 的已知问题
        debugPrint('⚠️ Caught and ignored setState after dispose error in appflowy_board');
        return;
      }
      
      // 检查是否是 desktop_updater 相关的错误
      if (errorString.contains('desktop_updater') ||
          errorString.contains('FormatException') ||
          errorString.contains('jsonDecode') ||
          errorString.contains('VersionError') ||
          errorString.contains('Invalid version format') ||
          errorString.contains('PlatformException') ||
          errorString.contains('hashes.json') ||
          errorString.contains('Failed to download hashes')) {
        // 静默忽略 desktop_updater 相关的错误
        // 包括：网络问题、文件不存在、版本格式问题、哈希验证失败（MSIX 包有签名验证）
        debugPrint('⚠️ Caught and ignored desktop_updater error: $error');
        return;
      }
      
      // 检查是否是 google_fonts 相关的错误
      if (errorString.contains('google_fonts') ||
          errorString.contains('AssetManifest.json') ||
          errorString.contains('Unable to load asset')) {
        // 静默忽略 google_fonts 相关的错误（通常是构建问题，不影响功能）
        debugPrint('⚠️ Caught and ignored google_fonts error: $error');
        return;
      }
      
      // 检查是否是 Windows 平台线程通信错误（通常发生在应用退出时）
      if (errorString.contains('Failed to post message to main thread') ||
          errorString.contains('task_runner_window') ||
          errorString.contains('message to main thread')) {
        // 静默忽略 Windows 线程通信错误（通常发生在应用退出时，无害）
        debugPrint('⚠️ Caught and ignored Windows thread communication error: $error');
        return;
      }
      
      // 对于其他错误，打印堆栈跟踪（保留原有的错误处理行为）
      debugPrint('Caught error in runZonedGuarded: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}
