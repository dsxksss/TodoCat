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

    final moveDistance = cardWidth + widget.spacing;
    final sourceIndex = dragSourceIndex!;
    final targetIndex = hoverIndex!;

    // 只移动源索引和目标索引之间的卡片
    if (sourceIndex < targetIndex) {
      // 向后移动，只移动直接相关的卡片
      if (index > sourceIndex && index < targetIndex) {
        return Offset(-moveDistance, 0);
      }
    } else if (sourceIndex > targetIndex) {
      // 向前移动，只移动直接相关的卡片
      if (index < sourceIndex && index >= targetIndex) {
        return Offset(moveDistance, 0);
      }
    }
    return Offset.zero;
  }

  void _updateAnimations() {
    if (!mounted || dragSourceIndex == null || hoverIndex == null) return;

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

    // ��加额外的检查，确保新的hover索引是有效的
    if (newHoverIndex != null) {
      // 如果新位置与当前位置相邻，且动画正在进行，则忽略这次更新
      if (hoverIndex != null &&
          _controller.isAnimating &&
          (newHoverIndex - hoverIndex!).abs() == 1) {
        return;
      }
    }

    setState(() {
      if (hoverIndex != newHoverIndex) {
        hoverIndex = newHoverIndex;
        _updateAnimations();
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

    // 如果有有效的拖拽目标，先执行位交换
    if (dragSourceIndex != null &&
        hoverIndex != null &&
        dragSourceIndex! < widget.children.length &&
        hoverIndex! <= widget.children.length) {
      // 注意这里用 <= 因为可以拖到末尾
      widget.onReorder(dragSourceIndex!, hoverIndex!);
    }

    // 然后清除状态
    setState(() {
      dragSourceIndex = null;
      hoverIndex = null;
      _offsetAnimations.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        width: 1.sw,
        child: Stack(
          children: [
            Wrap(
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
                            if (details.data == index) return false;

                            final RenderBox renderBox =
                                context.findRenderObject() as RenderBox;
                            final localPosition =
                                renderBox.globalToLocal(details.offset);

                            // 扩大接受区域，包括两侧的间距
                            final acceptArea = Rect.fromLTWH(
                              -widget.spacing, // 扩大左侧接受区域
                              0,
                              cardWidth + widget.spacing * 2, // 扩大右侧接受区域
                              renderBox.size.height,
                            );

                            if (acceptArea.contains(localPosition)) {
                              if (localPosition.dx < cardWidth / 2) {
                                _updateHoverIndex(index);
                              } else {
                                _updateHoverIndex(index + 1);
                              }
                              return true;
                            }
                            return false;
                          },
                          onLeave: (data) {
                            _updateHoverIndex(null);
                          },
                          onAcceptWithDetails: (details) {
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
                // 添加一个占位的空白区域，确保有足够的拖放空间
                if (dragSourceIndex != null)
                  SizedBox(
                    width: cardWidth,
                    height: 100, // 给一个合适的高度
                  ),
              ],
            ),
            // 末尾的拖放目标区域覆盖在整个容器上
            if (dragSourceIndex != null)
              Positioned.fill(
                child: DragTarget<int>(
                  hitTestBehavior: HitTestBehavior.translucent,
                  onWillAcceptWithDetails: (details) {
                    final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    final localPosition =
                        renderBox.globalToLocal(details.offset);

                    // 计算最后一个卡片的右边界
                    final lastCardRight = (widget.children.length *
                            (cardWidth + widget.spacing)) -
                        widget.spacing;

                    // 只有当拖拽位置超过最后一个卡片时才接受
                    if (localPosition.dx > lastCardRight) {
                      _updateHoverIndex(widget.children.length);
                      return true;
                    }
                    return false;
                  },
                  onLeave: (data) {
                    if (hoverIndex == widget.children.length) {
                      _updateHoverIndex(null);
                    }
                  },
                  onAcceptWithDetails: (details) {
                    _resetDragState();
                  },
                  builder: (context, candidateData, rejectedData) {
                    return const SizedBox.expand();
                  },
                ),
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
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);

        // 计算容器的总宽度
        final totalItemWidth = cardWidth + widget.spacing;
        final containerWidth = widget.children.length * totalItemWidth;

        // 处理边界情况
        if (localPosition.dx <= 0) {
          // 如果拖到最左边，直接设置为第一个位置
          if (dragSourceIndex != 0) {
            _updateHoverIndex(0);
          }
          return;
        }

        if (localPosition.dx >= containerWidth) {
          // 如果拖到最右边，直接设置为最后位置
          if (dragSourceIndex != widget.children.length) {
            _updateHoverIndex(widget.children.length);
          }
          return;
        }

        // 计算拖拽点相对于整个容器的位置
        final relativeX = localPosition.dx;

        // 计算相对于每个卡片中心点的距离
        final cardCenters = List.generate(widget.children.length + 1, (i) {
          return i * totalItemWidth - widget.spacing / 2;
        });

        // 找到最近的插入点
        double minDistance = double.infinity;
        int nearestIndex = 0;

        for (int i = 0; i < cardCenters.length; i++) {
          final distance = (relativeX - cardCenters[i]).abs();
          if (distance < minDistance) {
            minDistance = distance;
            nearestIndex = i;
          }
        }

        // 添加最小距离阈值，避免频繁切换
        if (minDistance < totalItemWidth / 3) {
          if (nearestIndex != dragSourceIndex) {
            _updateHoverIndex(nearestIndex);
          }
        }

        handleScroll(details, context);
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
