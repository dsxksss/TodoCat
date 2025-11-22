import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.isPhone ? 1.sw : 450,
      height: MediaQuery.of(context).size.height * 0.85, // 限制最大高度为屏幕的85%
      child: Container(
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
                          color: context.theme.dividerColor
                              .withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                    ],
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
    maskColor: Colors.black.withValues(alpha: 0.5),
    clickMaskDismiss: true,
    animationTime: const Duration(milliseconds: 300),
  );
}
