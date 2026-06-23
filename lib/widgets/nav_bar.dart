import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/core/utils/responsive.dart';
import 'package:todo_cat/routers/app_router.dart';
import 'package:todo_cat/widgets/animation_btn.dart';
import 'package:window_manager/window_manager.dart';

class NavBar extends ConsumerStatefulWidget {
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
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> with WindowListener {
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
    ref.read(windowControllerProvider.notifier).updateWindowStatus();
  }

  @override
  void onWindowMove() {
    ref.read(windowControllerProvider.notifier).updateWindowStatus();
    super.onWindowMove();
  }

  @override
  void onWindowMaximize() {
    ref.read(windowControllerProvider.notifier).updateWindowStatus();
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    ref.read(windowControllerProvider.notifier).updateWindowStatus();
    super.onWindowUnmaximize();
  }

  @override
  void onWindowEnterFullScreen() {
    ref.read(windowControllerProvider.notifier).updateWindowStatus();
    super.onWindowEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    ref.read(windowControllerProvider.notifier).updateWindowStatus();
    super.onWindowLeaveFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    final windowCtrl = ref.read(windowControllerProvider.notifier);
    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onTapCancel: () => {if (!context.isPhone) windowManager.startDragging()},
      child: Column(
        children: [
          Container(
            width: 1.sw,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (currentRoutePath != "/")
                        NavBarBtn(
                          onPressed: () => Navigator.of(context).pop(),
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
                              onPressed: windowCtrl.minimizeWindow,
                              child: Icon(
                                Icons.remove_rounded,
                                size: _iconSize,
                              ),
                            ),
                            2.horizontalSpace,
                            NavBarBtn(
                              onPressed: windowCtrl.targetMaximizeWindow,
                              child: Icon(
                                ref.watch(windowControllerProvider).isMaximize
                                    ? Icons.close_fullscreen_rounded
                                    : Icons.crop_square_rounded,
                                size: _iconSize,
                              ),
                            ),
                            2.horizontalSpace,
                            NavBarBtn(
                              onPressed: windowCtrl.closeWindow,
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
