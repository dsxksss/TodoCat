import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

/// Markdown 工具栏组件
/// 提供常用的 Markdown 语法快捷插入功能
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    super.key,
    required this.controller,
    this.onInsert,
  });

  final TextEditingController controller;
  final void Function(String)? onInsert;

  /// 在光标位置插入文本
  void _insertText(String text) {
    final value = controller.value;
    final selection = value.selection;
    
    if (selection.isValid) {
      final newText = value.text.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      final newSelection = TextSelection.collapsed(
        offset: selection.start + text.length,
      );
      controller.value = TextEditingValue(
        text: newText,
        selection: newSelection,
      );
    } else {
      // 如果没有选中文本，在末尾插入
      controller.text += text;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
    
    onInsert?.call(text);
  }

  /// 插入格式化的文本（在选中文本前后添加标记）
  void _wrapText(String prefix, String suffix) {
    final value = controller.value;
    final selection = value.selection;
    
    if (selection.isValid && selection.isCollapsed) {
      // 如果只是光标位置，插入标记
      final newText = value.text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$suffix',
      );
      final newSelection = TextSelection.collapsed(
        offset: selection.start + prefix.length,
      );
      controller.value = TextEditingValue(
        text: newText,
        selection: newSelection,
      );
    } else if (selection.isValid) {
      // 如果有选中文本，在前后添加标记
      final selectedText = value.text.substring(
        selection.start,
        selection.end,
      );
      final newText = value.text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      final newSelection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.start + prefix.length + selectedText.length + suffix.length,
      );
      controller.value = TextEditingValue(
        text: newText,
        selection: newSelection,
      );
    } else {
      // 如果没有选中文本，在末尾插入
      controller.text += '$prefix$suffix';
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length - suffix.length,
      );
    }
    
    onInsert?.call('$prefix$suffix');
  }

  /// 插入图片（支持本地图片和网络图片）
  Future<void> _insertImage() async {
    try {
      // 先尝试选择本地图片
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // 插入本地图片路径，使用 file:// 协议
          // 将 Windows 路径中的反斜杠转换为正斜杠，以符合标准 URI 格式
          String normalizedPath = file.path!.replaceAll('\\', '/');
          // 确保使用标准的 file:/// 格式（三个斜杠）
          final imagePath = 'file:///$normalizedPath';
          _wrapText('![', ']($imagePath)');
          return;
        }
      }
      
      // 如果用户取消了选择，可以选择插入网络图片占位符
      // 这里我们不做任何操作，让用户手动输入
    } catch (e) {
      // 如果选择失败，插入网络图片占位符
      _wrapText('![', '](${"imageUrl".tr})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolbarButton(
              icon: FontAwesomeIcons.bold,
              tooltip: 'markdownBold'.tr,
              onPressed: () => _wrapText('**', '**'),
            ),
            const SizedBox(width: 4),
            _buildToolbarButton(
              icon: FontAwesomeIcons.italic,
              tooltip: 'markdownItalic'.tr,
              onPressed: () => _wrapText('*', '*'),
            ),
            const SizedBox(width: 4),
            _buildToolbarButton(
              icon: FontAwesomeIcons.strikethrough,
              tooltip: 'markdownStrikethrough'.tr,
              onPressed: () => _wrapText('~~', '~~'),
            ),
            const SizedBox(width: 8),
            _buildToolbarButton(
              icon: FontAwesomeIcons.heading,
              tooltip: 'markdownHeading'.tr,
              onPressed: () => _insertText('# '),
            ),
            const SizedBox(width: 4),
            _buildToolbarButton(
              icon: FontAwesomeIcons.list,
              tooltip: 'markdownUnorderedList'.tr,
              onPressed: () => _insertText('- '),
            ),
            const SizedBox(width: 4),
            _buildToolbarButton(
              icon: FontAwesomeIcons.listOl,
              tooltip: 'markdownOrderedList'.tr,
              onPressed: () => _insertText('1. '),
            ),
            const SizedBox(width: 8),
            _buildToolbarButton(
              icon: FontAwesomeIcons.link,
              tooltip: 'markdownLink'.tr,
              onPressed: () => _wrapText('[', '](url)'),
            ),
            const SizedBox(width: 4),
            _buildToolbarButton(
              icon: FontAwesomeIcons.image,
              tooltip: 'markdownImage'.tr,
              onPressed: () => _insertImage(),
            ),
            const SizedBox(width: 4),
            _buildToolbarButton(
              icon: FontAwesomeIcons.code,
              tooltip: 'markdownCodeBlock'.tr,
              onPressed: () => _insertText('```\n\n```'),
            ),
            const SizedBox(width: 8),
            _buildToolbarButton(
              icon: FontAwesomeIcons.quoteLeft,
              tooltip: 'markdownQuote'.tr,
              onPressed: () => _insertText('> '),
            ),
            const SizedBox(width: 4),
            _buildToolbarButton(
              icon: FontAwesomeIcons.minus,
              tooltip: 'markdownSeparator'.tr,
              onPressed: () => _insertText('\n---\n'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

