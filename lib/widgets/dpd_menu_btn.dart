import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/dropdown_menu_btn.dart';

/// 菜单项类，包含标题、图标和回调函数
class MenuItem {
  String title;
  IconData? iconData;
  VoidCallback callback;
  bool isDisabled;
  // 可选的尾部操作按钮（显示在同一行右侧）
  IconData? trailingIcon;
  VoidCallback? trailingCallback;
  // 可选的尾部自定义 Widget（如果提供，将优先使用此 Widget 而不是 trailingIcon）
  Widget? trailingWidget;

  MenuItem({
    this.iconData,
    required this.title,
    required this.callback,
    this.isDisabled = false,
    this.trailingIcon,
    this.trailingCallback,
    this.trailingWidget,
  });
}

/// 菜单内容组件，显示菜单项
class DPDMenuContent extends StatelessWidget {
  const DPDMenuContent({
    super.key,
    required List<MenuItem> menuItems,
    String? tag,
    double? width, // 可选的固定宽度
    List<Widget>? additionalWidgets, // 可选的额外 Widget（如分割线）
  })  : _menuItems = menuItems,
        _tag = tag,
        _width = width,
        _additionalWidgets = additionalWidgets;
  final List<MenuItem> _menuItems;
  final String? _tag;
  final double? _width; // 可选的固定宽度
  final List<Widget>? _additionalWidgets; // 可选的额外 Widget

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 当检测到任何滚动事件时，关闭下拉菜单
        if (notification is ScrollUpdateNotification ||
            notification is ScrollStartNotification) {
          SmartDialog.dismiss(tag: _tag ?? dropDownMenuBtnTag);
        }
        return false; // 允许通知继续传播
      },
      child: Container(
        width: _width, // 如果指定了宽度，使用固定宽度；否则使用 IntrinsicWidth
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          border: Border.all(width: 0.5, color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: _width != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildMenuItems(context),
              )
            : IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildMenuItems(context),
                ),
              ),
      ),
    );
  }

  /// 构建菜单项列表
  List<Widget> _buildMenuItems(BuildContext context) {
    final List<Widget> widgets = [];
    // 添加菜单项
    for (final item in _menuItems) {
      widgets.add(_buildMenuItem(context, item));
    }
    // 添加额外的 Widget（如分割线）
    if (_additionalWidgets != null) {
      widgets.addAll(_additionalWidgets);
    }
    return widgets;
  }

  /// 构建单个菜单项（静态方法，供外部调用）
  static Widget buildMenuItem(BuildContext context, MenuItem item, [String? tag]) {
    final bool isDelete = item.title == 'delete';
    final bool isPermanentDelete = item.title == 'permanentDelete';
    final bool isRestore = item.title == 'restore';
    final bool isRedAction = isDelete || isPermanentDelete;
    final bool isDisabled = item.isDisabled;

    // 确定颜色
    Color? iconColor;
    Color? textColor;
    if (isRedAction) {
      iconColor = Colors.redAccent.shade200;
      textColor = Colors.redAccent.shade200;
    } else if (isRestore) {
      iconColor = Colors.greenAccent.shade700;
      textColor = Colors.greenAccent.shade700;
    }

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        enabled: !isDisabled,
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        isThreeLine: false,
        hoverColor: isDisabled ? Colors.transparent : context.theme.hoverColor,
        leading: item.iconData == null
            ? null
            : Icon(
                item.iconData,
                color: iconColor,
                size: 18,
              ),
        title: Tooltip(
          message: item.title.tr, // hover时显示完整内容
          waitDuration: const Duration(milliseconds: 500), // hover延迟时间
          child: Text(
            item.title.tr,
            style: TextStyle(
              color: isDisabled
                  ? Colors.grey
                  : textColor,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis, // 防止文字换行，超长时显示省略号
            maxLines: 1,
          ),
        ),
        trailing: item.trailingWidget != null
            ? item.trailingWidget
            : (item.trailingIcon != null && item.trailingCallback != null
                ? Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        item.trailingCallback!();
                        SmartDialog.dismiss(tag: tag ?? dropDownMenuBtnTag);
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          item.trailingIcon,
                          size: 18,
                          color: Colors.redAccent.shade200,
                        ),
                      ),
                    ),
                  )
                : null),
        onTap: isDisabled
            ? null
            : () {
                item.callback();
                SmartDialog.dismiss(tag: tag ?? dropDownMenuBtnTag);
              },
      ),
    );
  }

  /// 构建单个菜单项
  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return buildMenuItem(context, item, _tag);
  }
}

/// 下拉菜单按钮组件
class DPDMenuBtn extends StatelessWidget {
  const DPDMenuBtn(
      {super.key, required String tag, required List<MenuItem> menuItems})
      : _tag = tag,
        _menuItems = menuItems;

  final String _tag;
  final List<MenuItem> _menuItems;

  @override
  Widget build(BuildContext context) {
    return DropdownManuBtn(
      id: _tag,
      content: DPDMenuContent(menuItems: _menuItems, tag: _tag),
      child: const Center(
        child: Icon(
          Icons.more_horiz,
          color: Color.fromRGBO(129, 127, 158, 1),
        ),
      ),
    );
  }
}

/// 显示下拉菜单
void showDpdMenu({
  required String tag,
  required List<MenuItem> menuItems,
  required BuildContext targetContext,
  void Function()? onDismiss,
  SmartDialogController? controller,
}) async {
  SmartDialog.dismiss(tag: tag);
  SmartDialog.showAttach(
    onDismiss: onDismiss,
    tag: tag,
    targetContext: targetContext,
    debounce: true,
    keepSingle: true,
    usePenetrate: true,
    animationTime: 100.ms,
    controller: controller,
    alignment: Alignment.bottomRight,
    animationBuilder: (controller, child, animationParam) => child
        .animate(controller: controller)
        .fade(duration: controller.duration)
        .scaleXY(
          begin: 0.9,
          end: 1,
          curve: Curves.easeInOut,
          duration: controller.duration,
        ),
    builder: (context) => DPDMenuContent(menuItems: menuItems, tag: tag),
  );
}
