import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:window_manager/window_manager.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    this.rightWidgets,
    this.leftWidgets,
    this.title,
  });

  final String? title;
  final List<Widget>? leftWidgets;
  final List<Widget>? rightWidgets;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with WindowListener {
  final AppController _appController = Get.find();
  final Rx<String> currentRoute = Get.currentRoute.obs;
  final double _iconSize = 25;

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
    _appController.updateWindowStatus();
  }

  @override
  void onWindowMove() {
    _appController.updateWindowStatus();
    super.onWindowMove();
  }

  @override
  void onWindowMaximize() {
    _appController.updateWindowStatus();
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    _appController.updateWindowStatus();
    super.onWindowUnmaximize();
  }

  @override
  void onWindowEnterFullScreen() {
    _appController.updateWindowStatus();
    super.onWindowEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    _appController.updateWindowStatus();
    super.onWindowLeaveFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onTapCancel: () => {if (!context.isPhone) windowManager.startDragging()},
      child: Column(
        children: [
          Container(
            width: 1.sw,
            color: context.theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (currentRoute.value != "/")
                        NavBarBtn(
                          onPressed: Get.back,
                          child: const Icon(
                            size: 30,
                            Icons.keyboard_arrow_left_sharp,
                          ),
                        ),
                      ...?widget.leftWidgets,
                      if (widget.title != null)
                        SizedBox(
                          width: context.isPhone ? 120 : 300,
                          child: Text(
                            widget.title ?? "",
                            style: TextStyle(
                              fontSize: context.isPhone ? 24 : 25,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: context.isPhone
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [...?widget.rightWidgets],
                      ),
                      if (Platform.isWindows && !context.isPhone)
                        Row(
                          children: [
                            NavBarBtn(
                              onPressed: _appController.minimizeWindow,
                              child: Icon(
                                Icons.remove_rounded,
                                size: _iconSize,
                              ),
                            ),
                            2.horizontalSpace,
                            NavBarBtn(
                              onPressed: _appController.targetMaximizeWindow,
                              child: Obx(
                                () => Icon(
                                  _appController.isMaximize.value
                                      ? Icons.close_fullscreen_rounded
                                      : Icons.crop_square_rounded,
                                  size: _iconSize,
                                ),
                              ),
                            ),
                            2.horizontalSpace,
                            NavBarBtn(
                              onPressed: _appController.closeWindow,
                              hoverColor: Colors.redAccent,
                              child: Icon(
                                Icons.close_rounded,
                                size: _iconSize,
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarBtn extends StatelessWidget {
  const NavBarBtn(
      {super.key,
      required VoidCallback onPressed,
      required Widget child,
      Color? hoverColor})
      : _child = child,
        _hoverColor = hoverColor,
        _onPressed = onPressed;
  final VoidCallback _onPressed;
  final Color? _hoverColor;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onHoverScale: 1.2,
      onPressed: _onPressed,
      hoverBgColor: _hoverColor,
      onHoverBgColorChangeEnabled: true,
      onHoverAnimationEnabled: false,
      child: Container(
        decoration: BoxDecoration(
          // color: const Color.fromRGBO(245, 245, 247, 1),
          borderRadius: BorderRadius.circular(
            5,
          ),
          // border: Border.all(color: Colors.black54, width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 2,
        ),
        child: _child,
      ),
    );
  }
}
