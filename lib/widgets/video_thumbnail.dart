import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// 视频缩略图组件
/// 从视频中截取一帧作为缩略图显示
/// Windows 平台会自动使用 video_player_win 以获得更好的性能
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

  @override
  void initState() {
    super.initState();
    _initializeThumbnail();
  }

  Future<void> _initializeThumbnail() async {
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
        
        setState(() {
          _isInitialized = true;
        });
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
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.placeholder ?? 
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.videocam_off, color: Colors.white54),
            ),
          );
    }

    if (!_isInitialized || _controller == null) {
      return widget.placeholder ?? 
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
          );
    }

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
