import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:TodoCat/widgets/animation_btn.dart';

/// 自定义下拉菜单按钮组件
class DropdownManuBtn extends StatelessWidget {
  const DropdownManuBtn({
    super.key,
    required Widget child,
    required Widget content,
    SmartDialogController? controller,
    required String id,
    void Function()? onDismiss,
    bool disable = false,
    Alignment alignment = Alignment.bottomRight,
    SmartAttachAlignmentType? attachAlignmentType,
  })  : _onDismiss = onDismiss,
        _controller = controller,
        _disable = disable,
        _content = content,
        _child = child,
        _id = id,
        _alignment = alignment,
        _attachAlignmentType = attachAlignmentType;

  final String _id; // 下拉菜单的唯一标识符
  final Widget _child; // 按钮的子组件
  final Widget _content; // 下拉菜单的内容组件
  final bool _disable; // 按钮是否禁用
  final SmartDialogController? _controller; // SmartDialog 控制器
  final void Function()? _onDismiss; // 下拉菜单关闭时的回调函数
  final Alignment _alignment; // 对齐方式
  final SmartAttachAlignmentType? _attachAlignmentType; // 对齐类型

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onClickScale: 0.8, // 点击时按钮缩放的比例
      disable: _disable, // 按钮是否禁用
      clickScaleDuration: 100.ms, // 按钮点击缩放动画的持续时间
      onHoverAnimationEnabled: false, // 是否启用悬停动画
      onPressed: () {
        // 按钮点击事件
        // 如果指定了 attachAlignmentType，临时修改配置
        SmartConfigAttach? originalConfig;
        if (_attachAlignmentType != null) {
          originalConfig = SmartDialog.config.attach;
          SmartDialog.config.attach = SmartConfigAttach(
            attachAlignmentType: _attachAlignmentType,
          );
        }
        
        SmartDialog.showAttach(
          onDismiss: () {
            // 恢复原始配置
            if (_attachAlignmentType != null && originalConfig != null) {
              SmartDialog.config.attach = originalConfig;
            }
            _onDismiss?.call();
          },
          tag: _id, // 下拉菜单的唯一标识符
          targetContext: context, // 目标上下文
          debounce: true, // 防抖动
          keepSingle: true, // 保持单一实例
          usePenetrate: true, // 允许点击穿透
          animationTime: 100.ms, // 动画持续时间
          controller: _controller, // SmartDialog 控制器
          alignment: _alignment, // 对齐方式
          animationBuilder: (controller, child, animationParam) => child
              .animate(controller: controller)
              .fade(duration: controller.duration)
              .scaleXY(
                begin: 0.9, // 动画开始时的缩放比例
                end: 1, // 动画结束时的缩放比例
                curve: Curves.easeInOut, // 动画曲线
                duration: controller.duration, // 动画持续时间
              ),
          builder: (_) => _content, // 下拉菜单的内容组件
        );
      },
      child: _child, // 按钮的子组件
    );
  }
}
