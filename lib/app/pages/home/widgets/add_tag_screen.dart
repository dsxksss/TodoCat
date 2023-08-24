import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app/pages/home/controller.dart';

class AddTagScreen extends StatelessWidget {
  AddTagScreen({super.key});

  final HomeController ctrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.w),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "addTag".tr,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromRGBO(17, 10, 76, 1),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.w),
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.w),
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...ctrl.selectedTags.map(
                        (tag) => Container(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(
                              5.w,
                            ),
                          ),
                          margin: EdgeInsets.only(right: 20.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.w),
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ctrl
                                    .removeTag(ctrl.selectedTags.indexOf(tag)),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 30.w,
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
          controller: ctrl.tagController,
          decoration: InputDecoration(
            suffix: TextButton(
              // 取消按钮按下时出现的颜色
              style: const ButtonStyle(
                overlayColor: MaterialStatePropertyAll(Colors.transparent),
              ),
              onPressed: () => {ctrl.addTag()},
              child: Text(
                "addTag".tr,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),

            filled: true, // 是否填充背景色
            fillColor: const Color.fromRGBO(248, 250, 251, 1),
            border: InputBorder.none,

            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            hintStyle: const TextStyle(color: Colors.grey),
            hintText: "${"enter".tr}${"tag".tr}",
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.w),
            ),
          ),
        ),
      ],
    );
  }
}
