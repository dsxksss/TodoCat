import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:TodoCat/widgets/label_btn.dart';
import 'package:TodoCat/controllers/settings_ctr.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:TodoCat/config/default_backgrounds.dart';
import 'dart:io';

/// 背景设置对话框
class BackgroundSettingDialog extends StatelessWidget {
  const BackgroundSettingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 0.9.sw : 500,
      constraints: BoxConstraints(
        maxHeight: context.isPhone ? 0.8.sh : 700,
      ),
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
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
                      Icons.image,
                      size: 20,
                      color: context.theme.iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'backgroundImage'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () =>
                      SmartDialog.dismiss(tag: 'background_setting_dialog'),
                  color: context.theme.iconTheme.color,
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
                  // 默认模板选择区域
                  Text(
                    'defaultBackgrounds'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const DefaultBackgroundGrid(),
                  const SizedBox(height: 24),

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
                    final hasBackground = isDefaultTemplate || isCustomImage;

                    return Container(
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
                                      : 'backgroundImageSet'.tr)
                                  : 'backgroundImageNotSet'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                const Icon(Icons.image, size: 18),
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
}

/// 默认背景模板网格
class DefaultBackgroundGrid extends StatelessWidget {
  const DefaultBackgroundGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final settingsCtrl = Get.find<SettingsController>();
      final config = settingsCtrl.appCtrl.appConfig.value;
      final currentTemplateId =
          config.backgroundImagePath?.startsWith('default_template:') ?? false
              ? config.backgroundImagePath!.split(':').last
              : null;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: DefaultBackgrounds.templates.length,
        itemBuilder: (context, index) {
          final template = DefaultBackgrounds.templates[index];
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
