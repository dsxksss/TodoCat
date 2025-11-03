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

  MenuItem({
    this.iconData,
    required this.title,
    required this.callback,
    this.isDisabled = false,
  });
}

/// 菜单内容组件，显示菜单项
class DPDMenuContent extends StatelessWidget {
  const DPDMenuContent({super.key, required List<MenuItem> menuItems})
      : _menuItems = menuItems;
  final List<MenuItem> _menuItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120, // 最小宽度
        maxWidth: 300, // 最大宽度，防止过长文本撑破布局
      ),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border.all(width: 0.5, color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              _menuItems.map((item) => _buildMenuItem(context, item)).toList(),
        ),
      ),
    );
  }

  /// 构建单个菜单项
  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    final bool isDelete = item.title == 'delete';
    final bool isDisabled = item.isDisabled;

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        enabled: !isDisabled,
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        hoverColor: isDisabled ? Colors.transparent : context.theme.hoverColor,
        leading: item.iconData == null
            ? null
            : Icon(
                item.iconData,
                color: isDelete ? Colors.redAccent.shade200 : null,
                size: 18,
              ),
        title: Text(
          item.title.tr,
          style: TextStyle(
            color: isDisabled
                ? Colors.grey
                : (isDelete ? Colors.redAccent.shade200 : null),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.visible, // 允许文本完整显示
        ),
        onTap: isDisabled
            ? null
            : () {
                item.callback();
                SmartDialog.dismiss(tag: dropDownMenuBtnTag);
              },
      ),
    );
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
      content: DPDMenuContent(menuItems: _menuItems),
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
    builder: (context) => DPDMenuContent(menuItems: menuItems),
  );
}
