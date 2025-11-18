import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/todo_detail_ctr.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/core/utils/date_time.dart';
import 'package:todo_cat/pages/home/components/tag.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

class TodoDetailDialog extends StatelessWidget {
  final String todoId;
  final String taskId;

  const TodoDetailDialog({
    super.key,
    required this.todoId,
    required this.taskId,
  });
  
  String get _dialogTag => 'todo_detail_dialog_$todoId';

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
    final controller = Get.put(
      TodoDetailController(
        todoId: todoId,
        taskId: taskId,
      ),
      tag: _dialogTag,  // 使用唯一的 tag 创建独立的 controller
    );
    
    return _buildDialog(context, controller);
  }

  Widget _buildDialog(BuildContext context, TodoDetailController controller) {
    return Obx(() {
      final todo = controller.todo.value;
      if (todo == null) {
        return Container(
          width: context.isPhone ? 1.sw : 430,
          height: 400,
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Container(
        width: context.isPhone ? 1.sw : 600,
        height: context.isPhone ? 0.8.sh : 650,
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
          children: [
            // 头部
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
                    'todoDetail'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  LabelBtn(
                    label: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      SmartDialog.dismiss(tag: _dialogTag);
                    },
                    padding: EdgeInsets.zero,
                    ghostStyle: true,
                  ),
                ],
              ),
            ),
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题部分
                    _buildTitleSection(todo),
                    const SizedBox(height: 15),
                    
                    // 描述部分
                    if (todo.description.isNotEmpty) ...[
                      _buildDescriptionSection(todo),
                      const SizedBox(height: 15),
                    ],
                    
                    // 状态和优先级
                    _buildStatusSection(todo, controller),
                    const SizedBox(height: 15),
                    
                    // 标签部分
                    if (todo.tagsWithColor.isNotEmpty || todo.tags.isNotEmpty) ...[
                      _buildTagsSection(todo),
                      const SizedBox(height: 15),
                    ],
                    
                    // 时间信息
                    _buildTimeSection(todo),
                    
                    // 提醒信息
                    if (todo.reminders > 0) ...[
                      const SizedBox(height: 15),
                      _buildReminderSection(todo),
                    ],
                    
                    // 图片部分
                    if (todo.images.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      _buildImagesSection(todo),
                    ],
                  ],
                ),
              ),
            ),
            // 底部按钮
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: context.theme.dividerColor,
                    width: 0.3,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LabelBtn(
                    ghostStyle: true,
                    label: Text(
                      'edit'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    onPressed: () => controller.editTodo(),
                  ),
                  const SizedBox(width: 8),
                  LabelBtn(
                    label: Text(
                      'delete'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    bgColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    onPressed: () {
                      showToast(
                        "sureDeleteTodo".tr,
                        alwaysShow: true,
                        confirmMode: true,
                        toastStyleType: TodoCatToastStyleType.error,
                        onYesCallback: () => controller.deleteTodo(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTitleSection(Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor,
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

  Widget _buildDescriptionSection(Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor,
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
                    filePath = uriString.substring(7);
                    // 处理 Windows 路径的几种格式：
                    // file:///C:/path -> C:/path
                    // file://C:/path -> C:/path
                    // file://C:\path -> C:\path
                    if (filePath.startsWith('/') && filePath.length > 2 && filePath[2] == ':') {
                      // file:///C:/path 格式，去掉开头的 /
                      filePath = filePath.substring(1);
                    }
                    // URL 解码（处理编码的路径）
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
                  
                  // 如果还是不存在，显示调试信息
                  if (!file.existsSync()) {
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
                              '原始: ${uriString.length > 50 ? "${uriString.substring(0, 50)}..." : uriString}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '解析: ${filePath.length > 50 ? "${filePath.substring(0, 50)}..." : filePath}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
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
                      ),
                    ),
                  );
                } catch (e) {
                  // 路径解析错误
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
                            '路径解析失败',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              } else {
                // 网络图片（使用缓存）
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: uriString,
                      fit: BoxFit.cover,
                      width: config.width,
                      height: config.height,
                      placeholder: (context, url) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
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
                      ),
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

  Widget _buildImagesSection(Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor,
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

  Widget _buildStatusSection(Todo todo, TodoDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor,
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

  Widget _buildTagsSection(Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: todo.tagsWithColor.map((tagWithColor) {
              String displayText = tagWithColor.name;
              if (tagWithColor.name.length > 15) {
                displayText = '${tagWithColor.name.substring(0, 12)}...';
              }
              
              return Tag(
                tag: displayText,
                color: tagWithColor.color,
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 200.ms);
  }

  Widget _buildTimeSection(Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor,
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

  Widget _buildReminderSection(Todo todo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.dividerColor,
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

