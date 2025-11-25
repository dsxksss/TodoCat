import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/config/default_backgrounds.dart';
import 'package:todo_cat/widgets/video_thumbnail.dart';
import 'package:todo_cat/services/video_download_service.dart';
import 'dart:io';

/// 背景设置对话框
class BackgroundSettingDialog extends StatelessWidget {
  const BackgroundSettingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? double.infinity : 500,
      constraints: BoxConstraints(
        maxHeight: context.isPhone ? 0.8.sh : 700,
      ),
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              )
            : BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings,
                      size: 20,
                      color: context.theme.iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'backgroundSetting'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                LabelBtn(
                  label: Icon(
                    Icons.close,
                    size: 20,
                    color: context.theme.iconTheme.color,
                  ),
                  onPressed: () =>
                      SmartDialog.dismiss(tag: 'background_setting_dialog'),
                  padding: EdgeInsets.zero,
                  ghostStyle: true,
                ),
              ],
            ),
          ),
          // 可滚动内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 默认背景图片模板
                  Text(
                    'defaultBackgroundImages'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const DefaultBackgroundImageGrid(),
                  const SizedBox(height: 24),
                  
                  // 默认背景视频模板（移动端不显示）
                  if (!context.isPhone) ...[
                    Text(
                      'defaultBackgroundVideos'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const DefaultBackgroundVideoGrid(),
                    const SizedBox(height: 24),
                  ],

                  // 分隔线
                  Divider(color: context.theme.dividerColor, height: 1),
                  const SizedBox(height: 24),

                  // 当前状态
                  Obx(() {
                    final settingsCtrl = Get.find<SettingsController>();
                    final appCtrl = settingsCtrl.appCtrl;
                    final config = appCtrl.appConfig.value;
                    final isDefaultTemplate =
                        config.backgroundImagePath != null &&
                            config.backgroundImagePath!
                                .startsWith('default_template:');
                    final isCustomImage = config.backgroundImagePath != null &&
                        !isDefaultTemplate &&
                        GetPlatform.isDesktop &&
                        File(config.backgroundImagePath!).existsSync();
                    final isCustomVideo = isCustomImage &&
                        (config.backgroundImagePath!.toLowerCase().endsWith('.mp4') ||
                         config.backgroundImagePath!.toLowerCase().endsWith('.mov') ||
                         config.backgroundImagePath!.toLowerCase().endsWith('.avi') ||
                         config.backgroundImagePath!.toLowerCase().endsWith('.mkv') ||
                         config.backgroundImagePath!.toLowerCase().endsWith('.webm'));
                    final isDefaultVideo = isDefaultTemplate &&
                        DefaultBackgrounds.getById(config.backgroundImagePath!.split(':').last)?.isVideo == true;
                    final hasBackground = isDefaultTemplate || isCustomImage;
                    // 移动端不支持视频背景，如果当前是视频背景，则视为无背景
                    final isVideo = context.isPhone ? false : (isCustomVideo || isDefaultVideo);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 显示自定义图片或视频缩略图（如果有）
                        if (isCustomImage) ...[
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.theme.dividerColor,
                                width: 0.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7.5),
                              child: _buildCustomBackgroundPreview(
                                context,
                                config.backgroundImagePath!,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // 显示默认模板预览（如果是默认模板）
                        if (isDefaultTemplate) ...[
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.theme.dividerColor,
                                width: 0.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7.5),
                              child: _buildDefaultTemplatePreview(
                                context,
                                config.backgroundImagePath!.split(':').last,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.theme.dividerColor,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasBackground
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                size: 18,
                                color: hasBackground
                                    ? Colors.green
                                    : context.theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hasBackground
                                      ? (isDefaultTemplate
                                          ? 'defaultTemplateApplied'.tr
                                          : (isVideo
                                              ? 'backgroundVideoSet'.tr
                                              : 'backgroundImageSet'.tr))
                                      : 'backgroundImageNotSet'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  // 背景设置调节
                  Obx(() {
                    final settingsCtrl = Get.find<SettingsController>();
                    final config = settingsCtrl.appCtrl.appConfig.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 透明度设置
                        Text(
                          'opacity'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OpacitySlider(
                          value: config.backgroundImageOpacity,
                          onChanged: (value) {
                            settingsCtrl.appCtrl.appConfig.value =
                                config.copyWith(backgroundImageOpacity: value);
                            settingsCtrl.appCtrl.appConfig.refresh();
                          },
                        ),
                        const SizedBox(height: 12),

                        // 模糊度设置
                        Text(
                          'blur'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlurSlider(
                          value: config.backgroundImageBlur,
                          onChanged: (value) {
                            settingsCtrl.appCtrl.appConfig.value =
                                config.copyWith(backgroundImageBlur: value);
                            settingsCtrl.appCtrl.appConfig.refresh();
                          },
                        ),
                        const SizedBox(height: 12),

                        // 影响导航栏开关
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.table_bar,
                                    size: 18,
                                    color: context
                                        .theme.textTheme.bodySmall?.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'affectsNavBar'.tr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: context
                                            .theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: config.backgroundAffectsNavBar,
                              onChanged: (value) {
                                settingsCtrl.appCtrl.appConfig.value = config
                                    .copyWith(backgroundAffectsNavBar: value);
                                settingsCtrl.appCtrl.appConfig.refresh();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  // 操作按钮
                  Obx(() {
                    final settingsCtrl = Get.find<SettingsController>();
                    final config = settingsCtrl.appCtrl.appConfig.value;
                    final isDefaultTemplate =
                        config.backgroundImagePath != null &&
                            config.backgroundImagePath!
                                .startsWith('default_template:');
                    final isCustomImage = config.backgroundImagePath != null &&
                        !isDefaultTemplate &&
                        config.backgroundImagePath!.isNotEmpty &&
                        GetPlatform.isDesktop &&
                        File(config.backgroundImagePath!).existsSync();
                    final hasBackground = isDefaultTemplate || isCustomImage;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: LabelBtn(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.image, size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Flexible(
                                    child: Text(
                                  'selectBackground'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                )),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            onPressed: () async {
                              // 先关闭dialog
                              SmartDialog.dismiss(
                                  tag: 'background_setting_dialog');
                              // 等待dialog完全关闭
                              await Future.delayed(
                                  const Duration(milliseconds: 300));
                              await settingsCtrl.selectBackgroundImage();
                            },
                          ),
                        ),
                        if (hasBackground) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: LabelBtn(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.delete_outline, size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                      child: Text('clearBackground'.tr,
                                          textAlign: TextAlign.center)),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              ghostStyle: true,
                              onPressed: () async {
                                // 先关闭dialog
                                SmartDialog.dismiss(
                                    tag: 'background_setting_dialog');
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                await settingsCtrl.clearBackgroundImage();
                              },
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建自定义背景预览（支持图片和视频）
  Widget _buildCustomBackgroundPreview(BuildContext context, String path) {
    final isVideo = path.toLowerCase().endsWith('.mp4') ||
                   path.toLowerCase().endsWith('.mov') ||
                   path.toLowerCase().endsWith('.avi') ||
                   path.toLowerCase().endsWith('.mkv') ||
                   path.toLowerCase().endsWith('.webm');
    
    if (isVideo) {
      return VideoThumbnail(
        videoPath: path,
        fit: BoxFit.cover,
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam,
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  '视频文件',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey.shade400,
            ),
          );
        },
      );
    }
  }
  
  /// 构建默认模板预览
  Widget _buildDefaultTemplatePreview(BuildContext context, String templateId) {
    final template = DefaultBackgrounds.getById(templateId);
    if (template == null) {
      return Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey.shade400,
        ),
      );
    }
    
    // 如果是视频，显示视频缩略图
    if (template.isVideo) {
      // 如果有downloadUrl，优先使用缓存路径，否则使用URL
      if (template.downloadUrl != null) {
        return FutureBuilder<String?>(
          future: VideoDownloadService().getCachedVideoPath(template.downloadUrl!),
          builder: (context, snapshot) {
            // 无论是否已缓存，都先尝试从URL获取缩略图（如果缓存路径不存在）
            final cachedPath = snapshot.data;
            final videoPath = cachedPath ?? template.downloadUrl!;
            
            return VideoThumbnail(
              videoPath: videoPath,
              fit: BoxFit.cover,
              placeholder: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam,
                        size: 40,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '视频',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        // 没有downloadUrl，使用原路径（assets中的视频）
        return VideoThumbnail(
          videoPath: template.imageUrl,
          fit: BoxFit.cover,
          placeholder: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '视频',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    
    // 加载本地图片
    return Image.asset(
      template.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey.shade400,
          ),
        );
      },
    );
  }
}

/// 默认背景图片模板网格
class DefaultBackgroundImageGrid extends StatelessWidget {
  const DefaultBackgroundImageGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final settingsCtrl = Get.find<SettingsController>();
      final config = settingsCtrl.appCtrl.appConfig.value;
      final currentTemplateId =
          config.backgroundImagePath?.startsWith('default_template:') ?? false
              ? config.backgroundImagePath!.split(':').last
              : null;

      // 过滤出图片模板
      final imageTemplates = DefaultBackgrounds.templates
          .where((template) => !template.isVideo)
          .toList();

      if (imageTemplates.isEmpty) {
        return const SizedBox.shrink();
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: imageTemplates.length,
        itemBuilder: (context, index) {
          final template = imageTemplates[index];
          final isSelected = currentTemplateId == template.id;

          return GestureDetector(
            onTap: () async {
              // 应用模板
              await settingsCtrl.selectDefaultBackground(template.id);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? context.theme.primaryColor
                      : Colors.transparent,
                  width: isSelected ? 2 : 0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 图片背景
                    _buildImagePlaceholder(template.id),
                    // 选中指示器
                    if (isSelected)
                      Container(
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.theme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildImagePlaceholder(String templateId) {
    // 从模板数据获取图片路径
    final template = DefaultBackgrounds.templates.firstWhere(
      (bg) => bg.id == templateId,
      orElse: () => const DefaultBackground(
        id: '',
        name: '',
        description: '',
        imageUrl: 'assets/imgs/background_1.jpg',
      ),
    );

    // 加载本地图片
    return Image.asset(
      template.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey.shade400,
          ),
        );
      },
    );
  }
}

/// 默认背景视频模板网格
class DefaultBackgroundVideoGrid extends StatefulWidget {
  const DefaultBackgroundVideoGrid({super.key});

  @override
  State<DefaultBackgroundVideoGrid> createState() => _DefaultBackgroundVideoGridState();
}

class _DefaultBackgroundVideoGridState extends State<DefaultBackgroundVideoGrid> {
  final VideoDownloadService _downloadService = VideoDownloadService();
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};
  final Map<String, bool> _isCached = {};

  @override
  void initState() {
    super.initState();
    _checkCachedVideos();
  }

  Future<void> _checkCachedVideos() async {
    final videoTemplates = DefaultBackgrounds.templates
        .where((template) => template.isVideo && template.downloadUrl != null)
        .toList();

    for (final template in videoTemplates) {
      if (template.downloadUrl != null) {
        final cached = await _downloadService.isVideoCached(template.downloadUrl!);
        if (mounted) {
          setState(() {
            _isCached[template.id] = cached;
          });
        }
      }
    }
  }

  Future<void> _downloadVideo(DefaultBackground template) async {
    if (template.downloadUrl == null) return;

    setState(() {
      _isDownloading[template.id] = true;
      _downloadProgress[template.id] = 0.0;
    });

    await _downloadService.downloadVideo(
      template.downloadUrl!,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress[template.id] = progress;
          });
        }
      },
      onComplete: (filePath) {
        if (mounted) {
          setState(() {
            _isDownloading[template.id] = false;
            _isCached[template.id] = true;
            _downloadProgress[template.id] = 1.0;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isDownloading[template.id] = false;
            _downloadProgress[template.id] = 0.0;
          });
          // 如果是取消操作，不显示错误提示
          if (error != '下载已取消') {
            Get.snackbar(
              'downloadFailed'.tr,
              error,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 过滤出视频模板（在 build 外部，避免每次重建）
    final videoTemplates = DefaultBackgrounds.templates
        .where((template) => template.isVideo)
        .toList();

    if (videoTemplates.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: videoTemplates.length,
      itemBuilder: (context, index) {
        final template = videoTemplates[index];
        return _VideoGridItem(
          key: ValueKey(template.id),
          template: template,
          downloadService: _downloadService,
          isCached: _isCached[template.id] == true,
          isDownloading: _isDownloading[template.id] == true,
          downloadProgress: _downloadProgress[template.id] ?? 0.0,
          onDownload: () => _downloadVideo(template),
        );
      },
    );
  }

}

/// 带防抖的透明度滑块
class OpacitySlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const OpacitySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<OpacitySlider> createState() => _OpacitySliderState();
}

class _OpacitySliderState extends State<OpacitySlider> {
  late double _currentValue;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(OpacitySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
    }
  }

  void _onChanged(double value) {
    setState(() {
      _currentValue = value;
    });

    // 防抖处理
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _currentValue.clamp(0.0, 1.0),
            min: 0.0,
            max: 1.0,
            divisions: 20,
            label: '${(_currentValue * 100).toStringAsFixed(0)}%',
            onChanged: _onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${(_currentValue * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color: context.theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}

/// 带防抖的模糊度滑块
class BlurSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const BlurSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<BlurSlider> createState() => _BlurSliderState();
}

class _BlurSliderState extends State<BlurSlider> {
  late double _currentValue;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(BlurSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
    }
  }

  void _onChanged(double value) {
    setState(() {
      _currentValue = value;
    });

    // 防抖处理
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _currentValue.clamp(0.0, 20.0),
            min: 0.0,
            max: 20.0,
            divisions: 40,
            label: _currentValue.toStringAsFixed(1),
            onChanged: _onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            _currentValue.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              color: context.theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}

/// 视频网格项组件（独立组件，避免整个 GridView 重建）
class _VideoGridItem extends StatelessWidget {
  final DefaultBackground template;
  final VideoDownloadService downloadService;
  final bool isCached;
  final bool isDownloading;
  final double downloadProgress;
  final VoidCallback onDownload;

  const _VideoGridItem({
    super.key,
    required this.template,
    required this.downloadService,
    required this.isCached,
    required this.isDownloading,
    required this.downloadProgress,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    // 只监听当前选中的模板ID，而不是整个 appConfig
    return Obx(() {
      final settingsCtrl = Get.find<SettingsController>();
      final config = settingsCtrl.appCtrl.appConfig.value;
      final currentTemplateId =
          config.backgroundImagePath?.startsWith('default_template:') ?? false
              ? config.backgroundImagePath!.split(':').last
              : null;
      final isSelected = currentTemplateId == template.id;
      final needsDownload = template.downloadUrl != null && !isCached;

      return GestureDetector(
        onTap: needsDownload && !isDownloading
            ? null
            : () async {
                // 如果有downloadUrl，需要先检查是否已缓存
                if (template.downloadUrl != null) {
                  final cached = await downloadService.isVideoCached(template.downloadUrl!);
                  if (!cached) {
                    // 未缓存，不能应用
                    return;
                  }
                }
                // 应用模板
                await settingsCtrl.selectDefaultBackground(template.id);
              },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? context.theme.primaryColor
                  : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 视频背景或缩略图
                _buildVideoPlaceholder(),
                // 下载按钮或进度条
                if (needsDownload)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: isDownloading
                          ? _buildDownloadProgressWithCancel(context, downloadProgress)
                          : _buildDownloadButton(context),
                    ),
                  ),
                // 选中指示器
                if (isSelected && !needsDownload)
                  Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.theme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildVideoPlaceholder() {
    // 使用稳定的 key，避免频繁重建
    final stableKey = ValueKey('${template.id}_${isCached ? 'cached' : 'url'}');
    
    // 如果有downloadUrl，需要检查是否已缓存
    if (template.downloadUrl != null) {
      // 如果已缓存，使用缓存路径显示缩略图
      if (isCached) {
        // 使用 FutureBuilder 但缓存 future，避免每次重建都创建新的 future
        return FutureBuilder<String?>(
          key: stableKey,
          future: downloadService.getCachedVideoPath(template.downloadUrl!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPlaceholder();
            }
            final cachedPath = snapshot.data;
            if (cachedPath != null) {
              return VideoThumbnail(
                key: ValueKey('${template.id}_cached'),
                videoPath: cachedPath,
                fit: BoxFit.cover,
                placeholder: _buildPlaceholder(),
              );
            }
            // 如果缓存路径获取失败，尝试使用URL获取缩略图
            return VideoThumbnail(
              key: ValueKey('${template.id}_url'),
              videoPath: template.downloadUrl!,
              fit: BoxFit.cover,
              placeholder: _buildPlaceholder(),
            );
          },
        );
      } else {
        // 未下载，直接从URL获取缩略图
        return VideoThumbnail(
          key: stableKey,
          videoPath: template.downloadUrl!,
          fit: BoxFit.cover,
          placeholder: _buildPlaceholder(),
        );
      }
    }

    // 没有downloadUrl，使用原路径（assets中的视频）
    return VideoThumbnail(
      key: stableKey,
      videoPath: template.imageUrl,
      fit: BoxFit.cover,
      placeholder: _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 40,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              '视频',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadProgress(BuildContext context, double progress) {
    final theme = Get.theme;
    final isDark = theme.brightness == Brightness.dark;
    const progressColor = Colors.blueAccent;
    final backgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final progressBgColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final percentage = (progress * 100).toInt();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 圆圈进度条
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: progress,
              ),
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              builder: (context, animatedProgress, child) {
                return CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: 3.0,
                  backgroundColor: progressBgColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(progressColor),
                );
              },
            ),
          ),
          // 百分比数字显示在中心
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgressWithCancel(BuildContext context, double progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDownloadProgress(context, progress),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (template.downloadUrl != null) {
              downloadService.cancelDownload(template.downloadUrl!);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stop,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'stop'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return GestureDetector(
      onTap: onDownload,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.theme.primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.download,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'download'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
