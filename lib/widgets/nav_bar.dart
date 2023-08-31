import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/env.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
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
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    updateMaximized();
  }

  @override
  void onWindowMove() {
    updateMaximized();
    super.onWindowMove();
  }

  void minimizeWindow() async {
    await windowManager.minimize();
  }

  void updateMaximized() async {
    final maximized = await windowManager.isMaximized();
    setState(() {
      isMaximize = maximized;
    });
  }

  void targetMaximizeWindow() async {
    if (isMaximize) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    updateMaximized();
  }

  void closeWindow() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => {windowManager.startDragging()},
      child: Container(
        width: 1.sw,
        color: Colors.blue,
        margin: Platform.isMacOS ? EdgeInsets.only(top: 20.w) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/imgs/logo.png',
                    width: 50.w,
                    height: 50.w,
                    filterQuality: FilterQuality.medium,
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  Text(
                    "${"myTasks".tr} ${runMode.name}",
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate(delay: 1000.ms).moveY(
                        begin: -150,
                        duration: 1000.ms,
                        curve: Curves.bounceInOut,
                      ),
                ],
              ),
              if (!Platform.isMacOS)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NavBarBtn(
                      onPressed: minimizeWindow,
                      child: const FaIcon(FontAwesomeIcons.minus),
                    ),
                    SizedBox(
                      width: 30.w,
                    ),
                    NavBarBtn(
                      onPressed: targetMaximizeWindow,
                      child: Transform.scale(
                        scale: 0.85,
                        child: FaIcon(
                          isMaximize
                              ? FontAwesomeIcons.windowRestore
                              : FontAwesomeIcons.square,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30.w,
                    ),
                    NavBarBtn(
                      onPressed: closeWindow,
                      child: const FaIcon(
                        FontAwesomeIcons.xmark,
                        color: Colors.red,
                      ),
                    ),
                  ]
                      .animate(interval: 100.ms, delay: 1000.ms)
                      .moveY(duration: 400.ms)
                      .fade(duration: 400.ms),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavBarBtn extends StatelessWidget {
  const NavBarBtn({super.key, this.onPressed, required this.child});
  final Function? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onHoverScale: 1.2,
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 6.w,
          vertical: 2.w,
        ),
        child: child,
      ),
    );
  }
}
