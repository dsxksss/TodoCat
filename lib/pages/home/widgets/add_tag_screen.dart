import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/home/controller.dart';

class AddTagScreen extends StatelessWidget {
  AddTagScreen({super.key});

  final AddTodoDialogController _ctrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      ..._ctrl.selectedTags.map(
                        (tag) => Container(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _ctrl
                                    .removeTag(_ctrl.selectedTags.indexOf(tag)),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        TextField(
          maxLength: 6,
          controller: _ctrl.tagController,
          decoration: InputDecoration(
            counter: const Text(''),
            suffix: TextButton(
              // 取消按钮按下时出现的颜色
              style: const ButtonStyle(
                overlayColor: MaterialStatePropertyAll(Colors.transparent),
                backgroundColor: MaterialStatePropertyAll(Colors.lightBlue),
              ),
              onPressed: () => {_ctrl.addTag()},
              child: Text(
                "addTag".tr,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            filled: true, // 是否填充背景色
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            hintStyle: const TextStyle(color: Colors.grey),
            hintText: "${"enter".tr}${"tag".tr}",
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}
