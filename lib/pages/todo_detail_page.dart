import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:TodoCat/controllers/todo_detail_ctr.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/core/utils/date_time.dart';
import 'package:TodoCat/pages/home/components/tag.dart';
import 'package:TodoCat/widgets/animation_btn.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:TodoCat/widgets/todocat_scaffold.dart';
import 'package:TodoCat/controllers/app_ctr.dart';
import 'package:TodoCat/widgets/nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import 'dart:ui';

class TodoDetailPage extends StatelessWidget {
  final String todoId;
  final String taskId;

  const TodoDetailPage({
    super.key,
    required this.todoId,
    required this.taskId,
  });

  // 预处理 markdown 文本：将旧格式的 file:// 路径转换为标准格式
  static String _preprocessMarkdown(String text) {
    if (!text.contains('file://')) {
      return text;
    }
    
    // 检查是否已经是标准格式（file:///），如果是则不需要处理
    if (text.contains('file:///') && !text.contains(RegExp(r'file://[^/]'))) {
      return text;
    }
    
    // 将 file://C:\path 格式转换为 file:///C:/path 格式
    return text.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\(file://([^)]+)\)'),
      (match) {
        final alt = match.group(1) ?? '';
        final path = match.group(2) ?? '';
        // 将反斜杠转换为正斜杠，并确保使用 file:/// 格式
        final normalizedPath = path.replaceAll('\\', '/');
        final newPath = 'file:///$normalizedPath';
        return '![$alt]($newPath)';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TodoDetailController(
      todoId: todoId,
      taskId: taskId,
    ));
    final appCtrl = Get.find<AppController>();

    return Obx(() {
      final backgroundImagePath = appCtrl.appConfig.value.backgroundImagePath;
      final hasBackground = backgroundImagePath != null && 
                            backgroundImagePath.isNotEmpty && 
                            File(backgroundImagePath).existsSync();
      final opacity = appCtrl.appConfig.value.backgroundImageOpacity;
      final blur = appCtrl.appConfig.value.backgroundImageBlur;
      final affectsNavBar = hasBackground ? appCtrl.appConfig.value.backgroundAffectsNavBar : false;

      Widget scaffold = TodoCatScaffold(
      title: 'todoDetail'.tr,
      rightWidgets: _buildRightWidgets(controller),
      body: Obx(() {
        final todo = controller.todo.value;
        if (todo == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题部分
              _buildTitleSection(context, todo),
              const SizedBox(height: 20),
              
              // 描述部分
              if (todo.description.isNotEmpty) ...[
                _buildDescriptionSection(context, todo),
                const SizedBox(height: 20),
              ],
              
              // 图片部分
              if (todo.images.isNotEmpty) ...[
                _buildImagesSection(context, todo),
                const SizedBox(height: 20),
              ],
              
              // 状态和优先级
              _buildStatusSection(context, todo, controller),
              const SizedBox(height: 20),
              
              // 标签部分
              if (todo.tagsWithColor.isNotEmpty || todo.tags.isNotEmpty) ...[
                _buildTagsSection(context, todo),
                const SizedBox(height: 20),
              ],
              
              // 时间信息
              _buildTimeSection(context, todo),
              
              // 提醒信息
              if (todo.reminders > 0) ...[
                const SizedBox(height: 20),
                _buildReminderSection(context, todo),
              ],
            ],
          ),
        );
      }),
    );

      if (hasBackground && affectsNavBar) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(backgroundImagePath)),
                    fit: BoxFit.cover,
                    opacity: opacity,
                  ),
                ),
              ),
            ),
            if (blur > 0)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(color: Colors.white.withValues(alpha:0.0)),
                ),
              ),
            scaffold,
          ],
        );
      } else if (hasBackground && !affectsNavBar) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                minimum: EdgeInsets.zero,
                bottom: false,
                child: Column(
                  children: [
                    if (Platform.isMacOS) 15.verticalSpace,
                    NavBar(
                      title: 'todoDetail'.tr,
                      rightWidgets: _buildRightWidgets(controller),
                    ),
                    5.verticalSpace,
                    Expanded(
                      child: ClipRect(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(File(backgroundImagePath)),
                                    fit: BoxFit.cover,
                                    opacity: opacity,
                                  ),
                                ),
                              ),
                            ),
                            if (blur > 0)
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                                  child: Container(color: Colors.white.withValues(alpha:0.0)),
                                ),
                              ),
                            Container(
                              color: Colors.transparent,
                              child: Obx(() {
                                final todo = controller.todo.value;
                                if (todo == null) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildTitleSection(Get.context!, todo),
                                      const SizedBox(height: 20),
                                      if (todo.description.isNotEmpty) ...[
                                        _buildDescriptionSection(Get.context!, todo),
                                        const SizedBox(height: 20),
                                      ],
                                      if (todo.images.isNotEmpty) ...[
                                        _buildImagesSection(Get.context!, todo),
                                        const SizedBox(height: 20),
                                      ],
                                      _buildStatusSection(Get.context!, todo, controller),
                                      const SizedBox(height: 20),
                                      if (todo.tagsWithColor.isNotEmpty || todo.tags.isNotEmpty) ...[
                                        _buildTagsSection(Get.context!, todo),
                                        const SizedBox(height: 20),
                                      ],
                                      _buildTimeSection(Get.context!, todo),
                                      if (todo.reminders > 0) ...[
                                        const SizedBox(height: 20),
                                        _buildReminderSection(Get.context!, todo),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: scaffold,
      );
    });
  }

  Widget _buildTitleSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.clipboard,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'title'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todo.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildDescriptionSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.fileLines,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'description'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MarkdownBody(
            data: _preprocessMarkdown(todo.description),
            sizedImageBuilder: (config) {
              final uriString = config.uri.toString();
              // 检查是否是本地文件路径
              // 优先判断网络图片（http:// 或 https://）
              final isNetworkImage = uriString.startsWith('http://') || 
                                     uriString.startsWith('https://');
              // 判断是否是本地文件（file:// 协议，或者不是网络图片且包含路径分隔符或驱动器符）
              final isLocalFile = uriString.startsWith('file://') || 
                                 (!isNetworkImage && 
                                  (uriString.contains('/') || 
                                   uriString.contains('\\') || 
                                   (uriString.length > 1 && uriString[1] == ':')));
              
              if (isLocalFile) {
                // 本地文件
                String filePath;
                try {
                  if (uriString.startsWith('file://')) {
                    // 处理 file:// 协议
                    // 直接去掉 file:// 前缀（7个字符）
                    filePath = uriString.substring(7);
                    
                    // 处理 Windows 路径的几种格式：
                    // file:///C:/path -> C:/path (去掉开头的 /)
                    // file://C:/path -> C:/path (保持不变)
                    // file://C:\path -> C:\path (保持不变)
                    if (filePath.startsWith('/') && filePath.length > 2 && filePath[2] == ':') {
                      // file:///C:/path 格式，去掉开头的 /
                      filePath = filePath.substring(1);
                    }
                    
                    // URL 解码（处理编码的路径，如空格被编码为 %20）
                    try {
                      filePath = Uri.decodeComponent(filePath);
                    } catch (e) {
                      // 如果解码失败，使用原路径
                    }
                  } else {
                    // 直接使用路径，尝试 URL 解码
                    try {
                      filePath = Uri.decodeComponent(uriString);
                    } catch (e) {
                      // 如果解码失败，直接使用原路径
                      filePath = uriString;
                    }
                  }
                  
                  // 验证路径不为空且有效
                  if (filePath.isEmpty || filePath == '\\' || filePath == '/') {
                    throw Exception('无效的路径: $uriString');
                  }
                  
                  // 尝试使用 File 类加载
                  // Dart 的 File 类在 Windows 上可以处理正斜杠和反斜杠
                  // 先尝试保持原路径格式
                  File file = File(filePath);
                  
                  // 如果文件不存在，尝试其他路径格式
                  if (!file.existsSync() && Platform.isWindows) {
                    // 如果路径包含正斜杠，尝试替换为反斜杠
                    if (filePath.contains('/') && !filePath.contains('\\')) {
                      final windowsPath = filePath.replaceAll('/', '\\');
                      file = File(windowsPath);
                      if (file.existsSync()) {
                        filePath = windowsPath;
                      }
                    }
                    // 如果路径包含反斜杠，尝试替换为正斜杠
                    else if (filePath.contains('\\') && !filePath.contains('/')) {
                      final unixPath = filePath.replaceAll('\\', '/');
                      file = File(unixPath);
                      if (file.existsSync()) {
                        filePath = unixPath;
                      }
                    }
                  }
                  
                  // 如果文件存在，显示图片
                  if (file.existsSync()) {
                    // 处理 width 和 height 为 null 的情况
                    final imageWidth = config.width;
                    final imageHeight = config.height;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageWidth != null && imageHeight != null
                            ? Image.file(
                                file,
                                fit: BoxFit.cover,
                                width: imageWidth,
                                height: imageHeight,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          config.alt ?? '图片加载失败',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                file,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          config.alt ?? '图片加载失败',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
                  } else {
                    // 如果文件不存在，显示错误信息
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '文件不存在',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '原始URI: ${uriString.length > 50 ? "${uriString.substring(0, 50)}..." : uriString}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '解析路径: ${filePath.length > 50 ? "${filePath.substring(0, 50)}..." : filePath}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  // 处理异常
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '图片加载错误',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '错误: ${e.toString().length > 50 ? "${e.toString().substring(0, 50)}..." : e.toString()}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'URI: ${uriString.length > 50 ? "${uriString.substring(0, 50)}..." : uriString}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              } else {
                // 网络图片
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      uriString,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                config.alt ?? '图片加载失败',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      width: config.width,
                      height: config.height,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
              fontSize: 16,
              height: 1.5,
              ),
              h1: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              h2: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              h3: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              code: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                backgroundColor: Get.theme.dividerColor.withValues(alpha: 0.1),
              ),
              codeblockDecoration: BoxDecoration(
                color: Get.theme.dividerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              blockquote: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              listBullet: TextStyle(
                fontSize: 16,
                color: Get.theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 50.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildImagesSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.image,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'images'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: todo.images.map((imagePath) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imagePath,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildStatusSection(BuildContext context, Todo todo, TodoDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.circleInfo,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'status'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(todo.status).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(todo.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    controller.getStatusText(todo.status),
                    style: TextStyle(
                      color: _getStatusColor(todo.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.flag,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'priority'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(todo.priority).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getPriorityColor(todo.priority),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    controller.getPriorityText(todo.priority),
                    style: TextStyle(
                      color: _getPriorityColor(todo.priority),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildTagsSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.tags,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'tags'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // 直接使用todo.tagsWithColor，它内部已经处理了兼容逻辑
              // 如果有颜色数据则使用，如果没有但有字符串标签，则转换为带颜色的标签
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: todo.tagsWithColor.map((tagWithColor) {
                  // 限制标签文本长度，防止溢出
                  String displayText = tagWithColor.name;
                  if (tagWithColor.name.length > 15) {
                    displayText = '${tagWithColor.name.substring(0, 12)}...';
                  }
                  
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.45, // 限制单个标签最大宽度为容器的45%
                    ),
                    child: Tag(
                      tag: displayText,
                      color: tagWithColor.color, // 使用存储的颜色
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildTimeSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.clock,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'timeInfo'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'createdAt'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timestampToDate(todo.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (todo.finishedAt > 0) ...[
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dueDate'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timestampToDate(todo.finishedAt),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildReminderSection(BuildContext context, Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.bell,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'reminderTime'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${todo.reminders} ${'minute'.tr}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 200.ms);
  }

  List<Widget> _buildRightWidgets(TodoDetailController controller) {
    return [
      Obx(() {
        if (controller.todo.value == null) return const SizedBox.shrink();
        
        return SizedBox(
          width: 40,
          height: 40,
          child: AnimationBtn(
            onPressed: () => controller.editTodo(),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Get.theme.dividerColor,
                  width: 0.5,
                ),
              ),
              child: const Icon(
                FontAwesomeIcons.penToSquare,
                size: 16,
              ),
            ),
          ),
        );
      }),
      Obx(() {
        if (controller.todo.value == null) return const SizedBox.shrink();
        
        return SizedBox(
          width: 40,
          height: 40,
          child: AnimationBtn(
            onPressed: () {
              showToast(
                "sureDeleteTodo".tr,
                alwaysShow: true,
                confirmMode: true,
                toastStyleType: TodoCatToastStyleType.error,
                onYesCallback: () => controller.deleteTodo(),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.shade300,
                  width: 0.5,
                ),
              ),
              child: Icon(
                FontAwesomeIcons.trashCan,
                size: 16,
                color: Colors.red.shade400,
              ),
            ),
          ),
        );
      }),
    ];
  }

  Color _getStatusColor(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Colors.orange;
      case TodoStatus.inProgress:
        return Colors.blue;
      case TodoStatus.done:
        return Colors.green;
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return const Color.fromRGBO(46, 204, 147, 1);
      case TodoPriority.mediumLevel:
        return const Color.fromARGB(255, 251, 136, 94);
      case TodoPriority.highLevel:
        return const Color.fromARGB(255, 251, 98, 98);
    }
  }
}