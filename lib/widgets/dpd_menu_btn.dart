import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/utils/dialog_keys.dart';
import 'package:todo_cat/widgets/dropdown_menu_btn.dart';

class MenuItem {
  String title;
  IconData? iconData;
  VoidCallback callback;

  MenuItem({
    this.iconData,
    required this.title,
    required this.callback,
  });
}

class DPDMenuContent extends StatelessWidget {
  const DPDMenuContent({super.key, required List<MenuItem> menuItems})
      : _menuItems = menuItems;
  final List<MenuItem> _menuItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border.all(width: 0.5, color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          ..._menuItems.map(
            (item) => Material(
              type: MaterialType.transparency,
              child: ListTile(
                minLeadingWidth: 0,
                hoverColor: context.theme.dividerColor,
                leading: item.iconData == null
                    ? null
                    : Icon(
                        item.iconData,
                        color: item.title == 'delete'
                            ? Colors.redAccent.shade200
                            : null,
                        size: 18,
                      ),
                title: Text(
                  item.title.tr,
                  style: TextStyle(
                    color: item.title == 'delete'
                        ? Colors.redAccent.shade200
                        : null,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  item.callback();
                  SmartDialog.dismiss(tag: taskDropDownMenuBtnTag);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

void showDpdMenu({
  required String tag,
  required List<MenuItem> menuItems,
  required BuildContext targetContext,
  void Function()? onDismiss,
  SmartDialogController? controller,
}) {
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
