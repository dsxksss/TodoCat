import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

/// 显示图片查看器（使用 SmartDialog 避免 Navigator context 问题）
void showImageViewer({
  required BuildContext context,
  required ImageProvider imageProvider,
  String? heroTag,
  String? caption,
}) {
  final tag = 'image_viewer_${DateTime.now().millisecondsSinceEpoch}';
  
  SmartDialog.show(
    tag: tag,
    useSystem: false,
    keepSingle: true,
    backType: SmartBackType.normal,
    animationTime: const Duration(milliseconds: 200),
    alignment: Alignment.center,
    maskColor: Colors.black.withValues(alpha: 0.95),
    builder: (_) => _ImageViewerDialog(
      imageProvider: imageProvider,
      heroTag: heroTag,
      caption: caption,
      onClose: () => SmartDialog.dismiss(tag: tag),
    ),
    animationBuilder: (controller, child, _) {
      return FadeTransition(
        opacity: controller,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOut),
          ),
          child: child,
        ),
      );
    },
  );
}

/// 图片查看器对话框（内部使用）
class _ImageViewerDialog extends StatefulWidget {
  final ImageProvider imageProvider;
  final String? heroTag;
  final String? caption;
  final VoidCallback onClose;

  const _ImageViewerDialog({
    required this.imageProvider,
    this.heroTag,
    this.caption,
    required this.onClose,
  });

  @override
  State<_ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<_ImageViewerDialog>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;

  static const double _minScale = 0.5;
  static const double _maxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails?.localPosition ?? Offset.zero;
    final currentScale = _transformationController.value.getMaxScaleOnAxis();

    Matrix4 endMatrix;
    if (currentScale > 1.0) {
      // 已经放大，恢复原始大小
      endMatrix = Matrix4.identity();
    } else {
      // 放大到 2 倍，以点击位置为中心
      // 正确的变换顺序：先 scale，再 translate
      // 计算：要使 position 点在变换后保持在原位置
      // 变换后的点 = (点 - 中心) * scale + 中心 + translate
      // 我们要让 position 保持不动，所以 translate = position - position * scale = position * (1 - scale)
      const scale = 2.0;
      final dx = position.dx * (1 - scale);
      final dy = position.dy * (1 - scale);
      endMatrix = Matrix4.identity()
        ..scale(scale)
        ..translate(dx / scale, dy / scale);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward(from: 0);
  }

  void _resetTransform() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      child: Stack(
        children: [
          // 图片区域
          GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: _minScale,
              maxScale: _maxScale,
              panEnabled: true,
              scaleEnabled: true,
              child: Center(
                child: Image(
                  image: widget.imageProvider,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
                ),
              ),
            ),
          ),
          // 顶部工具栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: widget.onClose,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'resetView'.tr,
                        onPressed: _resetTransform,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 底部标题
          if (widget.caption != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.caption!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          // 缩放提示
          Positioned(
            bottom: widget.caption != null ? 80 : 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'doubleTapToZoom'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, size: 64, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'imageLoadFailed'.tr,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// 从本地文件路径显示图片
void showImageViewerFromFile({
  required BuildContext context,
  required String filePath,
  String? heroTag,
  String? caption,
}) {
  showImageViewer(
    context: context,
    imageProvider: FileImage(File(filePath)),
    heroTag: heroTag,
    caption: caption,
  );
}

/// 从网络URL显示图片
void showImageViewerFromUrl({
  required BuildContext context,
  required String url,
  String? heroTag,
  String? caption,
}) {
  showImageViewer(
    context: context,
    imageProvider: CachedNetworkImageProvider(url),
    heroTag: heroTag,
    caption: caption,
  );
}

/// 可点击的图片组件，点击后打开图片查看器
class ClickableImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final String? heroTag;
  final String? caption;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const ClickableImage({
    super.key,
    required this.imageProvider,
    this.heroTag,
    this.caption,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tag = heroTag ?? 'image_${imageProvider.hashCode}';
    
    Widget imageWidget = Hero(
      tag: tag,
      child: Image(
        image: imageProvider,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey.shade100,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
        },
      ),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: () {
        showImageViewer(
          context: context,
          imageProvider: imageProvider,
          heroTag: tag,
          caption: caption,
        );
      },
      child: imageWidget,
    );
  }
}

/// 从本地文件创建可点击图片
class ClickableFileImage extends StatelessWidget {
  final String filePath;
  final String? heroTag;
  final String? caption;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const ClickableFileImage({
    super.key,
    required this.filePath,
    this.heroTag,
    this.caption,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClickableImage(
      imageProvider: FileImage(File(filePath)),
      heroTag: heroTag ?? 'file_$filePath',
      caption: caption,
      fit: fit,
      width: width,
      height: height,
      errorWidget: errorWidget,
      borderRadius: borderRadius,
    );
  }
}

/// 从网络URL创建可点击图片（带缓存）
class ClickableNetworkImage extends StatelessWidget {
  final String url;
  final String? heroTag;
  final String? caption;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const ClickableNetworkImage({
    super.key,
    required this.url,
    this.heroTag,
    this.caption,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tag = heroTag ?? 'network_$url';

    Widget imageWidget = Hero(
      tag: tag,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: Icon(
                Icons.broken_image,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
      ),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: () {
        showImageViewer(
          context: context,
          imageProvider: CachedNetworkImageProvider(url),
          heroTag: tag,
          caption: caption,
        );
      },
      child: imageWidget,
    );
  }
}

