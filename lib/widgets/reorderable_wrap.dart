import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'dart:async';

class ReorderableWrap extends StatefulWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Duration? animationInterval;
  final List<Effect>? effects;

  const ReorderableWrap({
    Key? key,
    required this.children,
    required this.onReorder,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.animationInterval,
    this.effects,
  }) : super(key: key);

  @override
  State<ReorderableWrap> createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap>
    with SingleTickerProviderStateMixin {
  int? dragSourceIndex;
  int? hoverIndex;
  bool isInitialLoad = true;
  final cardWidth = 240.0;
  final animDuration = 400.ms;
  Timer? _debounceTimer;
  final _debounceTime = const Duration(milliseconds: 16);
  int _rowItemCount = 0;
  late AnimationController _controller;
  Map<int, Animation<Offset>> _offsetAnimations = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animDuration,
    );
    _calculateLayout();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _calculateLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final screenWidth = MediaQuery.of(context).size.width;
      final itemWidth = cardWidth + widget.spacing;
      _rowItemCount = (screenWidth / itemWidth).floor();
    });
  }

  @override
  void didUpdateWidget(ReorderableWrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spacing != widget.spacing) {
      _calculateLayout();
    }
  }

  Offset _getOffsetForIndex(int index) {
    if (dragSourceIndex == null || hoverIndex == null) return Offset.zero;
    if (index == dragSourceIndex) return Offset.zero;

    final movingForward = dragSourceIndex! < hoverIndex!;
    final sourceRow = dragSourceIndex! ~/ _rowItemCount;
    final targetRow = hoverIndex! ~/ _rowItemCount;
    final currentRow = index ~/ _rowItemCount;

    // 如果在同一行
    if (sourceRow == targetRow && currentRow == sourceRow) {
      final inRange = movingForward
          ? index > dragSourceIndex! && index <= hoverIndex!
          : index < dragSourceIndex! && index >= hoverIndex!;

      if (!inRange) return Offset.zero;

      final moveDistance = cardWidth + widget.spacing;
      return Offset(movingForward ? -moveDistance : moveDistance, 0);
    }

    // 如果跨行
    if (currentRow > sourceRow && currentRow <= targetRow ||
        currentRow < sourceRow && currentRow >= targetRow) {
      final verticalOffset = widget.runSpacing * (targetRow - sourceRow).sign;
      final moveDistance = cardWidth + widget.spacing;

      // 计算水平偏移
      double horizontalOffset = 0;
      if (currentRow == targetRow) {
        final targetPosition = hoverIndex! % _rowItemCount;
        final currentPosition = index % _rowItemCount;
        if (currentPosition >= targetPosition) {
          horizontalOffset = moveDistance;
        }
      }

      return Offset(horizontalOffset, verticalOffset);
    }

    return Offset.zero;
  }

  void _updateAnimations() {
    if (!mounted || dragSourceIndex == null) return;

    _controller.reset();
    _offsetAnimations.clear();

    for (int i = 0; i < widget.children.length; i++) {
      final endOffset = _getOffsetForIndex(i);
      _offsetAnimations[i] = Tween<Offset>(
        begin: Offset.zero,
        end: endOffset,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuint,
      ));
    }

    _controller.forward();
  }

  void _updateHoverIndex(int? newHoverIndex) {
    if (newHoverIndex == dragSourceIndex) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTime, () {
      if (mounted && dragSourceIndex != null) {
        setState(() {
          if (hoverIndex != newHoverIndex) {
            hoverIndex = newHoverIndex;
            _updateAnimations();
          }
        });
      }
    });
  }

  Widget _buildAnimatedChild(Widget child, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _offsetAnimations[index]?.value ?? Offset.zero;
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        width: 1.sw,
        child: Wrap(
          spacing: widget.spacing,
          runSpacing: widget.runSpacing,
          children: AnimateList(
            effects: [
              context.isPhone
                  ? MoveEffect(
                      begin: const Offset(0, 10),
                      end: Offset.zero,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic)
                  : MoveEffect(
                      begin: const Offset(-10, 0),
                      end: Offset.zero,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic),
              FadeEffect(duration: 500.ms, curve: Curves.easeOutCubic),
            ],
            interval: 80.ms,
            children: [
              ...widget.children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                return Container(
                  width: cardWidth,
                  child: DragTarget<int>(
                    hitTestBehavior: HitTestBehavior.opaque,
                    onWillAccept: (sourceIndex) {
                      if (sourceIndex != null && sourceIndex != index) {
                        _updateHoverIndex(index);
                        return true;
                      }
                      return false;
                    },
                    onLeave: (data) {
                      _updateHoverIndex(null);
                    },
                    onAccept: (sourceIndex) {
                      if (sourceIndex != index) {
                        widget.onReorder(sourceIndex, index);
                      }
                      setState(() {
                        dragSourceIndex = null;
                        hoverIndex = null;
                        _offsetAnimations.clear();
                        _controller.reset();
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return LongPressDraggable<int>(
                        maxSimultaneousDrags: 1,
                        hapticFeedbackOnStart: true,
                        delay: const Duration(milliseconds: 300),
                        data: index,
                        onDragStarted: () {
                          setState(() => dragSourceIndex = index);
                        },
                        onDragEnd: (_) {
                          setState(() {
                            dragSourceIndex = null;
                            hoverIndex = null;
                            _offsetAnimations.clear();
                            _controller.reset();
                          });
                        },
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: cardWidth,
                            child: child.animate().scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.05, 1.05),
                                  duration: 150.ms,
                                  curve: Curves.easeOutQuint,
                                ),
                          ),
                        ),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Opacity(
                            opacity: dragSourceIndex == index ? 0.0 : 1.0,
                            child: SizedBox(
                              width: cardWidth,
                              child: _buildAnimatedChild(child, index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              DragTarget<int>(
                hitTestBehavior: HitTestBehavior.opaque,
                onWillAccept: (sourceIndex) {
                  if (sourceIndex != null) {
                    _updateHoverIndex(widget.children.length);
                    return true;
                  }
                  return false;
                },
                onLeave: (data) {
                  _updateHoverIndex(null);
                },
                onAccept: (sourceIndex) {
                  widget.onReorder(sourceIndex, widget.children.length);
                  setState(() {
                    dragSourceIndex = null;
                    hoverIndex = null;
                    _offsetAnimations.clear();
                    _controller.reset();
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return SizedBox(
                    width: hoverIndex == widget.children.length ? cardWidth : 0,
                    height: hoverIndex == widget.children.length ? 100 : 0,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
