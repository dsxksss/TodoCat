import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/pages/home/components/tag.dart';
import 'package:todo_cat/widgets/label_btn.dart';

class TagDialogBtn extends StatelessWidget {
  const TagDialogBtn({
    super.key,
    required String tag,
    required Color tagColor,
    required String dialogTag,
    VoidCallback? onTap,
    Widget? titleWidget,
    Widget? openDialog,
    VoidCallback? onDialogClose,
    VoidCallback? onDialogOpen,
    VoidCallback? onDelete,
    bool showDelete = false,
  })  : _tag = tag,
        _tagColor = tagColor,
        _dialogTag = dialogTag,
        _titleWidget = titleWidget,
        _openDialog = openDialog,
        _onDialogOpen = onDialogOpen,
        _onDialogClose = onDialogClose,
        _onDelete = onDelete,
        _showDelete = showDelete,
        _onTap = onTap;

  final String _tag;
  final Color _tagColor;
  final String _dialogTag;
  final Widget? _titleWidget;
  final Widget? _openDialog;
  final VoidCallback? _onDialogOpen;
  final VoidCallback? _onDialogClose;
  final VoidCallback? _onDelete;
  final bool _showDelete;
  final VoidCallback? _onTap;

  @override
  Widget build(BuildContext context) {
    VoidCallback? callback = _onTap;
    if (callback == null && _openDialog != null) {
      callback = () {
        SmartDialog.show(
          tag: _dialogTag,
          useSystem: false,
          debounce: true,
          keepSingle: true,
          backType: SmartBackType.normal,
          animationTime: 150.ms,
          onDismiss: _onDialogClose,
          builder: (context) => _openDialog!,
          animationBuilder: (controller, child, _) => child
              .animate(controller: controller)
              .fade(duration: controller.duration)
              .scaleXY(
                begin: 0.99,
                duration: controller.duration,
                curve: Curves.easeOutCubic,
              ),
        );
        _onDialogOpen?.call();
      };
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        LabelBtn(
          interval: 5,
          reverse: true,
          onClickScale: callback != null ? 0.97 : 1.0,
          onHoverAnimationEnabled: callback != null,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ghostStyle: true,
          label: _titleWidget ??
              Tag(
                tag: _tag,
                color: _tagColor,
              ),
          onPressed: callback ?? () {},
        ),
        if (_showDelete && _onDelete != null)
          Positioned(
            right: -8,
            top: -8,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _onDelete,
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
