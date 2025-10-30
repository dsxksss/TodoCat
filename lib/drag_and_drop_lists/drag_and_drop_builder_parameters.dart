import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:todo_cat/drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:todo_cat/drag_and_drop_lists/drag_handle.dart';
import 'package:flutter/widgets.dart';

// Forward declarations to avoid circular dependencies
// These classes are defined in their respective files
// Using abstract classes so they can be used as types
abstract class DragAndDropItemTargetBase {}
abstract class DragAndDropListTargetBase {}

// These typedefs match the ones in drag_and_drop_lists.dart
// We need them here to avoid circular dependencies
typedef ListOnWillAccept = bool Function(
  DragAndDropListInterface? incoming,
  DragAndDropListInterface? target,
);
typedef ListTargetOnWillAccept = bool Function(
  DragAndDropListInterface? incoming,
  DragAndDropListTargetBase target,
);
typedef ItemOnWillAccept = bool Function(
  DragAndDropItem? incoming,
  DragAndDropItem target,
);
typedef ItemTargetOnWillAccept = bool Function(
  DragAndDropItem? incoming,
  DragAndDropItemTargetBase target,
);
typedef OnListDraggingChanged = void Function(
  DragAndDropListInterface? list,
  bool dragging,
);
typedef OnItemDraggingChanged = void Function(
  DragAndDropItem item,
  bool dragging,
);

typedef OnPointerMove = void Function(PointerMoveEvent event);
typedef OnPointerUp = void Function(PointerUpEvent event);
typedef OnPointerDown = void Function(PointerDownEvent event);
typedef OnItemReordered = void Function(
  DragAndDropItem reorderedItem,
  DragAndDropItem receiverItem,
);
typedef OnItemDropOnLastTarget = void Function(
  DragAndDropItem newOrReorderedItem,
  DragAndDropListInterface parentList,
  DragAndDropItemTargetBase receiver,
);
typedef OnListReordered = void Function(
  DragAndDropListInterface reorderedList,
  DragAndDropListInterface receiverList,
);

class DragAndDropBuilderParameters {
  final OnPointerMove? onPointerMove;
  final OnPointerUp? onPointerUp;
  final OnPointerDown? onPointerDown;
  final OnItemReordered? onItemReordered;
  final OnItemDropOnLastTarget? onItemDropOnLastTarget;
  final OnListReordered? onListReordered;
  final ListOnWillAccept? listOnWillAccept;
  final ListTargetOnWillAccept? listTargetOnWillAccept;
  final OnListDraggingChanged? onListDraggingChanged;
  final ItemOnWillAccept? itemOnWillAccept;
  final ItemTargetOnWillAccept? itemTargetOnWillAccept;
  final OnItemDraggingChanged? onItemDraggingChanged;
  final Axis axis;
  final CrossAxisAlignment verticalAlignment;
  final double? listDraggingWidth;
  final bool dragOnLongPress;
  final int itemSizeAnimationDuration;
  final Widget? itemGhost;
  final double itemGhostOpacity;
  final Widget? itemDivider;
  final double? itemDraggingWidth;
  final Decoration? itemDecorationWhileDragging;
  final int listSizeAnimationDuration;
  final Widget? listGhost;
  final double listGhostOpacity;
  final EdgeInsets? listPadding;
  final Decoration? listDecoration;
  final Decoration? listDecorationWhileDragging;
  final Decoration? listInnerDecoration;
  final double listWidth;
  final double lastItemTargetHeight;
  final bool addLastItemTargetHeightToTop;
  final DragHandle? listDragHandle;
  final DragHandle? itemDragHandle;
  final bool constrainDraggingAxis;
  final bool disableScrolling;

  DragAndDropBuilderParameters({
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerDown,
    this.onItemReordered,
    this.onItemDropOnLastTarget,
    this.onListReordered,
    this.listDraggingWidth,
    this.listOnWillAccept,
    this.listTargetOnWillAccept,
    this.onListDraggingChanged,
    this.itemOnWillAccept,
    this.itemTargetOnWillAccept,
    this.onItemDraggingChanged,
    this.dragOnLongPress = true,
    this.axis = Axis.vertical,
    this.verticalAlignment = CrossAxisAlignment.start,
    this.itemSizeAnimationDuration = 150,
    this.itemGhostOpacity = 0.3,
    this.itemGhost,
    this.itemDivider,
    this.itemDraggingWidth,
    this.itemDecorationWhileDragging,
    this.listSizeAnimationDuration = 150,
    this.listGhostOpacity = 0.3,
    this.listGhost,
    this.listPadding,
    this.listDecoration,
    this.listDecorationWhileDragging,
    this.listInnerDecoration,
    this.listWidth = double.infinity,
    this.lastItemTargetHeight = 20,
    this.addLastItemTargetHeightToTop = false,
    this.listDragHandle,
    this.itemDragHandle,
    this.constrainDraggingAxis = true,
    this.disableScrolling = false,
  });
}

