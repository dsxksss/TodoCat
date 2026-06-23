import 'package:flutter/material.dart';

/// 手机宽度阈值（与 GetX `context.isPhone` 行为保持一致）。
const double kPhoneWidthThreshold = 600;

/// 替代 GetX 在 BuildContext 上的便捷扩展（`context.theme` / `context.width` /
/// `context.height` / `context.isPhone`）。
///
/// 命名与 GetX 保持一致，因此移除 `package:get/get.dart` 后，原有调用点无需改动，
/// 只需改为 import 本文件。注意：本扩展与 GetX 的同名扩展冲突，**仅在已移除 get 的
/// 文件中** import。
extension ResponsiveContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  Size get mediaQuerySize => MediaQuery.sizeOf(this);
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  bool get isPhone => width < kPhoneWidthThreshold;
}
