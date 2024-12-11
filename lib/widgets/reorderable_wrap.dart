import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late double cardWidth;
  final animDuration = 400.ms;
  Timer? _debounceTimer;
  final _debounceTime = const Duration(milliseconds: 8);
  late AnimationController _controller;
  Map<int, Animation<Offset>> _offsetAnimations = {};
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  final _scrollThreshold = 100.0; // 触发滚动的边缘距离
  final _scrollSpeed = 5.0; // 滚动速度

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: animDuration,
    );
    cardWidth = 240.0;
    _calculateLayout();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        cardWidth = context.isPhone ? screenWidth * 0.9 : 240.0;
      });
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
    if (dragSourceIndex == null ||
        hoverIndex == null ||
        index == dragSourceIndex) {
      return Offset.zero;
    }

    final movingForward = dragSourceIndex! < hoverIndex!;
    final moveDistance = cardWidth + widget.spacing;

    if (movingForward) {
      return (index > dragSourceIndex! && index <= hoverIndex!)
          ? Offset(-moveDistance, 0)
          : Offset.zero;
    } else {
      return (index < dragSourceIndex! && index >= hoverIndex!)
          ? Offset(moveDistance, 0)
          : Offset.zero;
    }
  }

  void _updateAnimations() {
    if (!mounted || dragSourceIndex == null) return;

    if (_controller.isAnimating) {
      _controller.stop();
    }

    setState(() {
      _offsetAnimations = Map.fromEntries(
        List.generate(widget.children.length, (i) {
          final endOffset = _getOffsetForIndex(i);
          return MapEntry(
            i,
            Tween<Offset>(
              begin: _offsetAnimations[i]?.value ?? Offset.zero,
              end: endOffset,
            ).animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutCubic,
            )),
          );
        }),
      );
    });

    _controller.forward(from: 0.0);
  }

  void _updateHoverIndex(int? newHoverIndex) {
    if (newHoverIndex == dragSourceIndex) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTime, () {
      if (mounted && dragSourceIndex != null) {
        setState(() {
          if (hoverIndex != newHoverIndex) {
            final oldHoverIndex = hoverIndex;
            hoverIndex = newHoverIndex;

            if (oldHoverIndex != null &&
                newHoverIndex != null &&
                (oldHoverIndex - newHoverIndex).abs() == 1) {
              _controller.duration = 300.ms;
            } else {
              _controller.duration = animDuration;
            }

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

  Widget _buildDragFeedback(Widget child) {
    return Material(
      color: Colors.transparent,
      elevation: 8.0,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: cardWidth,
        child: child.animate().scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 200.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }

  void handleScroll(DragUpdateDetails details, BuildContext context) {
    _scrollTimer?.cancel();
    final RenderBox box = context.findRenderObject() as RenderBox;
    final position = box.globalToLocal(details.globalPosition);
    final height = box.size.height;

    if (position.dy < _scrollThreshold) {
      // 向上滚动
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (_scrollController.position.pixels <= 0) {
          timer.cancel();
          return;
        }
        _scrollController.animateTo(
          _scrollController.position.pixels - _scrollSpeed,
          duration: const Duration(milliseconds: 16),
          curve: Curves.linear,
        );
      });
    } else if (position.dy > height - _scrollThreshold) {
      // 向下滚动
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
          timer.cancel();
          return;
        }
        _scrollController.animateTo(
          _scrollController.position.pixels + _scrollSpeed,
          duration: const Duration(milliseconds: 16),
          curve: Curves.linear,
        );
      });
    }
  }

  void handleDragEnd(DraggableDetails details) {
    setState(() {
      dragSourceIndex = null;
      hoverIndex = null;
      _offsetAnimations.clear();
      _controller.reset();
    });
    _scrollTimer?.cancel();
    HapticFeedback.lightImpact();
  }

  void _resetDragState() {
    if (!mounted) return;

    final currentOffsets = Map<int, Offset>.fromEntries(
      _offsetAnimations.entries.map((e) => MapEntry(e.key, e.value.value)),
    );

    setState(() {
      dragSourceIndex = null;
      hoverIndex = null;

      _offsetAnimations = Map.fromEntries(
        currentOffsets.entries.map((e) => MapEntry(
              e.key,
              Tween<Offset>(
                begin: e.value,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
              )),
            )),
      );
    });

    _controller.forward(from: 0.0);
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
          children: [
            ...widget.children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: cardWidth,
                    child: DragTarget<int>(
                      hitTestBehavior: HitTestBehavior.translucent,
                      onWillAcceptWithDetails: (details) {
                        final RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        final localPosition =
                            renderBox.globalToLocal(details.offset);

                        // 扩大检测区域到卡片两侧
                        final expandedRect = Rect.fromLTWH(
                          -widget.spacing / 2,
                          0,
                          cardWidth + widget.spacing,
                          renderBox.size.height,
                        );

                        if (details.data != index &&
                            expandedRect.contains(localPosition)) {
                          _updateHoverIndex(index);
                          return true;
                        }
                        return false;
                      },
                      onLeave: (data) {
                        _updateHoverIndex(null);
                      },
                      onAcceptWithDetails: (details) {
                        final sourceIndex = details.data;
                        if (sourceIndex != index) {
                          widget.onReorder(sourceIndex, index);
                        }
                        _resetDragState();
                      },
                      builder: (context, candidateData, rejectedData) {
                        return _buildDraggable(index, child);
                      },
                    ),
                  );
                },
              );
            }),
            // 末尾的拖放目标
            DragTarget<int>(
              hitTestBehavior: HitTestBehavior.translucent,
              onWillAcceptWithDetails: (details) {
                _updateHoverIndex(widget.children.length);
                return true;
              },
              onLeave: (data) {
                _updateHoverIndex(null);
              },
              onAcceptWithDetails: (details) {
                final sourceIndex = details.data;
                widget.onReorder(sourceIndex, widget.children.length);
                _resetDragState();
              },
              builder: (context, candidateData, rejectedData) {
                return SizedBox(
                  width: hoverIndex == widget.children.length ? cardWidth : 0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggable(int index, Widget child) {
    return LongPressDraggable<int>(
      maxSimultaneousDrags: 1,
      hapticFeedbackOnStart: true,
      delay: const Duration(milliseconds: 300),
      data: index,
      onDragStarted: () {
        setState(() => dragSourceIndex = index);
        _updateAnimations();
        HapticFeedback.mediumImpact();
      },
      onDragUpdate: (details) {
        // 获取拖拽卡片的位置和尺寸
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final dragCardRect = Rect.fromLTWH(
          details.globalPosition.dx - (cardWidth / 2),
          details.globalPosition.dy - 20,
          cardWidth,
          renderBox.size.height,
        );

        // 获取目标卡片的位置和尺寸
        final targetCardRect =
            renderBox.localToGlobal(Offset.zero) & renderBox.size;

        // 计算重叠区域
        if (index != dragSourceIndex) {
          final overlapRect = dragCardRect.overlaps(targetCardRect)
              ? dragCardRect.intersect(targetCardRect)
              : Rect.zero;

          // 计算重叠面积占卡片面积的比例
          final overlapArea = overlapRect.width * overlapRect.height;
          final cardArea = cardWidth * renderBox.size.height;
          final overlapRatio = overlapArea / cardArea;

          // 当重叠面积超过 40% 时触发
          if (overlapRatio > 0.4) {
            _updateHoverIndex(index);
          }
        }
      },
      onDragEnd: (_) {
        _resetDragState();
        HapticFeedback.lightImpact();
      },
      feedback: _buildDragFeedback(child),
      childWhenDragging: const SizedBox(),
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
  }
}
