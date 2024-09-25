import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/widgets/label_btn.dart';

/// 自定义标签对话框按钮组件
class TagDialogBtn extends StatelessWidget {
  const TagDialogBtn({
    super.key,
    String? title,
    Widget? titleWidget,
    Widget? openDialog,
    required String tag,
    required Widget? icon,
    TextStyle? titleStyle,
    EdgeInsets? margin,
    VoidCallback? onDialogClose,
    VoidCallback? onDialogOpen,
  })  : _margin = margin,
        _tag = tag,
        _title = title ?? "",
        _titleStyle = titleStyle,
        _titleWidget = titleWidget,
        _openDialog = openDialog,
        _icon = icon,
        _onDialogOpen = onDialogOpen,
        _onDialogClose = onDialogClose;

  final String _tag; // 对话框的唯一标识符
  final String _title; // 按钮的标题
  final VoidCallback? _onDialogOpen; // 对话框打开时的回调函数
  final VoidCallback? _onDialogClose; // 对话框关闭时的回调函数
  final Widget? _openDialog; // 对话框的内容组件
  final TextStyle? _titleStyle; // 按钮标题的样式
  final Widget? _titleWidget; // 自定义标题组件
  final Widget? _icon; // 按钮的图标
  final EdgeInsets? _margin; // 按钮的外边距

  @override
  Widget build(BuildContext context) {
    return LabelBtn(
      interval: 5, // 图标与文本之间的间距
      margin: _margin, // 按钮的外边距
      reverse: true, // 图标与文本的排列顺序
      onClickScale: 0.97, // 点击时按钮缩放的比例
      onHoverAnimationEnabled: false, // 是否启用悬停动画
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 按钮的内边距
      ghostStyle: true, // 按钮是否为透明样式
      label: _titleWidget ??
          Text(
            _title,
            style: _titleStyle,
          ), // 按钮的标题
      icon: _icon, // 按钮的图标
      onPressed: () {
        if (_openDialog != null) {
          SmartDialog.show(
            tag: _tag, // 对话框的唯一标识符
            useSystem: false, // 是否使用系统对话框
            debounce: true, // 防抖动
            keepSingle: true, // 保持单一实例
            backDismiss: false, // 是否允许返回键关闭对话框
            animationTime: 150.ms, // 动画持续时间
            onDismiss: _onDialogClose, // 对话框关闭时的回调函数
            builder: (context) =>
                _openDialog ?? const Text("open unknown dialog!!!"), // 对话框的内容组件
            animationBuilder: (controller, child, _) => child
                .animate(controller: controller)
                .fade(duration: controller.duration)
                .scaleXY(
                  begin: 0.99, // 动画开始时的缩放比例
                  duration: controller.duration, // 动画持续时间
                  curve: Curves.easeOutCubic, // 动画曲线
                ),
          );
          _onDialogOpen?.call(); // 调用对话框打开时的回调函数
        }
      },
    );
  }
}
