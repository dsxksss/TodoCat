import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/env.dart';
import 'package:window_manager/window_manager.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with WindowListener {
  bool isMaximize = false;

  @override
  void initState() {
    super.initState();
    updateMaximized();
  }

  void updateMaximized() async {
    final maximized = await windowManager.isMaximized();
    setState(() {
      isMaximize = maximized;
    });
  }

  void targetWindow() async {
    if (isMaximize) {
      await windowManager.restore();
    } else {
      await windowManager.maximize();
    }
    updateMaximized();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => {windowManager.startDragging()},
      child: Container(
        width: 1.w,
        color: isDebugMode ? Colors.greenAccent : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "myTasks".tr,
                style: TextStyle(
                  fontSize: 60.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.outlined(
                    onPressed: () {
                      windowManager.minimize();
                    },
                    icon: Icon(
                      Icons.horizontal_rule_rounded,
                      size: 45.w,
                    ),
                  ),
                  SizedBox(
                    width: isMaximize ? 30.w : 20.w,
                  ),
                  isMaximize
                      ? Padding(
                          padding: EdgeInsets.only(top: 15.w),
                          child: IconButton.outlined(
                            onPressed: targetWindow,
                            icon: Icon(
                              Icons.filter_none_rounded,
                              size: 30.w,
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 5.w),
                          child: IconButton.outlined(
                            onPressed: targetWindow,
                            icon: Icon(
                              Icons.crop_square_rounded,
                              size: 40.w,
                            ),
                          ),
                        ),
                  SizedBox(
                    width: 10.w,
                  ),
                  IconButton.outlined(
                    onPressed: () {
                      WindowManager.instance.close();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.red,
                      size: 46.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
