import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/routers/app_router.dart';
import 'package:todo_cat/services/llm_polishing_service.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/responsive.dart';
class MagicPolishingButton extends StatefulWidget {
  final TextEditingController controller;
  final bool isMultiline;

  const MagicPolishingButton({
    super.key,
    required this.controller,
    this.isMultiline = false,
  });

  @override
  State<MagicPolishingButton> createState() => _MagicPolishingButtonState();
}

class _MagicPolishingButtonState extends State<MagicPolishingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isLoading = false;

  // 单例服务（替代 GetX 的 Get.put / Get.find）。
  LlmPolishingService get _llmService => LlmPolishingService.to;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handlePolish() async {
    final originalText = widget.controller.text;
    if (originalText.trim().isEmpty) {
      SmartDialog.showToast(l10n.pleaseCompleteItProperly);
      return;
    }

    setState(() {
      _isLoading = true;
      _animController.repeat();
    });

    try {
      final polishedText = await _llmService.polishText(originalText);
      if (mounted) {
        _showResultPopover(polishedText);
      }
    } catch (e) {
      SmartDialog.showToast("Failed to polish text");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _animController.stop();
          _animController.reset();
        });
      }
    }
  }

  void _showResultPopover(String polishedText) {
    final isPhone = rootNavigatorKey.currentContext?.isPhone ?? false;

    SmartDialog.show(
      alignment: Alignment.center,
      animationType: SmartAnimationType.fade, // Disable default scale
      usePenetrate: false, // 禁止点击穿透，确保拖拽事件总是能被捕获（解决 Transform 移出布局边界后无法交互的问题）
      maskColor: Colors.transparent, // 透明遮罩，保持视觉上的无遮挡感
      clickMaskDismiss: false,
      animationTime: 150.ms,
      builder: (_) {
        return _PolishingResultPopup(
          originalText: widget.controller.text,
          polishedText: polishedText,
          isPhone: isPhone,
          onApply: () {
            widget.controller.text = polishedText;
            SmartDialog.dismiss();
          },
          onCancel: () {
            SmartDialog.dismiss();
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isLoading ? null : _handlePolish,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _isLoading ? _animController.value * 2 * math.pi : 0,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.auto_fix_high,
              size: 20,
              color: _isLoading ? Colors.blueAccent : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _PolishingResultPopup extends StatefulWidget {
  final String originalText;
  final String polishedText;
  final bool isPhone;
  final VoidCallback onApply;
  final VoidCallback onCancel;

  const _PolishingResultPopup({
    required this.originalText,
    required this.polishedText,
    required this.isPhone,
    required this.onApply,
    required this.onCancel,
  });

  @override
  State<_PolishingResultPopup> createState() => _PolishingResultPopupState();
}

class _PolishingResultPopupState extends State<_PolishingResultPopup> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: _offset,
            child: Container(
              width: 320,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.dialogTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(width: 0.3, color: context.theme.dividerColor),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头部（可拖拽移动）：与其它对话框统一使用 DialogHeader。
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        setState(() {
                          _offset += details.delta;
                        });
                      },
                      child: DialogHeader(
                        titleWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_fix_high,
                                size: 18,
                                color: context.theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              l10n.aiPolishResult,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onCancel: widget.onCancel,
                        onConfirm: widget.onApply,
                        confirmText: l10n.aiReplace,
                      ),
                    ),

                    // 内容
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: Text(
                            widget.polishedText,
                            style: const TextStyle(height: 1.5, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
