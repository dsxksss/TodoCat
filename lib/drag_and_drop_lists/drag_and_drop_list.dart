import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_item_target.dart';
import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DragAndDropList implements DragAndDropListInterface {
  /// The widget that is displayed at the top of the list.
  final Widget? header;

  /// The widget that is displayed at the bottom of the list.
  final Widget? footer;

  /// The widget that is displayed to the left of the list.
  final Widget? leftSide;

  /// The widget that is displayed to the right of the list.
  final Widget? rightSide;

  /// The widget to be displayed when a list is empty.
  /// If this is not null, it will override that set in [DragAndDropLists.contentsWhenEmpty].
  final Widget? contentsWhenEmpty;

  /// The widget to be displayed as the last element in the list that will accept
  /// a dragged item.
  final Widget? lastTarget;

  /// The decoration displayed around a list.
  /// If this is not null, it will override that set in [DragAndDropLists.listDecoration].
  final Decoration? decoration;

  /// The vertical alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.verticalAlignment].
  final CrossAxisAlignment verticalAlignment;

  /// The horizontal alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.horizontalAlignment].
  final MainAxisAlignment horizontalAlignment;

  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  @override
  final List<DragAndDropItem> children;

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  @override
  final bool canDrag;
  @override
  final Key? key;
  DragAndDropList({
    required this.children,
    this.key,
    this.header,
    this.footer,
    this.leftSide,
    this.rightSide,
    this.contentsWhenEmpty,
    this.lastTarget,
    this.decoration,
    this.horizontalAlignment = MainAxisAlignment.start,
    this.verticalAlignment = CrossAxisAlignment.start,
    this.canDrag = true,
  });

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    Widget intrinsicHeight = IntrinsicHeight(
      child: Row(
        mainAxisAlignment: horizontalAlignment,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _generateDragAndDropListInnerContents(params),
      ),
    );
    if (params.axis == Axis.horizontal) {
      intrinsicHeight = SizedBox(
        width: params.listWidth,
        child: intrinsicHeight,
      );
    }
    if (params.listInnerDecoration != null) {
      intrinsicHeight = Container(
        decoration: params.listInnerDecoration,
        child: intrinsicHeight,
      );
    }

    // 如果没有 header 和 footer，直接返回内容
    if (header == null && footer == null) {
      return Container(
        key: key,
        width: params.axis == Axis.vertical
            ? double.infinity
            : params.listWidth - params.listPadding!.horizontal,
        decoration: decoration ?? params.listDecoration,
        child: intrinsicHeight,
      );
    }

    // 有 header 或 footer 时，使用 Column 布局
    var contents = <Widget>[];
    if (header != null) {
      contents.add(header!);
    }
    // 对于水平布局和垂直布局，都使用 Flexible 来限制中间内容的高度
    // 这样可以避免溢出，并且内容可以在 SingleChildScrollView 中滚动
    contents.add(Flexible(
      child: intrinsicHeight,
    ));
    if (footer != null) {
      contents.add(footer!);
    }

    return Container(
      key: key,
      width: params.axis == Axis.vertical
          ? double.infinity
          : params.listWidth - params.listPadding!.horizontal,
      decoration: decoration ?? params.listDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: verticalAlignment,
        children: contents,
      ),
    );
  }

  List<Widget> _generateDragAndDropListInnerContents(
      DragAndDropBuilderParameters parameters) {
    var contents = <Widget>[];
    if (leftSide != null) {
      contents.add(leftSide!);
    }
    if (children.isNotEmpty) {
      List<Widget> allChildren = <Widget>[];
      if (parameters.addLastItemTargetHeightToTop) {
        allChildren.add(Padding(
          padding: EdgeInsets.only(top: parameters.lastItemTargetHeight),
        ));
      }
      for (int i = 0; i < children.length; i++) {
        allChildren.add(DragAndDropItemWrapper(
          key: children[i].key,
          child: children[i],
          parameters: parameters,
        ));
        if (parameters.itemDivider != null && i < children.length - 1) {
          allChildren.add(parameters.itemDivider!);
        }
      }
      allChildren.add(DragAndDropItemTarget(
        parent: this,
        parameters: parameters,
        onReorderOrAdd: parameters.onItemDropOnLastTarget!,
        child: lastTarget ??
            Container(
              height: parameters.lastItemTargetHeight,
            ),
      ));
      contents.add(
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => true,
            child: PrimaryScrollController(
              controller: ScrollController(),
              child: SingleChildScrollView(
                primary: true,
              // 对于水平布局，使用 ClampingScrollPhysics 限制滚动，防止影响父级 x 轴滚动
              // 对于垂直布局，使用 NeverScrollableScrollPhysics（由外部的 ScrollController 控制）
              physics: parameters.axis == Axis.horizontal 
                  ? const ClampingScrollPhysics() // 限制滚动范围，不影响父级
                  : const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: verticalAlignment,
                  mainAxisSize: MainAxisSize.min,
                  children: allChildren,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      contents.add(
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => true,
            child: PrimaryScrollController(
              controller: ScrollController(),
              child: SingleChildScrollView(
                primary: true,
              // 对于水平布局，使用 ClampingScrollPhysics 限制滚动，防止影响父级 x 轴滚动
              // 对于垂直布局，使用 NeverScrollableScrollPhysics（由外部的 ScrollController 控制）
              physics: parameters.axis == Axis.horizontal 
                  ? const ClampingScrollPhysics() // 限制滚动范围，不影响父级
                  : const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (contentsWhenEmpty != null) contentsWhenEmpty!,
                    DragAndDropItemTarget(
                      parent: this,
                      parameters: parameters,
                      onReorderOrAdd: parameters.onItemDropOnLastTarget!,
                      child: lastTarget ??
                          Container(
                            height: parameters.lastItemTargetHeight,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (rightSide != null) {
      contents.add(rightSide!);
    }
    return contents;
  }
}
