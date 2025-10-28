import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/controllers/settings_ctr.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'dart:io';

/// 背景设置对话框
class BackgroundSettingDialog extends StatelessWidget {
  const BackgroundSettingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 0.9.sw : 500,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.dialogBackgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
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
                onPressed: () => SmartDialog.dismiss(tag: 'background_setting_dialog'),
                color: context.theme.iconTheme.color,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 当前状态
          Obx(() {
            final settingsCtrl = Get.find<SettingsController>();
            final appCtrl = settingsCtrl.appCtrl;
            final config = appCtrl.appConfig.value;
            final hasBackground = config.backgroundImagePath != null && 
                                    File(config.backgroundImagePath!).existsSync();
            
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
                    hasBackground ? Icons.check_circle : Icons.info_outline,
                    size: 18,
                    color: hasBackground ? Colors.green : context.theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasBackground ? 'backgroundImageSet'.tr : 'backgroundImageNotSet'.tr,
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
                            color: context.theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'affectsNavBar'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: config.backgroundAffectsNavBar,
                      onChanged: (value) {
                        settingsCtrl.appCtrl.appConfig.value = 
                            config.copyWith(backgroundAffectsNavBar: value);
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
            final hasBackground = config.backgroundImagePath != null &&
                config.backgroundImagePath!.isNotEmpty &&
                File(config.backgroundImagePath!).existsSync();
            
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
                        Flexible(child: Text('selectBackground'.tr, textAlign: TextAlign.center)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    onPressed: () async {
                      // 先关闭dialog
                      SmartDialog.dismiss(tag: 'background_setting_dialog');
                      // 等待dialog完全关闭
                      await Future.delayed(const Duration(milliseconds: 300));
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
                          Flexible(child: Text('clearBackground'.tr, textAlign: TextAlign.center)),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ghostStyle: true,
                      onPressed: () async {
                        // 先关闭dialog
                        SmartDialog.dismiss(tag: 'background_setting_dialog');
                        await Future.delayed(const Duration(milliseconds: 200));
                        await settingsCtrl.clearBackgroundImage();
                      },
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
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

