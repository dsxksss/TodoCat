import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:logger/logger.dart';

/// 视频背景组件
/// 支持高帧率视频循环播放，自动静音
/// Windows 平台会自动使用 video_player_win 以获得更好的性能和硬件加速
class VideoBackground extends StatefulWidget {
  final String videoPath;
  final double opacity;
  final double blur;

  const VideoBackground({
    super.key,
    required this.videoPath,
    this.opacity = 1.0,
    this.blur = 0.0,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  static final _logger = Logger();
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isDisposed = false; // 标记是否已销毁

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      VideoPlayerController? tempController;

      // 检查是否是 assets 路径
      if (widget.videoPath.startsWith('assets/')) {
        if (GetPlatform.isWindows) {
          // Windows 平台不支持 assets，需要先复制到临时目录
          try {
            // 去掉 'assets/' 前缀，Flutter 的 rootBundle.load 需要不带 'assets/' 的路径
            final assetPath = widget.videoPath.replaceFirst('assets/', '');
            _logger.d('尝试加载 assets 视频: $assetPath');
            final byteData = await rootBundle.load(assetPath);
            
            // 检查是否已销毁
            if (_isDisposed || !mounted) return;
            
            final tempDir = await getTemporaryDirectory();
            final tempFile =
                File('${tempDir.path}/${assetPath.split('/').last}');
            await tempFile.writeAsBytes(byteData.buffer.asUint8List());
            _logger.d('Assets 视频已复制到临时目录: ${tempFile.path}');
            tempController = VideoPlayerController.file(tempFile);
          } catch (e) {
            _logger.e('加载 assets 视频失败: $e');
            // 检查是否已销毁
            if (_isDisposed || !mounted) return;
            
            // 尝试使用完整路径作为文件路径（开发环境可能直接使用文件路径）
            final fullPath = widget.videoPath;
            final projectRoot = Directory.current.path;
            final absolutePath = '$projectRoot/$fullPath';
            if (File(absolutePath).existsSync()) {
              _logger.d('使用项目根目录下的文件路径: $absolutePath');
              tempController = VideoPlayerController.file(File(absolutePath));
            } else if (File(fullPath).existsSync()) {
              _logger.d('使用完整文件路径: $fullPath');
              tempController = VideoPlayerController.file(File(fullPath));
            } else {
              if (!_isDisposed && mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = '加载 assets 视频失败: $e';
                });
              }
              return;
            }
          }
        } else {
          // 其他平台使用 asset 路径
          final assetPath = widget.videoPath.replaceFirst('assets/', '');
          tempController = VideoPlayerController.asset(assetPath);
        }
      } else {
        // 检查是否是网络URL
        if (widget.videoPath.startsWith('http://') ||
            widget.videoPath.startsWith('https://')) {
          // 使用网络视频控制器
          tempController =
              VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
        } else {
          // 检查文件是否存在
          if (!File(widget.videoPath).existsSync()) {
            _logger.e('视频文件不存在: ${widget.videoPath}');
            if (!_isDisposed && mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = '视频文件不存在: ${widget.videoPath}';
              });
            }
            return;
          }

          // 创建视频播放器控制器
          // video_player_win 会自动在 Windows 平台上生效
          tempController = VideoPlayerController.file(File(widget.videoPath));
        }
      }

      // 检查是否已销毁
      if (_isDisposed || !mounted) {
        // 如果已销毁，清理可能已创建的控制器
        // 注意：tempController 可能为 null（如果前面的代码路径没有创建它）
        if (tempController != null) {
          try {
            tempController.dispose();
          } catch (e) {
            // 忽略销毁错误
          }
        }
        return;
      }

      // 此时 tempController 应该已经被赋值（根据代码路径分析）
      _controller = tempController;

      // 初始化视频
      await _controller!.initialize();

      // 再次检查是否已销毁（在异步操作后）
      if (_isDisposed || !mounted) {
        _controller?.dispose();
        _controller = null;
        return;
      }

      // 添加监听器，监听播放状态变化
      _controller!.addListener(_videoListener);

      // 设置循环播放
      _controller!.setLooping(true);
      // 静音播放
      _controller!.setVolume(0.0);
      // 开始播放
      await _controller!.play();

      // 最后一次检查是否已销毁（在异步操作后）
      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      _logger.e('初始化视频失败: $e', error: e, stackTrace: stackTrace);
      if (!_isDisposed && mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = '初始化视频失败: $e';
        });
      }
    }
  }

  @override
  void didUpdateWidget(VideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果视频路径改变，重新初始化
    if (oldWidget.videoPath != widget.videoPath) {
      _disposeController();
      _initializeVideo();
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      final value = _controller!.value;
      // 如果视频播放完成但未循环，重新播放
      if (value.isCompleted && !value.isLooping) {
        _controller!.seekTo(Duration.zero);
        _controller!.play();
      }
      // 如果视频意外停止，重新播放（但不要过于频繁）
      if (!value.isPlaying &&
          value.isInitialized &&
          !value.isBuffering &&
          !value.isCompleted) {
        _controller!.play();
      }
      // 触发 UI 更新
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _disposeController() {
    _isDisposed = true; // 标记为已销毁
    final controller = _controller;
    _controller = null; // 先清空引用，避免后续访问
    controller?.removeListener(_videoListener);
    controller?.pause();
    // 延迟销毁，避免在拖拽等操作时触发可访问性树更新错误
    // 这样可以避免在 Widget 树重建时立即销毁导致的冲突
    Future.microtask(() {
      controller?.dispose();
    });
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            _errorMessage ?? '视频加载失败',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    return Opacity(
      opacity: widget.opacity,
      child: ClipRect(
        child: widget.blur > 0
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: _buildVideoPlayer(),
              )
            : _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // 使用 ExcludeSemantics 减少可访问性树更新
    return ExcludeSemantics(
      child: _buildVideoPlayerContent(),
    );
  }

  Widget _buildVideoPlayerContent() {
    // 使用 ValueListenableBuilder 确保视频状态变化时 UI 更新
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller!,
      builder: (context, value, child) {
        if (value.size.width == 0 || value.size.height == 0) {
          return Container(color: Colors.black);
        }
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
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
