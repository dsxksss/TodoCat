import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:todo_cat/drag_and_drop_lists/drag_handle.dart';
import 'package:todo_cat/drag_and_drop_lists/measure_size.dart';
import 'package:flutter/material.dart';

class DragAndDropListWrapper extends StatefulWidget {
  final DragAndDropListInterface dragAndDropList;
  final DragAndDropBuilderParameters parameters;

  const DragAndDropListWrapper(
      {required this.dragAndDropList, required this.parameters, super.key});

  @override
  State<StatefulWidget> createState() => _DragAndDropListWrapper();
}

class _DragAndDropListWrapper extends State<DragAndDropListWrapper>
    with TickerProviderStateMixin {
  DragAndDropListInterface? _hoveredDraggable;

  bool _dragging = false;
  Size _containerSize = Size.zero;
  Size _dragHandleSize = Size.zero;
  
  // 跟踪当前正在被拖拽的列表（来自其他列表的拖拽反馈）
  DragAndDropListInterface? _currentlyDraggedList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget dragAndDropListContents =
        widget.dragAndDropList.generateWidget(widget.parameters);

    Widget draggable;
    if (widget.dragAndDropList.canDrag) {
      if (widget.parameters.listDragHandle != null) {
        Widget dragHandle = MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: widget.parameters.listDragHandle,
        );

        Widget feedback =
            buildFeedbackWithHandle(dragAndDropListContents, dragHandle);

        draggable = MeasureSize(
          onSizeChange: (size) {
            setState(() {
              _containerSize = size!;
            });
          },
          child: Stack(
            children: [
              // 使用 Opacity 隐藏内容但始终占位，避免原位置被挤占
              Opacity(
                opacity: _dragging ? 0.0 : 1.0,
                child: dragAndDropListContents,
              ),
              Positioned(
                right: widget.parameters.listDragHandle!.onLeft ? null : 0,
                left: widget.parameters.listDragHandle!.onLeft ? 0 : null,
                top: _dragHandleDistanceFromTop(),
                child: Draggable<DragAndDropListInterface>(
                  data: widget.dragAndDropList,
                  axis: draggableAxis(),
                  feedback: Transform.translate(
                    offset: _feedbackContainerOffset(),
                    child: feedback,
                  ),
                  // childWhenDragging 替换的是 child（即 dragHandle）
                  childWhenDragging: Container(),
                  onDragStarted: () => _setDragging(true),
                  onDragCompleted: () => _setDragging(false),
                  onDraggableCanceled: (_, __) => _setDragging(false),
                  onDragEnd: (_) => _setDragging(false),
                  child: MeasureSize(
                    onSizeChange: (size) {
                      setState(() {
                        _dragHandleSize = size!;
                      });
                    },
                    child: dragHandle,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (widget.parameters.dragOnLongPress) {
        draggable = MeasureSize(
          onSizeChange: (size) {
            setState(() {
              _containerSize = size!;
            });
          },
          child: LongPressDraggable<DragAndDropListInterface>(
            data: widget.dragAndDropList,
            axis: draggableAxis(),
            feedback:
                buildFeedbackWithoutHandle(context, dragAndDropListContents),
            childWhenDragging: Container(),
            onDragStarted: () => _setDragging(true),
            onDragCompleted: () => _setDragging(false),
            onDraggableCanceled: (_, __) => _setDragging(false),
            onDragEnd: (_) => _setDragging(false),
            child: Visibility(
              visible: !_dragging,
              maintainSize: true, // 保持尺寸，确保空间不丢失
              maintainAnimation: true, // 保持动画状态
              maintainState: true, // 保持状态
              child: dragAndDropListContents,
            ),
          ),
        );
      } else {
        draggable = MeasureSize(
          onSizeChange: (size) {
            setState(() {
              _containerSize = size!;
            });
          },
          child: Draggable<DragAndDropListInterface>(
            data: widget.dragAndDropList,
            axis: draggableAxis(),
            feedback:
                buildFeedbackWithoutHandle(context, dragAndDropListContents),
            childWhenDragging: Container(),
            onDragStarted: () => _setDragging(true),
            onDragCompleted: () => _setDragging(false),
            onDraggableCanceled: (_, __) => _setDragging(false),
            onDragEnd: (_) => _setDragging(false),
            child: Visibility(
              visible: !_dragging,
              maintainSize: true, // 保持尺寸，确保空间不丢失
              maintainAnimation: true, // 保持动画状态
              maintainState: true, // 保持状态
              child: dragAndDropListContents,
            ),
          ),
        );
      }
    } else {
      draggable = dragAndDropListContents;
    }

    var rowOrColumnChildren = <Widget>[
      // 目标位置显示 ghost，使用 AnimatedSize 实现平滑动画
      AnimatedSize(
        duration:
            Duration(milliseconds: widget.parameters.listSizeAnimationDuration),
        curve: Curves.easeInOut, // 使用缓动曲线，使动画更自然
        alignment: Alignment.topLeft, // 使用 start-start 对齐（左上角）
        child: _hoveredDraggable != null && !_isHoveredDraggableSelf()
            ? Opacity(
                opacity: widget.parameters.listGhostOpacity,
                child: widget.parameters.listGhost ??
                    Container(
                      padding: widget.parameters.axis == Axis.vertical
                          ? const EdgeInsets.all(0)
                          : EdgeInsets.symmetric(
                              horizontal:
                                  widget.parameters.listPadding!.horizontal),
                      child:
                          _hoveredDraggable!.generateWidget(widget.parameters),
                    ),
              )
            : SizedBox.shrink(), // 使用 SizedBox.shrink() 而不是 Container()，确保动画更平滑
      ),
      // 使用 AnimatedSize 包裹 draggable，确保原位置空间变化的动画平滑
      AnimatedSize(
        duration:
            Duration(milliseconds: widget.parameters.listSizeAnimationDuration),
        curve: Curves.easeInOut,
        alignment: Alignment.topLeft, // 使用 start-start 对齐（左上角）
        child: Listener(
          onPointerMove: _onPointerMove,
          onPointerDown: widget.parameters.onPointerDown,
          onPointerUp: widget.parameters.onPointerUp,
          child: draggable,
        ),
      ),
    ];

    var stack = Stack(
      children: <Widget>[
        widget.parameters.axis == Axis.vertical
            ? Column(
                crossAxisAlignment: widget.parameters.verticalAlignment, // 使用 verticalAlignment
                children: rowOrColumnChildren,
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start, // start-start 对齐
                children: rowOrColumnChildren,
              ),
        Positioned.fill(
          child: DragTarget<DragAndDropListInterface>(
            builder: (context, candidateData, rejectedData) {
              if (candidateData.isNotEmpty) {}
              return Container();
            },
            onWillAcceptWithDetails: (details) {
              bool accept = true;
              if (widget.parameters.listOnWillAccept != null) {
                accept = widget.parameters.listOnWillAccept!(
                    details.data, widget.dragAndDropList);
              }
              // 判断拖拽的是不是自己
              bool isDraggingSelf = false;
              if (details.data.key != null && widget.dragAndDropList.key != null) {
                isDraggingSelf = details.data.key == widget.dragAndDropList.key;
              } else {
                isDraggingSelf = details.data == widget.dragAndDropList;
              }
              if (isDraggingSelf || _dragging) {
                setState(() {
                  _hoveredDraggable = null;
                });
                return false;
              }
              if (accept && mounted) {
                setState(() {
                  _hoveredDraggable = details.data;
                });
              }
              return accept;
            },
            onLeave: (data) {
              if (mounted) {
                setState(() {
                  _hoveredDraggable = null;
                  // 如果离开的是当前被拖拽的列表，清除标记
                  final currentlyDragged = _currentlyDraggedList;
                  if (currentlyDragged != null && data != null) {
                    bool isLeavingDraggedList = false;
                    if (data.key != null && currentlyDragged.key != null) {
                      isLeavingDraggedList = data.key == currentlyDragged.key;
                    } else {
                      isLeavingDraggedList = data == currentlyDragged;
                    }
                    if (isLeavingDraggedList) {
                      _currentlyDraggedList = null;
                    }
                  }
                });
              }
            },
            onAcceptWithDetails: (details) {
              if (mounted) {
                setState(() {
                  widget.parameters.onListReordered!(
                      details.data, widget.dragAndDropList);
                  _hoveredDraggable = null;
                });
              }
            },
          ),
        ),
      ],
    );

    Widget toReturn = stack;
    if (widget.parameters.listPadding != null) {
      toReturn = Padding(
        padding: widget.parameters.listPadding!,
        child: stack,
      );
    }
    if (widget.parameters.axis == Axis.horizontal &&
        !widget.parameters.disableScrolling) {
      toReturn = SingleChildScrollView(
        child: Container(
          child: toReturn,
        ),
      );
    }

    return toReturn;
  }

  Material buildFeedbackWithHandle(
      Widget dragAndDropListContents, Widget dragHandle) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: widget.parameters.listDecorationWhileDragging,
        child: SizedBox(
          width: widget.parameters.listDraggingWidth ?? _containerSize.width,
          height: _containerSize.height > 0 ? _containerSize.height : null, // 设置高度，确保完整显示
          child: Stack(
            children: [
              Directionality(
                textDirection: Directionality.of(context),
                child: dragAndDropListContents,
              ),
              Positioned(
                right: widget.parameters.listDragHandle!.onLeft ? null : 0,
                left: widget.parameters.listDragHandle!.onLeft ? 0 : null,
                top: widget.parameters.listDragHandle!.verticalAlignment ==
                        DragHandleVerticalAlignment.bottom
                    ? null
                    : 0,
                bottom: widget.parameters.listDragHandle!.verticalAlignment ==
                        DragHandleVerticalAlignment.top
                    ? null
                    : 0,
                child: dragHandle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox buildFeedbackWithoutHandle(
      BuildContext context, Widget dragAndDropListContents) {
    return SizedBox(
      width: widget.parameters.axis == Axis.vertical
          ? (widget.parameters.listDraggingWidth ??
              MediaQuery.of(context).size.width)
          : (widget.parameters.listDraggingWidth ??
              widget.parameters.listWidth),
      height: _containerSize.height > 0 ? _containerSize.height : null, // 设置高度，确保完整显示
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: widget.parameters.listDecorationWhileDragging,
          child: Directionality(
            textDirection: Directionality.of(context),
            child: dragAndDropListContents,
          ),
        ),
      ),
    );
  }

  Axis? draggableAxis() {
    return widget.parameters.axis == Axis.vertical &&
            widget.parameters.constrainDraggingAxis
        ? Axis.vertical
        : null;
  }

  // 辅助方法
  bool _isHoveredDraggableSelf() {
    if (_hoveredDraggable == null) return false;
    if (_hoveredDraggable!.key != null && widget.dragAndDropList.key != null) {
      return _hoveredDraggable!.key == widget.dragAndDropList.key;
    }
    return _hoveredDraggable == widget.dragAndDropList;
  }

  bool _isCurrentlyDraggedListSelf() {
    if (_currentlyDraggedList == null) return false;
    // 检查当前被拖拽的列表是不是自己
    if (_currentlyDraggedList!.key != null && widget.dragAndDropList.key != null) {
      return _currentlyDraggedList!.key == widget.dragAndDropList.key;
    }
    return _currentlyDraggedList == widget.dragAndDropList;
  }

  double _dragHandleDistanceFromTop() {
    switch (widget.parameters.listDragHandle!.verticalAlignment) {
      case DragHandleVerticalAlignment.top:
        return 0;
      case DragHandleVerticalAlignment.center:
        return (_containerSize.height / 2.0) - (_dragHandleSize.height / 2.0);
      case DragHandleVerticalAlignment.bottom:
        return _containerSize.height - _dragHandleSize.height;
      default:
        return 0;
    }
  }

  Offset _feedbackContainerOffset() {
    double xOffset;
    double yOffset;
    if (widget.parameters.listDragHandle!.onLeft) {
      xOffset = 0;
    } else {
      xOffset = -_containerSize.width + _dragHandleSize.width;
    }
    if (widget.parameters.listDragHandle!.verticalAlignment ==
        DragHandleVerticalAlignment.bottom) {
      yOffset = -_containerSize.height + _dragHandleSize.width;
    } else {
      yOffset = 0;
    }

    return Offset(xOffset, yOffset);
  }

  void _setDragging(bool dragging) {
    if (_dragging != dragging && mounted) {
      setState(() {
        _dragging = dragging;
        // 当开始拖拽时，清除 ghost 和标记，避免原始位置显示 ghost
        if (dragging) {
          _hoveredDraggable = null;
          _currentlyDraggedList = widget.dragAndDropList; // 标记自己是正在被拖拽的列表
        } else {
          // 拖拽结束时，清除标记
          _currentlyDraggedList = null;
        }
      });
      if (widget.parameters.onListDraggingChanged != null) {
        widget.parameters.onListDraggingChanged!(
            widget.dragAndDropList, dragging);
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_dragging) widget.parameters.onPointerMove!(event);
  }
}
