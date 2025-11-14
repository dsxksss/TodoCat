import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:TodoCat/controllers/todo_dialog_ctr.dart';
import 'package:TodoCat/keys/dialog_keys.dart';
import 'package:TodoCat/pages/home/components/add_tag_with_color_screen.dart';
import 'package:TodoCat/pages/home/components/text_form_field_item.dart';
import 'package:TodoCat/widgets/date_picker_panel.dart';
import 'package:TodoCat/widgets/label_btn.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:TodoCat/widgets/tag_dialog_btn.dart';
import 'package:TodoCat/widgets/priority_picker_panel.dart';
import 'package:TodoCat/widgets/reminder_picker_panel.dart';
import 'package:TodoCat/widgets/status_picker_panel.dart';
import 'package:intl/intl.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/widgets/markdown_toolbar.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

class TodoDialog extends StatefulWidget {
  const TodoDialog({
    super.key,
    required this.dialogTag,
  });

  final String dialogTag;

  @override
  State<TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<TodoDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late FocusNode _descriptionFocusNode;
  bool _isPreviewVisible = false;
  bool _shouldOffset = false; // 控制 dialog 是否应该偏移

  @override
  void initState() {
    super.initState();
    _descriptionFocusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _descriptionFocusNode.addListener(() {
      if (_descriptionFocusNode.hasFocus) {
        if (!_isPreviewVisible) {
          setState(() {
            _isPreviewVisible = true;
            _shouldOffset = true; // 触发位置偏移
          });
          _animationController.forward();
        }
      }
      // 移除失焦自动关闭的逻辑，改为通过关闭按钮控制
    });
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  AddTodoDialogController get controller =>
      Get.find<AddTodoDialogController>(tag: widget.dialogTag);

  void _closePreview() {
    if (_isPreviewVisible) {
      setState(() {
        _isPreviewVisible = false;
        _shouldOffset = false; // 触发位置恢复
      });
      _animationController.reverse();
    }
  }

  void _handleSubmit() async {
    // 先获取编辑状态和标题，再提交表单
    final isEditing = controller.isEditing.value;
    final todoTitle = controller.titleController.text;
    
    if (await controller.submitForm()) {
      SmartDialog.dismiss(tag: addTodoDialogTag);
      
      // 根据之前获取的编辑状态显示不同的提示
      final actionText = isEditing ? "updatedSuccessfully".tr : "addedSuccessfully".tr;
      
      // 使用左下角通知显示成功信息
      showSuccessNotification(
        "${"todo".tr} '$todoTitle' $actionText",
      );
      
      // 清理表单状态（在显示提示后）
      controller.clearForm();
    }
  }

  void _handleClose() {
    if (controller.hasChanges) {
      showToast(
        controller.isEditing.value ? "${"saveEditing".tr}?" : "keepInput".tr,
        tag: confirmDialogTag,
        alwaysShow: true,
        confirmMode: true,
        onYesCallback: () {
          if (controller.isEditing.value) {
            controller.submitForm();
          } else {
            // 只保留输入但不直接创建
            controller.saveCache();
          }
          SmartDialog.dismiss(tag: addTodoDialogTag);
        },
        onNoCallback: () {
          if (controller.isEditing.value) {
            controller.revertChanges();
          } else {
            // 取消保留并清除缓存，避免下次打开有残留
            controller.clearForm();
          }
          SmartDialog.dismiss(tag: addTodoDialogTag);
        },
      );
    } else {
      SmartDialog.dismiss(tag: addTodoDialogTag);
    }
  }

  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return "lowPriority".tr;
      case TodoPriority.mediumLevel:
        return "mediumPriority".tr;
      case TodoPriority.highLevel:
        return "highPriority".tr;
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return Colors.green;
      case TodoPriority.mediumLevel:
        return Colors.orange;
      case TodoPriority.highLevel:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.lowLevel:
        return Icons.flag_outlined;
      case TodoPriority.mediumLevel:
        return Icons.flag_outlined;
      case TodoPriority.highLevel:
        return Icons.flag;
    }
  }

  String _getReminderLabel(int reminderMinutes) {
    if (reminderMinutes == 0) {
      return "noReminder".tr;
    } else if (reminderMinutes < 60) {
      return "$reminderMinutes${'minutesAgo'.tr}";
    } else if (reminderMinutes < 1440) {
      return "${(reminderMinutes / 60).round()}${'hoursAgo'.tr}";
    } else {
      return "${(reminderMinutes / 1440).round()}${'daysAgo'.tr}";
    }
  }

  String _getStatusLabel(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return "statusTodo".tr;
      case TodoStatus.inProgress:
        return "statusInProgress".tr;
      case TodoStatus.done:
        return "statusDone".tr;
    }
  }

  Color _getStatusColor(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Colors.grey[600]!;
      case TodoStatus.inProgress:
        return Colors.orange;
      case TodoStatus.done:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Icons.radio_button_unchecked;
      case TodoStatus.inProgress:
        return Icons.access_time;
      case TodoStatus.done:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddTodoDialogController>(
      tag: widget.dialogTag,
      builder: (_) => AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          // 确保 _shouldOffset 变化时也能触发重建
          return _buildDialog(context);
        },
      ),
    );
  }

  Widget _buildDialog(BuildContext context) {
    final dialogWidth = context.isPhone ? 1.sw : 430.0;
    final dialogHeight = context.isPhone ? 0.75.sh : 540.0;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // dialog 和预览窗口之间的间距
    const spacing = 10.0;
    
    // 计算预览区域宽度：比 dialog 宽一点，但不超过屏幕宽度
    // 确保预览窗口 + dialog + 间距不超过屏幕宽度
    final previewWidth = (dialogWidth + 100).clamp(0.0, screenWidth - dialogWidth - spacing - 20);
    
    // 计算当预览窗口显示时的总宽度
    final totalWidth = dialogWidth + spacing + previewWidth;
    
    // 计算 dialog 需要向左移动的距离（当预览窗口显示时）
    // 如果总宽度超过屏幕宽度，需要向左移动以确保预览窗口完全可见
    // 如果总宽度不超过屏幕，也需要移动一些，让预览窗口在 dialog 右侧显示
    final maxDialogOffsetX = totalWidth > screenWidth
        ? ((totalWidth - screenWidth) / 2 + 20).clamp(0.0, screenWidth / 2)
        : (previewWidth + spacing) / 2; // 即使不超过屏幕，也移动一半预览窗口宽度，为预览窗口让出空间
    
    // dialog 的偏移量：根据 _shouldOffset 状态决定
    final dialogOffsetX = _shouldOffset ? maxDialogOffsetX : 0.0;
    
    // Stack 的宽度：始终保持 totalWidth，避免宽度变化导致位置计算跳动
    // 预览窗口隐藏时，通过 FadeTransition 的 opacity 和 IgnorePointer 来控制显示
    final stackWidth = totalWidth;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: stackWidth,
      height: dialogHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
        // 左侧编辑区域（dialog 使用 AnimatedContainer 的 transform 实现位置移动动画）
        // 使用 AnimatedPositioned 同步 left 和 transform 的动画，避免先向右偏移的问题
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: (stackWidth - dialogWidth) / 2 - dialogOffsetX,
          top: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: dialogWidth,
            height: dialogHeight,
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
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.3,
                    color: context.theme.dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    controller.isEditing.value ? "editTodo".tr : "addTodo".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  Row(
                    children: [
                      LabelBtn(
                        ghostStyle: true,
                        label: Text(
                          "cancel".tr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onPressed: _handleClose,
                      ),
                      const SizedBox(width: 8),
                      LabelBtn(
                        label: Text(
                          "confirm".tr,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // 顶部可滚动内容区域
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 35,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              children: [
                          // 日期选择器按钮
                          Obx(() => TagDialogBtn(
                                tag: controller.selectedDate.value != null
                                    ? DateFormat('MM-dd HH:mm')
                                        .format(controller.selectedDate.value!)
                                    : "setDueDate".tr,
                                tagColor: controller.selectedDate.value != null
                                    ? const Color(0xFF3B82F6)
                                    : Colors.grey[700]!,
                                dialogTag: 'todo_date',
                                showDelete: false,
                                openDialog: DatePickerPanel(
                                  dialogTag: addTodoTagDialogBtnTag,
                                  initialSelectedDate: controller.selectedDate.value, // 传递当前选中的日期
                                  onDateSelected: (date) {
                                    controller.selectedDate.value = date;
                                  },
                                ),
                                titleWidget: Row(
                                  children: [
                                    Text(
                                      controller.selectedDate.value != null
                                          ? DateFormat('MM-dd HH:mm').format(
                                              controller.selectedDate.value!)
                                          : "setDueDate".tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.event_available_outlined,
                                        size: 20),
                                  ],
                                ),
                              )),
                          const SizedBox(width: 10),
                          Obx(() => TagDialogBtn(
                                tag: _getPriorityLabel(controller.selectedPriority.value),
                                tagColor: _getPriorityColor(controller.selectedPriority.value),
                                dialogTag: 'todo_priority',
                                showDelete: false,
                                openDialog: PriorityPickerPanel(
                                  initialPriority: controller.selectedPriority.value,
                                  onPrioritySelected: (priority) {
                                    controller.selectedPriority.value = priority;
                                  },
                                ),
                                titleWidget: Row(
                                  children: [
                                    Text(
                                      _getPriorityLabel(controller.selectedPriority.value),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      _getPriorityIcon(controller.selectedPriority.value),
                                      size: 20,
                                      color: _getPriorityColor(controller.selectedPriority.value),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(width: 10),
                          Obx(() => TagDialogBtn(
                                tag: _getReminderLabel(controller.remindersValue.value),
                                tagColor: controller.remindersValue.value > 0 
                                    ? const Color(0xFF3B82F6) 
                                    : Colors.grey[700]!,
                                dialogTag: 'todo_reminder',
                                showDelete: false,
                                openDialog: ReminderPickerPanel(
                                  initialReminder: controller.remindersValue.value,
                                  onReminderSelected: (reminder) {
                                    controller.remindersValue.value = reminder;
                                  },
                                ),
                                titleWidget: Row(
                                  children: [
                                    Text(
                                      _getReminderLabel(controller.remindersValue.value),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      controller.remindersValue.value > 0 
                                          ? Icons.alarm 
                                          : Icons.alarm_off,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(width: 10),
                          Obx(() => TagDialogBtn(
                                tag: _getStatusLabel(controller.selectedStatus.value),
                                tagColor: _getStatusColor(controller.selectedStatus.value),
                                dialogTag: 'todo_status',
                                showDelete: false,
                                openDialog: StatusPickerPanel(
                                  initialStatus: controller.selectedStatus.value,
                                  onStatusSelected: (status) {
                                    controller.selectedStatus.value = status;
                                  },
                                ),
                                titleWidget: Row(
                                  children: [
                                    Text(
                                      _getStatusLabel(controller.selectedStatus.value),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      _getStatusIcon(controller.selectedStatus.value),
                                      size: 20,
                                      color: _getStatusColor(controller.selectedStatus.value),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    10.verticalSpace,
                    TextFormFieldItem(
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      focusNode: FocusNode(),
                      maxLength: 20,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: "title".tr,
                      validator: controller.validateTitle,
                      editingController: controller.titleController,
                      onFieldSubmitted: (_) {},
                    ),
                    const SizedBox(height: 10),
                    AddTagWithColorPicker(
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      maxLines: 1,
                      radius: 6,
                      fieldTitle: "tag".tr,
                      validator: (_) => null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      editingController: controller.tagController,
                      selectedTags: controller.selectedTags,
                      onDeleteTag: controller.removeTag,
                      onAddTagWithColor: controller.addTagWithColor,
                    ),
                  ],
                ),
              ),
            ),
            // Markdown 工具栏 - 固定在tag下方，确保始终可见
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: MarkdownToolbar(
                controller: controller.descriptionController,
              ),
            ),
            // Description 输入框 - 占据剩余空间
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 计算合适的行数：每行大约 20-25 像素（包括 padding）
                    // 减去底部边距15像素
                    const lineHeight = 25.0;
                    const minLines = 3;
                    const bottomPadding = 15.0;
                    // 计算最大行数，确保填充整个可用高度（减去底部边距）
                    final availableHeight = constraints.maxHeight - bottomPadding;
                    final calculatedMaxLines = ((availableHeight / lineHeight).floor()).clamp(minLines, 100);
                    
                    return SizedBox(
                      height: availableHeight,
                      child: TextFormFieldItem(
                        textInputAction: null, // 设置为 null 以允许回车键换行
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 10,
                        ),
                        maxLength: 400,
                        minLines: calculatedMaxLines, // 使用计算出的行数确保填充高度
                        maxLines: calculatedMaxLines, // 使用计算出的最大行数
                        radius: 6,
                        fieldTitle: "description".tr,
                        validator: (_) => null,
                        editingController: controller.descriptionController,
                        focusNode: _descriptionFocusNode,
                        onFieldSubmitted: (_) {},
                      ),
                    );
                  },
                ),
              ),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
        ),
        // 右侧预览区域（使用 AnimatedPositioned 处理位置移动，FadeTransition 处理透明度）
        // 预览窗口在 dialog 右侧，间距为 spacing
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: (stackWidth - dialogWidth) / 2 + dialogWidth + spacing - dialogOffsetX,
          top: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: IgnorePointer(
              ignoring: _fadeAnimation.value == 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: previewWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  color: context.theme.dialogTheme.backgroundColor,
                  border: Border.all(width: 0.3, color: context.theme.dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0.3,
                            color: context.theme.dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'preview'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          LabelBtn(
                            label: const Icon(Icons.close, size: 20),
                            onPressed: _closePreview,
                            padding: EdgeInsets.zero,
                            ghostStyle: true,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(15),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller.descriptionController,
                            builder: (context, value, child) {
                            // 预处理 markdown 文本：将旧格式的 file:// 路径转换为标准格式
                            String processedText = value.text;
                            if (processedText.contains('file://')) {
                              // 检查是否已经是标准格式（file:///），如果是则不需要处理
                              if (!processedText.contains('file:///') || 
                                  processedText.contains(RegExp(r'file://[^/]'))) {
                                // 将 file://C:\path 格式转换为 file:///C:/path 格式
                                // 匹配 ![](file://C:\path) 或 ![alt](file://C:\path) 格式
                                processedText = processedText.replaceAllMapped(
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
                            }
                            
                            return MarkdownBody(
                              data: processedText.isEmpty
                                  ? '*暂无内容*'
                                  : processedText,
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
                                      // 支持多种格式：
                                      // file:///C:/path -> C:/path (标准格式)
                                      // file://C:/path -> C:/path
                                      // file://C:\path -> C:\path (非标准，但可能存在于旧数据)
                                      
                                      // 先去掉 file:// 前缀（7个字符）
                                      filePath = uriString.substring(7);
                                      
                                      // 如果是以 / 开头（file:/// 格式），去掉开头的 /
                                      if (filePath.startsWith('/')) {
                                        filePath = filePath.substring(1);
                                      }
                                      
                                      // 如果路径中包含正斜杠，在 Windows 上可能需要转换为反斜杠
                                      // 但先尝试保持原格式，因为 Dart 的 File 类可以处理正斜杠
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
                                    
                                    // 如果还是不存在，显示错误信息
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
                                  backgroundColor: context.theme.dividerColor.withValues(alpha: 0.1),
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: context.theme.dividerColor.withValues(alpha: 0.1),
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
                                  color: context.theme.colorScheme.primary,
                                ),
                              ),
                            );
                          },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ],
      ),
    );
  }
}
