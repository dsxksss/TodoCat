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
      final stackString = stack.toString();
      
      // 检查是否是 setState after dispose 错误（仅在特定组件中）
      if (errorString.contains('setState() called after dispose()') &&
          (errorString.contains('ReorderFlexState') || 
           stackString.contains('appflowy_board'))) {
        // 静默忽略 appflowy_board 内部的已知问题
        debugPrint('⚠️ Ignoring known setState after dispose error in appflowy_board');
        return;
      }
      
      // 检查是否是 desktop_updater 相关的非关键错误（仅在特定上下文中）
      // 只在错误明确来自 desktop_updater 插件时才忽略
      if ((errorString.contains('desktop_updater') || stackString.contains('desktop_updater')) &&
          (errorString.contains('hashes.json') ||
           errorString.contains('Failed to download hashes') ||
           errorString.contains('VersionError') ||
           errorString.contains('Invalid version format'))) {
        // 静默忽略 desktop_updater 的非关键错误（网络问题、文件不存在等）
        debugPrint('⚠️ Ignoring non-critical desktop_updater error: $error');
        return;
      }
      
      // 检查是否是 google_fonts 相关的资源加载错误（仅在特定上下文中）
      if ((errorString.contains('google_fonts') || stackString.contains('google_fonts')) &&
          (errorString.contains('AssetManifest.json') ||
           errorString.contains('Unable to load asset'))) {
        // 静默忽略 google_fonts 的资源加载错误（通常是构建问题，不影响功能）
        debugPrint('⚠️ Ignoring google_fonts asset loading error: $error');
        return;
      }
      
      // 检查是否是 Windows 平台线程通信错误（仅在应用退出时）
      if (errorString.contains('Failed to post message to main thread') ||
          (errorString.contains('task_runner_window') && 
           stackString.contains('close') || stackString.contains('dispose'))) {
        // 静默忽略 Windows 线程通信错误（通常发生在应用退出时，无害）
        debugPrint('⚠️ Ignoring Windows thread communication error during shutdown: $error');
        return;
      }
      
      // 对于所有其他错误，详细记录并显示
      // 这些可能是导致应用崩溃的关键错误
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('❌ UNHANDLED ERROR in runZonedGuarded');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Error: $error');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Stack trace:');
      debugPrint(stack.toString());
      debugPrint('═══════════════════════════════════════════════════════════');
      
      // 在调试模式下，可以考虑显示错误对话框
      // 但在生产环境中，应该记录到日志文件或错误报告服务
    },
  );
}
