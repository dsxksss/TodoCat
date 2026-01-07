import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/services/llm_polishing_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math' as math;

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

  // 确保 Service 可用
  LlmPolishingService get _llmService {
    if (!Get.isRegistered<LlmPolishingService>()) {
      Get.put(LlmPolishingService());
    }
    return Get.find<LlmPolishingService>();
  }

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
      SmartDialog.showToast("pleaseCompleteItProperly".tr);
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
    final isPhone = Get.context?.isPhone ?? false;

    SmartDialog.show(
      alignment: Alignment.center,
      animationType: SmartAnimationType.fade, // Disable default scale
      usePenetrate: true, // 允许点击背景关闭
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
    return Transform.translate(
      offset: _offset,
      child: Container(
        width: 300,
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
                // Header (Draggable Area)
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
                        const Icon(Icons.stars, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          "AI 润色结果",
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.polishedText,
                        style: const TextStyle(height: 1.5, fontSize: 14),
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
                        child: const Text("取消"),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 8),
                      // 移除 "替换" 按钮
                      ElevatedButton.icon(
                        onPressed: widget.onApply,
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
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text("替换"),
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
