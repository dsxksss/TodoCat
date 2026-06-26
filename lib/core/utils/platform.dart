import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 替代 GetX 的 `GetPlatform`，基于 `dart:io` + `kIsWeb`。
///
/// 用法：`AppPlatform.isDesktop` / `AppPlatform.isMobile` 等。
abstract final class AppPlatform {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
}
