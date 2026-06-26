import 'dart:io';
import 'package:flutter/material.dart';

/// 渲染 todo 附件图片：自动区分网络 URL 与本地文件路径（含 file:// 规范化）。
///
/// 此前详情弹窗 / 详情页对 `todo.images` 一律用 `Image.network`，本地文件路径
/// 永远加载失败、显示损坏图标。这里按协议分流：http(s) → 网络图，其余 → 本地文件图。
class AttachmentImage extends StatelessWidget {
  const AttachmentImage(this.path, {super.key, this.size = 150});

  final String path;
  final double size;

  bool get _isNetwork =>
      path.startsWith('http://') || path.startsWith('https://');

  String _normalizeLocalPath(String p) {
    if (p.startsWith('file://')) {
      // 去掉 file:// 前缀：Windows 形如 file:///C:/a → C:/a；类 Unix 保留前导 /。
      var fp = p.replaceFirst(
          RegExp(r'^file:///+'), Platform.isWindows ? '' : '/');
      if (Platform.isWindows) fp = fp.replaceAll('/', '\\');
      return fp;
    }
    return p;
  }

  Widget _broken() => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.broken_image,
            size: size / 3, color: Colors.grey.shade400),
      );

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _broken(),
      );
    }
    return Image.file(
      File(_normalizeLocalPath(path)),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _broken(),
    );
  }
}
