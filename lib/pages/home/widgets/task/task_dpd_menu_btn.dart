import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/utils/dialog_keys.dart';
import 'package:todo_cat/widgets/dropdown_menu_btn.dart';

class MenuItem {
  String title;
  IconData iconData;
  VoidCallback callback;

  MenuItem({
    required this.title,
    required this.iconData,
    required this.callback,
  });
}

class TaskDropDownMenuBtn extends StatelessWidget {
  const TaskDropDownMenuBtn({super.key, required List<MenuItem> menuItems})
      : _menuItems = menuItems;

  final List<MenuItem> _menuItems;

  @override
  Widget build(BuildContext context) {
    return DropdownManuBtn(
      id: taskDropDownMenuBtnTag,
      content: Container(
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
                  leading: Icon(
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
      ),
      child: const Center(
        child: Icon(
          Icons.more_horiz,
          color: Color.fromRGBO(129, 127, 158, 1),
        ),
      ),
    );
  }
}
