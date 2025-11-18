import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

/// 图片粘贴服务
/// 负责从剪贴板获取图片并保存到本地
class ImagePasteService {
  static final _logger = Logger();
  static final ImagePasteService _instance = ImagePasteService._internal();
  factory ImagePasteService() => _instance;
  ImagePasteService._internal();

  /// 从剪贴板获取图片并保存
  /// 返回保存的图片文件路径，如果失败返回 null
  Future<String?> pasteImageFromClipboard() async {
    try {
      if (!Platform.isWindows) {
        _logger.w('图片粘贴功能目前仅支持 Windows 平台');
        return null;
      }

      // 在 Windows 上，使用平台通道获取剪贴板图片
      const platform = MethodChannel('com.todocat/clipboard');
      
      try {
        // 调用原生方法获取剪贴板图片
        final result = await platform.invokeMethod('getClipboardImage');
        
        if (result == null) {
          _logger.d('剪贴板中没有图片');
          return null;
        }

        // result 应该是图片的字节数据
        Uint8List? imageBytes;
        if (result is Uint8List) {
          imageBytes = result;
        } else if (result is List) {
          imageBytes = Uint8List.fromList(result.cast<int>());
        } else {
          _logger.e('无法解析剪贴板图片数据: ${result.runtimeType}');
          return null;
        }

        if (imageBytes.isEmpty) {
          _logger.d('剪贴板图片数据为空');
          return null;
        }

        // 保存图片到应用目录
        final imagePath = await _saveImageToLocal(imageBytes);
        return imagePath;
      } on PlatformException catch (e) {
        _logger.d('平台通道不可用，尝试备用方案: ${e.message}');
        // 如果平台通道不可用，尝试使用备用方案
        return await _tryFlutterClipboard();
      } on MissingPluginException catch (e) {
        _logger.d('平台通道未实现，使用备用方案: ${e.message}');
        // 平台通道未实现，使用备用方案
        return await _tryFlutterClipboard();
      }
    } catch (e) {
      _logger.e('粘贴图片失败: $e');
      return null;
    }
  }

  /// 尝试使用 Flutter 的 Clipboard API（作为备用方案）
  Future<String?> _tryFlutterClipboard() async {
    try {
      // Flutter 的 Clipboard API 在 Windows 上可能不支持图片
      // 这里作为备用方案，实际可能需要平台通道
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        // 如果剪贴板是文本，检查是否是图片路径
        final text = clipboardData!.text!;
        if (text.startsWith('file://') || 
            (text.contains('.') && 
             (text.endsWith('.png') || 
              text.endsWith('.jpg') || 
              text.endsWith('.jpeg') || 
              text.endsWith('.gif') || 
              text.endsWith('.bmp') || 
              text.endsWith('.webp')))) {
          // 如果是图片路径，直接返回
          return text.replaceFirst('file://', '').replaceAll('/', '\\');
        }
      }
      return null;
    } catch (e) {
      _logger.e('使用 Flutter Clipboard API 失败: $e');
      return null;
    }
  }

  /// 保存图片到本地文件系统
  Future<String> _saveImageToLocal(Uint8List imageBytes) async {
    try {
      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'pasted_images'));
      
      // 确保目录存在
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // 生成唯一的文件名（Windows 剪贴板返回的是 BMP 格式）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'pasted_image_$timestamp.bmp';
      final filePath = path.join(imagesDir.path, fileName);

      // 保存文件
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      _logger.i('图片已保存到: $filePath');
      return filePath;
    } catch (e) {
      _logger.e('保存图片失败: $e');
      rethrow;
    }
  }
}

