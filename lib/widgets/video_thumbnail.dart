import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 视频缩略图组件
/// 从视频中截取一帧作为缩略图显示
/// Windows 平台会自动使用 video_player_win 以获得更好的性能
/// 支持自动缓存缩略图，避免重复加载
class VideoThumbnail extends StatefulWidget {
  final String videoPath;
  final BoxFit fit;
  final Duration? position; // 指定截取的时间位置，null 表示使用视频中间位置
  final Widget? placeholder; // 加载时的占位符

  const VideoThumbnail({
    super.key,
    required this.videoPath,
    this.fit = BoxFit.cover,
    this.position,
    this.placeholder,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _cachedThumbnailPath;
  bool _isCheckingCache = false;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeThumbnail();
  }

  /// 获取缓存文件路径
  Future<String> _getCacheFilePath() async {
    // 生成视频路径的哈希值作为缓存文件名
    final bytes = utf8.encode(widget.videoPath);
    final hash = sha256.convert(bytes);
    final cacheDir = await getApplicationCacheDirectory();
    final thumbnailDir = Directory('${cacheDir.path}/video_thumbnails');
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    return '${thumbnailDir.path}/${hash.toString()}.png';
  }

  /// 检查缓存是否存在
  Future<bool> _checkCache() async {
    try {
      final cachePath = await _getCacheFilePath();
      final cacheFile = File(cachePath);
      if (await cacheFile.exists()) {
        _cachedThumbnailPath = cachePath;
        return true;
      }
    } catch (e) {
      // 忽略缓存检查错误
    }
    return false;
  }

  /// 保存缩略图到缓存
  Future<void> _saveThumbnailToCache() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        return;
      }

      final cachePath = await _getCacheFilePath();
      
      // 等待一帧渲染完成
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 使用 RepaintBoundary 捕获截图
      final RenderRepaintBoundary? boundary = 
          _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final file = File(cachePath);
          await file.writeAsBytes(byteData.buffer.asUint8List());
          _cachedThumbnailPath = cachePath;
        }
        image.dispose();
      }
    } catch (e) {
      // 忽略保存缓存错误，不影响正常显示
    }
  }

  Future<void> _initializeThumbnail() async {
    // 先检查缓存
    _isCheckingCache = true;
    final hasCache = await _checkCache();
    _isCheckingCache = false;
    
    if (hasCache && _cachedThumbnailPath != null) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      return;
    }

    try {
      VideoPlayerController? tempController;
      
      // 检查是否是网络URL
      if (widget.videoPath.startsWith('http://') || widget.videoPath.startsWith('https://')) {
        // 使用网络视频控制器
        tempController = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      }
      // 检查是否是 assets 路径
      else if (widget.videoPath.startsWith('assets/')) {
        if (GetPlatform.isWindows) {
          // Windows 平台不支持 assets，需要先复制到临时目录
          try {
            // 去掉 'assets/' 前缀，Flutter 的 rootBundle.load 需要不带 'assets/' 的路径
            final assetPath = widget.videoPath.replaceFirst('assets/', '');
            final byteData = await rootBundle.load(assetPath);
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
            await tempFile.writeAsBytes(byteData.buffer.asUint8List());
            tempController = VideoPlayerController.file(tempFile);
          } catch (e) {
            // 尝试使用完整路径作为文件路径（开发环境可能直接使用文件路径）
            final fullPath = widget.videoPath;
            final projectRoot = Directory.current.path;
            final absolutePath = '$projectRoot/$fullPath';
            if (File(absolutePath).existsSync()) {
              tempController = VideoPlayerController.file(File(absolutePath));
            } else if (File(fullPath).existsSync()) {
              tempController = VideoPlayerController.file(File(fullPath));
            } else {
              if (mounted) {
                setState(() {
                  _hasError = true;
                });
              }
              return;
            }
          }
        } else {
          final assetPath = widget.videoPath.replaceFirst('assets/', '');
          tempController = VideoPlayerController.asset(assetPath);
        }
      } else {
        // 检查文件是否存在
        if (!File(widget.videoPath).existsSync()) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
          return;
        }
        
        // 创建视频播放器控制器
        // video_player_win 会自动在 Windows 平台上生效
        tempController = VideoPlayerController.file(File(widget.videoPath));
      }

      _controller = tempController;

      // 初始化视频
      await _controller!.initialize();

      if (mounted && _controller!.value.isInitialized) {
        // 计算要截取的时间位置
        final duration = _controller!.value.duration;
        final targetPosition = widget.position ?? 
            Duration(milliseconds: duration.inMilliseconds ~/ 2);
        
        // 跳转到指定位置
        await _controller!.seekTo(targetPosition);
        
        // 等待一帧渲染
        await Future.delayed(const Duration(milliseconds: 200));
        
        // 暂停视频，只显示当前帧
        _controller!.pause();
        
        // 等待一帧渲染后保存缓存
        await Future.delayed(const Duration(milliseconds: 300));
        await _saveThumbnailToCache();
        
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // 延迟销毁，避免在拖拽等操作时触发可访问性树更新错误
    final controller = _controller;
    _controller = null; // 先清空引用，避免后续访问
    controller?.pause();
    // 使用微任务延迟销毁，确保可访问性树更新完成
    // 这样可以避免在 Widget 树重建时立即销毁导致的冲突
    Future.microtask(() {
      controller?.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用统一的容器结构，减少 Widget 树变化
    // 使用稳定的 key 确保 Widget 树结构的一致性
    final cacheKey = _cachedThumbnailPath ?? 'none';
    final stableKey = ValueKey('thumbnail_${widget.videoPath}_$cacheKey');
    
    Widget content;
    
    if (_hasError) {
      content = widget.placeholder ?? 
          Container(
            key: const ValueKey('thumbnail_error'),
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.videocam_off, color: Colors.white54),
            ),
          );
    } else if (_cachedThumbnailPath != null && File(_cachedThumbnailPath!).existsSync()) {
      // 如果已缓存，直接显示缓存的图片
      content = Image.file(
        key: const ValueKey('thumbnail_cached'),
        File(_cachedThumbnailPath!),
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          // 如果缓存图片加载失败，显示占位符
          return widget.placeholder ?? 
              Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.videocam_off, color: Colors.white54),
                ),
              );
        },
      );
    } else if (_isCheckingCache || !_isInitialized || _controller == null) {
      // 如果正在检查缓存或未初始化，显示加载指示器
      content = widget.placeholder ?? 
          Container(
            key: const ValueKey('thumbnail_loading'),
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
          );
    } else {
      // 使用 RepaintBoundary 包裹以便捕获截图
      content = RepaintBoundary(
        key: _repaintBoundaryKey,
        child: _buildVideoPlayer(),
      );
    }
    
    // 使用稳定的容器包裹，减少可访问性树的变化
    return Container(
      key: stableKey,
      child: content,
    );
  }

  Widget _buildVideoPlayer() {
    // 使用 ValueListenableBuilder 确保视频状态变化时 UI 更新
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller!,
      builder: (context, value, child) {
        if (value.size.width == 0 || value.size.height == 0) {
          return widget.placeholder ?? 
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
              );
        }
        // 使用 VideoPlayer 显示当前帧（暂停状态）
        return ClipRect(
          child: FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: value.size.width,
              height: value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        );
      },
    );
  }
}
