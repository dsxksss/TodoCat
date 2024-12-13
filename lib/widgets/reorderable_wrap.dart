import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reorderables/reorderables.dart' as reorderables;

class ReorderableWrap extends StatefulWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index)? onNoReorder;
  final void Function(int index)? onReorderStarted;
  final Duration? animationInterval;
  final List<Effect>? effects;
  final EdgeInsetsGeometry? padding;

  const ReorderableWrap({
    super.key,
    required this.children,
    required this.onReorder,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.animationInterval,
    this.effects,
    this.padding,
    this.onNoReorder,
    this.onReorderStarted,
  });

  @override
  State<ReorderableWrap> createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap> {
  late List<Widget> _wrappedChildren;

  @override
  void initState() {
    super.initState();
    _updateWrappedChildren();
  }

  @override
  void didUpdateWidget(ReorderableWrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children != oldWidget.children) {
      _updateWrappedChildren();
    }
  }

  void _updateWrappedChildren() {
    _wrappedChildren = List.generate(widget.children.length, (index) {
      Widget child = widget.children[index];

      if (widget.effects != null) {
        child = Animate(
          effects: widget.effects,
          delay: (widget.animationInterval ?? 0.ms) * index,
          autoPlay: true,
          child: child,
        );
      }

      return child;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex--;
    }

    newIndex = newIndex.clamp(0, widget.children.length);

    widget.onReorder(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: reorderables.ReorderableWrap(
          controller: ScrollController(),
          spacing: widget.spacing,
          runSpacing: widget.runSpacing,
          onReorder: _onReorder,
          onNoReorder: widget.onNoReorder,
          onReorderStarted: widget.onReorderStarted,
          enableReorder: true,
          buildDraggableFeedback: (context, constraints, child) {
            return Material(
              elevation: 6.0,
              color: Colors.transparent,
              child: child,
            );
          },
          children: _wrappedChildren,
        ),
      ),
    );
  }
}
