import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:todo_cat/config/template_generator.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/custom_template.dart';
import 'package:todo_cat/data/services/repositorys/custom_template.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/utils/font_utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/pages/home/components/task/task_card.dart';
import 'dart:io';
import 'dart:ui';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/config/default_backgrounds.dart';
import 'package:todo_cat/widgets/video_background.dart';
import 'package:todo_cat/services/video_download_service.dart';
import 'package:todo_cat/widgets/platform_dialog_wrapper.dart';
import 'package:todo_cat/services/llm_template_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum TaskTemplateType {
  empty, // 空模板
  content, // 学生日程模板
  work, // 工作管理模板
  fitness, // 健身训练模板
  travel, // 旅行计划模板
}

class TemplateSelectorDialog extends StatefulWidget {
  final Function(TaskTemplateType) onTemplateSelected;
  final Function(CustomTemplate)? onCustomTemplateSelected;

  const TemplateSelectorDialog({
    Key? key,
    required this.onTemplateSelected,
    this.onCustomTemplateSelected,
  }) : super(key: key);

  @override
  State<TemplateSelectorDialog> createState() => _TemplateSelectorDialogState();
}

class _TemplateSelectorDialogState extends State<TemplateSelectorDialog> {
  List<CustomTemplate> _customTemplates = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTemplates();
  }

  Future<void> _loadCustomTemplates() async {
    try {
      final repository = await CustomTemplateRepository.getInstance();
      final templates = await repository.readAll();
      if (mounted) {
        setState(() {
          _customTemplates = templates;
        });
      }
    } catch (e) {
      // 加载失败，保持空列表
    }
  }

  void _handleAiGenerate() {
    SmartDialog.show(
      tag: 'ai_template_input',
      alignment: Alignment.center,
      animationType: SmartAnimationType.fade, // Disable default scale
      clickMaskDismiss: false,
      animationTime: 150.ms,
      builder: (_) {
        return _AiTemplateGeneratorPopup(
          onCancel: () => SmartDialog.dismiss(tag: 'ai_template_input'),
          onGenerate: (prompt) {
            if (prompt.isNotEmpty) {
              SmartDialog.dismiss(tag: 'ai_template_input');
              _generateTemplate(prompt);
            }
          },
        );
      },
      animationBuilder: (controller, child, _) => child
          .animate(controller: controller)
          .fade(duration: controller.duration)
          .scaleXY(
            begin: 0.99,
            duration: controller.duration,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  Future<void> _generateTemplate(String prompt) async {
    SmartDialog.show(
        tag: 'loading_ai',
        clickMaskDismiss: false,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.blue)),
                const SizedBox(height: 24),
                Text(
                  "AI 正在为你规划...",
                  style: FontUtils.getMediumStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "正在生成任务清单与详细步骤",
                  style: TextStyle(
                      fontSize: 13,
                      color: context.theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.6)),
                ),
              ],
            ),
          );
        });

    try {
      if (!Get.isRegistered<LlmTemplateService>()) {
        Get.put(LlmTemplateService());
      }

      final template = await LlmTemplateService.to.generateTemplate(prompt);
      SmartDialog.dismiss(tag: 'loading_ai');

      if (template != null) {
        _showCustomTemplatePreview(template);
      } else {
        SmartDialog.showToast("生成失败，请重试");
      }
    } catch (e) {
      SmartDialog.dismiss(tag: 'loading_ai');
      SmartDialog.showToast("发生错误: $e");
    }
  }

  void _showCustomTemplatePreview(CustomTemplate template) {
    PlatformDialogWrapper.show(
      tag: 'generated_template_preview',
      content: _GeneratedTemplatePreview(
        template: template,
        onApply: () {
          SmartDialog.dismiss(tag: 'generated_template_preview');
          _showConfirmDialogForCustom(context, template, false);
        },
        onCancel: () {
          SmartDialog.dismiss(tag: 'generated_template_preview');
        },
      ),
      maskColor: Colors.black.withOpacity(0.3),
      clickMaskDismiss: true,
      useSystem: false,
      useFixedSize: false,
    );
  }

  Widget _buildAiGenerateOption(BuildContext context) {
    return GestureDetector(
      onTap: _handleAiGenerate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.theme.dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: context.theme.cardColor,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI 智能生成",
                    style: FontUtils.getMediumStyle(
                        fontSize: 16,
                        color: context.theme.textTheme.bodyLarge?.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "输入描述，AI 帮你生成专属任务模板",
                    style: FontUtils.getTextStyle(
                        fontSize: 13,
                        color: context.theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16,
                color: context.theme.textTheme.bodyMedium?.color
                    ?.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        border: Border.all(width: 0.3, color: context.theme.dividerColor),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.theme.dividerColor,
                  width: 0.3,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'selectTaskTemplate'.tr,
                  style: FontUtils.getBoldStyle(fontSize: 20),
                ),
                LabelBtn(
                  ghostStyle: true,
                  label: Text('cancel'.tr),
                  onPressed: () =>
                      SmartDialog.dismiss(tag: 'template_selector'),
                ),
              ],
            ),
          ),
          // 内容区域 - 使用 Expanded 和 SingleChildScrollView 使其可滚动
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 显示自定义模板（放在前面）
                  if (_customTemplates.isNotEmpty) ...[
                    Text(
                      'customTemplates'.tr,
                      style: FontUtils.getTextStyle(
                        fontSize: 14,
                        color: context.theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._customTemplates
                        .map(
                          (template) =>
                              _buildCustomTemplateOption(context, template),
                        )
                        .toList(),
                    const SizedBox(height: 24),
                    Divider(
                        color:
                            context.theme.dividerColor.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                  ],
                  // AI 生成按钮
                  _buildAiGenerateOption(context),
                  const SizedBox(height: 24),

                  Text(
                    _customTemplates.isNotEmpty
                        ? 'default'.tr
                        : 'selectTemplateType'.tr,
                    style: FontUtils.getTextStyle(
                      fontSize: 14,
                      color: context.theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTemplateOption(
                    context,
                    TaskTemplateType.empty,
                    'emptyTemplate'.tr,
                    'emptyTemplateDescription'.tr,
                    Icons.checklist_outlined,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildTemplateOption(
                    context,
                    TaskTemplateType.content,
                    'studentScheduleTemplate'.tr,
                    'studentScheduleTemplateDescription'.tr,
                    Icons.school_outlined,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildTemplateOption(
                    context,
                    TaskTemplateType.work,
                    'workManagementTemplate'.tr,
                    'workManagementTemplateDescription'.tr,
                    Icons.work_outline,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildTemplateOption(
                    context,
                    TaskTemplateType.fitness,
                    'fitnessTrainingTemplate'.tr,
                    'fitnessTrainingTemplateDescription'.tr,
                    Icons.fitness_center,
                    Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _buildTemplateOption(
                    context,
                    TaskTemplateType.travel,
                    'travelPlanTemplate'.tr,
                    'travelPlanTemplateDescription'.tr,
                    Icons.flight_takeoff,
                    Colors.teal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTemplateOption(
      BuildContext context, CustomTemplate template) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _CustomTemplateOptionWidget(
        template: template,
        onTap: (shouldClosePreview) {
          _showConfirmDialogForCustom(context, template, shouldClosePreview);
        },
        onDelete: () async {
          await _deleteCustomTemplate(template);
        },
      ),
    );
  }

  Future<void> _deleteCustomTemplate(CustomTemplate template) async {
    showToast(
      'confirmDeleteTemplate'.tr,
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.error,
      onYesCallback: () async {
        try {
          if (template.id == null) return;
          final repository = await CustomTemplateRepository.getInstance();
          await repository.delete(template.id!);
          showSuccessNotification('templateDeleted'.tr);
          // 重新加载列表
          await _loadCustomTemplates();
        } catch (e) {
          showErrorNotification('Error: $e');
        }
      },
    );
  }

  void _showConfirmDialogForCustom(
      BuildContext context, CustomTemplate template, bool shouldClosePreview) {
    // 检查当前工作空间是否有任务
    bool hasTasks = false;
    if (Get.isRegistered<HomeController>()) {
      try {
        final homeCtrl = Get.find<HomeController>();
        hasTasks = homeCtrl.tasks.isNotEmpty;
      } catch (e) {
        // 如果获取失败，默认显示确认对话框
        hasTasks = true;
      }
    }

    // 如果没有任务，直接应用模板，不显示确认提示
    if (!hasTasks) {
      widget.onCustomTemplateSelected?.call(template);
      SmartDialog.dismiss(tag: 'template_selector');
      if (shouldClosePreview) {
        SmartDialog.dismiss(tag: 'custom_template_preview_${template.id}');
      }
      // 关闭空任务提示 toast
      SmartDialog.dismiss(tag: 'empty_task_prompt');
      showSuccessNotification("taskTemplateApplied".tr);
      return;
    }

    // 如果有任务，显示确认对话框
    showToast(
      "${'confirmApplyTemplate'.tr}「${template.name}」",
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.warning,
      tag: 'template_confirm_custom_${template.id}', // 使用唯一的 tag
      onYesCallback: () {
        widget.onCustomTemplateSelected?.call(template);
        SmartDialog.dismiss(tag: 'template_selector');
        if (shouldClosePreview) {
          SmartDialog.dismiss(tag: 'custom_template_preview_${template.id}');
        }
        // 关闭空任务提示 toast
        SmartDialog.dismiss(tag: 'empty_task_prompt');
        showSuccessNotification("taskTemplateApplied".tr);
      },
    );
  }

  Widget _buildTemplateOption(
    BuildContext context,
    TaskTemplateType type,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return _TemplateOptionWithPreview(
      type: type,
      title: title,
      description: description,
      icon: icon,
      color: color,
      onTap: (shouldClosePreview) {
        _showConfirmDialog(context, type, title, shouldClosePreview);
      },
    );
  }

  void _showConfirmDialog(BuildContext context, TaskTemplateType type,
      String title, bool shouldClosePreview) {
    // 检查当前工作空间是否有任务
    bool hasTasks = false;
    if (Get.isRegistered<HomeController>()) {
      try {
        final homeCtrl = Get.find<HomeController>();
        hasTasks = homeCtrl.tasks.isNotEmpty;
      } catch (e) {
        // 如果获取失败，默认显示确认对话框
        hasTasks = true;
      }
    }

    // 如果没有任务，直接应用模板，不显示确认提示
    if (!hasTasks) {
      widget.onTemplateSelected(type);
      SmartDialog.dismiss(tag: 'template_selector');
      if (shouldClosePreview) {
        SmartDialog.dismiss(tag: 'template_preview_$type');
      }
      // 关闭空任务提示 toast
      SmartDialog.dismiss(tag: 'empty_task_prompt');
      showSuccessNotification("taskTemplateApplied".tr);
      return;
    }

    // 如果有任务，显示确认对话框
    showToast(
      "${'confirmApplyTemplate'.tr}「$title」",
      confirmMode: true,
      alwaysShow: true,
      toastStyleType: TodoCatToastStyleType.warning,
      tag: 'template_confirm_$type', // 使用唯一的 tag
      onYesCallback: () {
        widget.onTemplateSelected(type);
        SmartDialog.dismiss(tag: 'template_selector');
        if (shouldClosePreview) {
          SmartDialog.dismiss(tag: 'template_preview_$type');
        }
        // 关闭空任务提示 toast
        SmartDialog.dismiss(tag: 'empty_task_prompt');
        showSuccessNotification("taskTemplateApplied".tr);
      },
    );
  }
}

/// 自定义模板选项组件
class _CustomTemplateOptionWidget extends StatefulWidget {
  final CustomTemplate template;
  final Function(bool) onTap;
  final VoidCallback onDelete;

  const _CustomTemplateOptionWidget({
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_CustomTemplateOptionWidget> createState() =>
      _CustomTemplateOptionWidgetState();
}

class _CustomTemplateOptionWidgetState
    extends State<_CustomTemplateOptionWidget> {
  bool _isPreviewShowing = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPreview() {
    if (_isPreviewShowing) return;

    _isPreviewShowing = true;

    PlatformDialogWrapper.show(
      tag: 'custom_template_preview_${widget.template.id}',
      content: _buildPreviewOverlay(),
      maskColor: Colors.black.withValues(alpha: 0.3),
      clickMaskDismiss: true,
      useSystem: false,
      useFixedSize: false,
      onDismiss: () {
        _isPreviewShowing = false;
      },
    );
  }

  void _hidePreview() {
    if (!_isPreviewShowing) return;

    SmartDialog.dismiss(tag: 'custom_template_preview_${widget.template.id}');
    _isPreviewShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isPreviewShowing) {
          _showPreview();
        } else {
          _hidePreview();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.theme.dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: context.theme.cardColor,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bookmark,
                color: Colors.deepPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template.name,
                    style: FontUtils.getMediumStyle(
                      fontSize: 16,
                      color: context.theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (widget.template.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.template.description!,
                      style: FontUtils.getTextStyle(
                        fontSize: 13,
                        color: context.theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red,
              onPressed: widget.onDelete,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.theme.textTheme.bodyMedium?.color
                  ?.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewOverlay() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: _buildPreview(),
        ),
      ],
    );
  }

  void _applyTemplate() {
    widget.onTap(true);
  }

  Widget _buildPreview() {
    final templates = widget.template.getTasks();

    // 计算对话框宽度：屏幕宽度的90%，最大不超过1600（约6个卡片）
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = (screenWidth * 0.9).clamp(800.0, 1600.0);

    // 获取背景设置
    final appCtrl = Get.find<AppController>();
    final backgroundImagePath = appCtrl.appConfig.value.backgroundImagePath;
    final isDefaultTemplate = backgroundImagePath != null &&
        backgroundImagePath.startsWith('default_template:');
    final isCustomImage = backgroundImagePath != null &&
        !isDefaultTemplate &&
        backgroundImagePath.isNotEmpty &&
        GetPlatform.isDesktop &&
        File(backgroundImagePath).existsSync();
    final hasBackground = isDefaultTemplate || isCustomImage;
    final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
    final blur = appCtrl.appConfig.value.backgroundImageBlur;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: maxWidth,
        height: 640,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: context.theme.dialogTheme.backgroundColor,
          border: Border.all(width: 1, color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // 背景图片层
              if (hasBackground)
                Positioned.fill(
                  child: Opacity(
                    opacity: opacity,
                    child: _getBackgroundWidget(backgroundImagePath),
                  ),
                ),
              // 模糊层
              if (hasBackground && blur > 0)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blur,
                      sigmaY: blur,
                    ),
                    child:
                        Container(color: Colors.white.withValues(alpha: 0.0)),
                  ),
                ),
              // 内容层
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              context.theme.dividerColor.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'templatePreview'.tr,
                          style: FontUtils.getBoldStyle(fontSize: 18),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LabelBtn(
                              label: Text('apply'.tr,
                                  style: const TextStyle(color: Colors.white)),
                              onPressed: _applyTemplate,
                              bgColor: Colors.lightBlue,
                            ),
                            const SizedBox(width: 12),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _hidePreview,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: context.theme.dividerColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: context
                                        .theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 预览内容 - 水平滚动
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...templates
                                .map((task) => Padding(
                                      padding: const EdgeInsets.only(right: 50),
                                      child: _buildPreviewTaskCard(task),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取背景装饰
  Widget _getBackgroundWidget(String? backgroundPath) {
    // 获取背景设置
    final appCtrl = Get.find<AppController>();
    final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
    final blur = appCtrl.appConfig.value.backgroundImageBlur;

    // 检查是否是默认模板
    if (backgroundPath != null &&
        backgroundPath.startsWith('default_template:')) {
      final templateId = backgroundPath.split(':').last;
      final template = DefaultBackgrounds.getById(templateId);

      if (template != null) {
        // 检查是否为视频模板
        if (template.isVideo) {
          // 如果有downloadUrl，优先使用缓存路径，否则使用URL
          if (template.downloadUrl != null) {
            return FutureBuilder<String?>(
              future: VideoDownloadService()
                  .getCachedVideoPath(template.downloadUrl!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(color: Colors.black);
                }
                // 如果已缓存，使用缓存路径；否则使用URL（VideoBackground现在支持网络URL）
                final videoPath = snapshot.data ?? template.downloadUrl!;
                return VideoBackground(
                  videoPath: videoPath,
                  opacity: opacity,
                  blur: blur,
                );
              },
            );
          } else {
            // 没有downloadUrl，使用原路径（assets中的视频）
            return VideoBackground(
              videoPath: template.imageUrl,
              opacity: opacity,
              blur: blur,
            );
          }
        } else {
          // 使用本地图片
          final imageUrl = template.imageUrl;
          return Opacity(
            opacity: opacity,
            child: ClipRect(
              child: blur > 0
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                      ),
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // 回退到渐变占位符
                          final colors = _getGradientColors(templateId);
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: colors,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 回退到渐变占位符
                        final colors = _getGradientColors(templateId);
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        }
      } else {
        // 回退到渐变
        final colors = _getGradientColors(templateId);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        );
      }
    } else {
      // 自定义图片或视频
      if (backgroundPath != null &&
          GetPlatform.isDesktop &&
          File(backgroundPath).existsSync()) {
        final isVideo = backgroundPath.toLowerCase().endsWith('.mp4') ||
            backgroundPath.toLowerCase().endsWith('.mov') ||
            backgroundPath.toLowerCase().endsWith('.avi') ||
            backgroundPath.toLowerCase().endsWith('.mkv') ||
            backgroundPath.toLowerCase().endsWith('.webm');

        if (isVideo) {
          // 使用视频背景播放
          return VideoBackground(
            videoPath: backgroundPath,
            opacity: opacity,
            blur: blur,
          );
        } else {
          // 自定义图片
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(backgroundPath)),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      } else {
        return Container();
      }
    }
  }

  /// 获取渐变颜色（用作占位符）
  List<Color> _getGradientColors(String templateId) {
    return [Colors.grey.shade300, Colors.grey.shade400];
  }

  Widget _buildPreviewTaskCard(Task task) {
    return IgnorePointer(
      child: TaskCard(task: task),
    );
  }
}

/// 创建指定类型的任务模板（使用多语言支持的TemplateGenerator）
List<Task> createTaskTemplate(TaskTemplateType type) {
  switch (type) {
    case TaskTemplateType.empty:
      return TemplateGenerator.getEmptyTemplate();

    case TaskTemplateType.content:
      return TemplateGenerator.getStudentTemplate();

    case TaskTemplateType.work:
      return TemplateGenerator.getWorkTemplate();

    case TaskTemplateType.fitness:
      return TemplateGenerator.getFitnessTemplate();

    case TaskTemplateType.travel:
      return TemplateGenerator.getTravelTemplate();
  }
}

/// 带预览的模板选项组件
class _TemplateOptionWithPreview extends StatefulWidget {
  final TaskTemplateType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Function(bool) onTap;

  const _TemplateOptionWithPreview({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TemplateOptionWithPreview> createState() =>
      _TemplateOptionWithPreviewState();
}

class _TemplateOptionWithPreviewState
    extends State<_TemplateOptionWithPreview> {
  bool _isPreviewShowing = false;
  final GlobalKey _key = GlobalKey();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPreview() {
    if (_isPreviewShowing) return;

    _isPreviewShowing = true;

    PlatformDialogWrapper.show(
      tag: 'template_preview_${widget.type}',
      content: _buildPreviewOverlay(),
      maskColor: Colors.black.withValues(alpha: 0.3),
      clickMaskDismiss: true,
      useSystem: false, // 使用系统overlay，降低层级
      useFixedSize: false,
      onDismiss: () {
        _isPreviewShowing = false;
      },
    );
  }

  void _hidePreview() {
    if (!_isPreviewShowing) return;

    SmartDialog.dismiss(tag: 'template_preview_${widget.type}');
    _isPreviewShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: () {
        if (!_isPreviewShowing) {
          _showPreview();
        } else {
          _hidePreview();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.theme.dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: context.theme.cardColor,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: FontUtils.getMediumStyle(
                      fontSize: 16,
                      color: context.theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: FontUtils.getTextStyle(
                      fontSize: 13,
                      color: context.theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.theme.textTheme.bodyMedium?.color
                  ?.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewOverlay() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: _buildPreview(),
        ),
      ],
    );
  }

  void _applyTemplate() {
    widget.onTap(true); // 从预览窗口应用，需要关闭预览窗口
  }

  Widget _buildPreview() {
    final templates = _getTemplateData();

    // 计算对话框宽度：屏幕宽度的90%，最大不超过1600（约6个卡片）
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = (screenWidth * 0.9).clamp(800.0, 1600.0);

    // 获取背景设置
    final appCtrl = Get.find<AppController>();
    final backgroundImagePath = appCtrl.appConfig.value.backgroundImagePath;
    final isDefaultTemplate = backgroundImagePath != null &&
        backgroundImagePath.startsWith('default_template:');
    final isCustomImage = backgroundImagePath != null &&
        !isDefaultTemplate &&
        backgroundImagePath.isNotEmpty &&
        GetPlatform.isDesktop &&
        File(backgroundImagePath).existsSync();
    final hasBackground = isDefaultTemplate || isCustomImage;
    final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
    final blur = appCtrl.appConfig.value.backgroundImageBlur;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: maxWidth,
        height: 640,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: context.theme.dialogTheme.backgroundColor,
          border: Border.all(width: 1, color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // 背景图片层
              if (hasBackground)
                Positioned.fill(
                  child: Opacity(
                    opacity: opacity,
                    child: _getBackgroundWidget(backgroundImagePath),
                  ),
                ),
              // 模糊层
              if (hasBackground && blur > 0)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blur,
                      sigmaY: blur,
                    ),
                    child:
                        Container(color: Colors.white.withValues(alpha: 0.0)),
                  ),
                ),
              // 内容层
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              context.theme.dividerColor.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'templatePreview'.tr,
                          style: FontUtils.getBoldStyle(fontSize: 18),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LabelBtn(
                              label: Text('apply'.tr,
                                  style: const TextStyle(color: Colors.white)),
                              onPressed: _applyTemplate,
                              bgColor: Colors.lightBlue,
                            ),
                            const SizedBox(width: 12),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _hidePreview,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: context.theme.dividerColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: context
                                        .theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 预览内容 - 水平滚动
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...templates
                                .map((task) => Padding(
                                      padding: const EdgeInsets.only(right: 50),
                                      child: _buildPreviewTaskCard(task),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取背景装饰
  Widget _getBackgroundWidget(String? backgroundPath) {
    // 获取背景设置
    final appCtrl = Get.find<AppController>();
    final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
    final blur = appCtrl.appConfig.value.backgroundImageBlur;

    // 检查是否是默认模板
    if (backgroundPath != null &&
        backgroundPath.startsWith('default_template:')) {
      final templateId = backgroundPath.split(':').last;
      final template = DefaultBackgrounds.getById(templateId);

      if (template != null) {
        // 检查是否为视频模板
        if (template.isVideo) {
          // 如果有downloadUrl，优先使用缓存路径，否则使用URL
          if (template.downloadUrl != null) {
            return FutureBuilder<String?>(
              future: VideoDownloadService()
                  .getCachedVideoPath(template.downloadUrl!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(color: Colors.black);
                }
                // 如果已缓存，使用缓存路径；否则使用URL（VideoBackground现在支持网络URL）
                final videoPath = snapshot.data ?? template.downloadUrl!;
                return VideoBackground(
                  videoPath: videoPath,
                  opacity: opacity,
                  blur: blur,
                );
              },
            );
          } else {
            // 没有downloadUrl，使用原路径（assets中的视频）
            return VideoBackground(
              videoPath: template.imageUrl,
              opacity: opacity,
              blur: blur,
            );
          }
        } else {
          // 使用本地图片
          final imageUrl = template.imageUrl;
          return Opacity(
            opacity: opacity,
            child: ClipRect(
              child: blur > 0
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                      ),
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // 回退到渐变占位符
                          final colors = _getGradientColors(templateId);
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: colors,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 回退到渐变占位符
                        final colors = _getGradientColors(templateId);
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        }
      } else {
        // 回退到渐变
        final colors = _getGradientColors(templateId);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        );
      }
    } else {
      // 自定义图片或视频
      if (backgroundPath != null &&
          GetPlatform.isDesktop &&
          File(backgroundPath).existsSync()) {
        final isVideo = backgroundPath.toLowerCase().endsWith('.mp4') ||
            backgroundPath.toLowerCase().endsWith('.mov') ||
            backgroundPath.toLowerCase().endsWith('.avi') ||
            backgroundPath.toLowerCase().endsWith('.mkv') ||
            backgroundPath.toLowerCase().endsWith('.webm');

        if (isVideo) {
          // 使用视频背景播放
          return VideoBackground(
            videoPath: backgroundPath,
            opacity: opacity,
            blur: blur,
          );
        } else {
          // 自定义图片
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(backgroundPath)),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      } else {
        return Container();
      }
    }
  }

  /// 获取渐变颜色（用作占位符）
  List<Color> _getGradientColors(String templateId) {
    return [Colors.grey.shade300, Colors.grey.shade400];
  }

  Widget _buildPreviewTaskCard(Task task) {
    return IgnorePointer(
      child: TaskCard(task: task),
    );
  }

  List<Task> _getTemplateData() {
    return createTaskTemplate(widget.type);
  }
}

/// 显示模板选择对话框
void showTemplateSelectorDialog({
  required Function(TaskTemplateType) onTemplateSelected,
  Function(CustomTemplate)? onCustomTemplateSelected,
}) {
  // 使用SmartDialog确保对话框显示在最顶层
  // 使用SmartDialog确保对话框显示在最顶层
  PlatformDialogWrapper.show(
    tag: 'template_selector',
    content: TemplateSelectorDialog(
      onTemplateSelected: onTemplateSelected,
      onCustomTemplateSelected: onCustomTemplateSelected,
    ),
    width: 900,
    height: 700,
    maskColor: Colors.black.withValues(alpha: 0.5),
    clickMaskDismiss: true,
    animationTime: const Duration(milliseconds: 300),
  );
}

/// AI 模板生成弹窗
class _AiTemplateGeneratorPopup extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(String) onGenerate;

  const _AiTemplateGeneratorPopup({
    required this.onCancel,
    required this.onGenerate,
  });

  @override
  State<_AiTemplateGeneratorPopup> createState() =>
      _AiTemplateGeneratorPopupState();
}

class _GeneratedTemplatePreview extends StatefulWidget {
  final CustomTemplate template;
  final VoidCallback onApply;
  final VoidCallback onCancel;

  const _GeneratedTemplatePreview({
    required this.template,
    required this.onApply,
    required this.onCancel,
  });

  @override
  State<_GeneratedTemplatePreview> createState() =>
      _GeneratedTemplatePreviewState();
}

class _GeneratedTemplatePreviewState extends State<_GeneratedTemplatePreview> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = widget.template.getTasks();

    // 计算对话框宽度：屏幕宽度的90%，最大不超过1600（约6个卡片）
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = (screenWidth * 0.9).clamp(800.0, 1600.0);

    // 获取背景设置
    final appCtrl = Get.find<AppController>();
    final backgroundImagePath = appCtrl.appConfig.value.backgroundImagePath;
    final isDefaultTemplate = backgroundImagePath != null &&
        backgroundImagePath.startsWith('default_template:');
    final isCustomImage = backgroundImagePath != null &&
        !isDefaultTemplate &&
        backgroundImagePath.isNotEmpty &&
        GetPlatform.isDesktop &&
        File(backgroundImagePath).existsSync();
    final hasBackground = isDefaultTemplate || isCustomImage;
    final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
    final blur = appCtrl.appConfig.value.backgroundImageBlur;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: maxWidth,
          height: 640,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: context.theme.dialogTheme.backgroundColor,
            border: Border.all(width: 1, color: context.theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // 背景图片层
                if (hasBackground)
                  Positioned.fill(
                    child: Opacity(
                      opacity: opacity,
                      child: _getBackgroundWidget(backgroundImagePath),
                    ),
                  ),
                // 模糊层
                if (hasBackground && blur > 0)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                      ),
                      child: Container(color: Colors.white.withOpacity(0.0)),
                    ),
                  ),
                // 内容层
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题栏
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: context.theme.dividerColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text(
                              'AI 生成结果预览',
                              style: FontUtils.getBoldStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 12),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(widget.template.description ?? "",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.blue)))
                          ]),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LabelBtn(
                                label: Text('apply'.tr,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                onPressed: widget.onApply,
                                bgColor: Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: widget.onCancel,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: context.theme.dividerColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: context
                                          .theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 预览内容 - 水平滚动
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        scrollbarOrientation: ScrollbarOrientation.bottom,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...templates
                                  .map((task) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 50),
                                        child: SizedBox(
                                          width:
                                              300, // Enforce width for TaskCard to ensure it renders correctly in Row
                                          child: TaskCard(
                                              task: task, isPreview: true),
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 获取背景装饰 (Copied helper)
  Widget _getBackgroundWidget(String? backgroundPath) {
    // ... Reuse the logic from parent if possible, but for simplicity duplication is easier here since the parent logic is complex with methods.
    // Actually, we can just instantiate a minimal placeholder or try to reuse.
    // Let's copy the logic from _TemplateSelectorDialogState._getBackgroundWidget briefly or just simplify it since this is a transient preview.
    // To be safe and quick, I will just use a transparent placeholder if I can't access instances.
    // However, the user wants it to look "like existing", so ideally it matches the current background.

    // 获取背景设置
    final appCtrl = Get.find<AppController>();
    final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
    final blur = appCtrl.appConfig.value.backgroundImageBlur;

    // 检查是否是默认模板
    if (backgroundPath != null &&
        backgroundPath.startsWith('default_template:')) {
      final templateId = backgroundPath.split(':').last;
      final template = DefaultBackgrounds.getById(templateId);

      if (template != null) {
        // 检查是否为视频模板
        if (template.isVideo) {
          // 如果有downloadUrl，优先使用缓存路径，否则使用URL
          if (template.downloadUrl != null) {
            return FutureBuilder<String?>(
              future: VideoDownloadService()
                  .getCachedVideoPath(template.downloadUrl!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(color: Colors.black);
                }
                final videoPath = snapshot.data ?? template.downloadUrl!;
                return VideoBackground(
                  videoPath: videoPath,
                  opacity: opacity,
                  blur: blur,
                );
              },
            );
          } else {
            return VideoBackground(
              videoPath: template.imageUrl,
              opacity: opacity,
              blur: blur,
            );
          }
        } else {
          // 使用本地图片
          final imageUrl = template.imageUrl;
          return Opacity(
            opacity: opacity,
            child: ClipRect(
              child: blur > 0
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                      ),
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
          );
        }
      } else {
        return Container();
      }
    } else {
      // 自定义图片或视频
      if (backgroundPath != null &&
          GetPlatform.isDesktop &&
          File(backgroundPath).existsSync()) {
        // ... simplified
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(backgroundPath)),
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }
}

class _AiTemplateGeneratorPopupState extends State<_AiTemplateGeneratorPopup> {
  final TextEditingController _controller = TextEditingController();
  Offset _offset = Offset.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: Container(
        width: 500,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Draggable)
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _offset += details.delta;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          "AI 智能生成模板",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.close,
                              size: 16, color: Theme.of(context).dividerColor),
                          onPressed: widget.onCancel,
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText:
                              "描述你想要的任务列表，例如：\n- '为期7天的云南旅游计划'\n- '准备一场马拉松的训练计划'\n- '新房装修全流程'",
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: context.theme.dividerColor
                                    .withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: context.theme.dividerColor
                                    .withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          filled: true,
                          fillColor: context.theme.cardColor,
                        ),
                        maxLines: 4,
                        maxLength: 200,
                        autofocus: true,
                        style: TextStyle(
                            color: context.theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ),

                // Footer Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: Text("cancel".tr),
                      ),
                      const SizedBox(width: 8),
                      // AI Generate Button
                      ElevatedButton.icon(
                        onPressed: () => widget.onGenerate(_controller.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text("立即生成"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
