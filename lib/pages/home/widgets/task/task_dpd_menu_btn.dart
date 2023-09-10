import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
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
  const TaskDropDownMenuBtn({super.key, required this.menuItems});

  final List<MenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    return DropdownManuBtn(
      id: "TaskDropDownMenuBtn",
      content: Container(
        width: 120,
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          border: Border.all(color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            ...menuItems.map(
              (item) => ListTile(
                minLeadingWidth: 0,
                leading: Icon(
                  item.iconData,
                  color:
                      item.title == 'delete' ? Colors.redAccent.shade200 : null,
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
                  SmartDialog.dismiss(tag: 'TaskDropDownMenuBtn');
                },
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
