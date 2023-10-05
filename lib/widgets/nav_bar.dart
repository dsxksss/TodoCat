import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo_cat/app.dart';
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
  final AppController _appController = Get.find();

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
          SizedBox(
            height: Platform.isMacOS ? 30 : 5,
          ),
          Container(
            width: 1.sw,
            color: context.theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/imgs/logo-light-rounded.png',
                        width: 50,
                        height: 50,
                        filterQuality: FilterQuality.medium,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        context.isPhone
                            ? "myTasks".tr
                            : "${"myTasks".tr} ${runMode.name}",
                        style: TextStyle(
                          fontSize: context.isPhone ? 24 : 28,
                          fontWeight: FontWeight.bold,
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
                        children: [
                          NavBarBtn(
                            onPressed: () => _appController.targetThemeMode(),
                            child: const Icon(
                              Icons.nights_stay,
                              size: 25,
                            )
                                .animate(
                                    target: _appController
                                            .appConfig.value.isDarkMode
                                        ? 1
                                        : 0)
                                .fadeOut(duration: 200.ms)
                                .rotate(end: 0.1, duration: 200.ms)
                                .swap(
                                    builder: (_, __) => const Icon(
                                          Icons.light_mode,
                                          size: 25,
                                        )
                                            .animate()
                                            .fadeIn(duration: 200.ms)
                                            .rotate(
                                                end: 0.1, duration: 200.ms)),
                          ),
                          SizedBox(
                            width: context.isPhone ? 10 : 20,
                          ),
                          NavBarBtn(
                            onPressed: () => _appController.changeLanguage(
                              Get.locale == const Locale("zh", "CN")
                                  ? const Locale("en", "US")
                                  : const Locale("zh", "CN"),
                            ),
                            child: const Icon(
                              Icons.g_translate,
                              size: 22,
                            ),
                          ),
                          SizedBox(
                            width: context.isPhone ? 10 : 20,
                          ),
                          NavBarBtn(
                            onPressed: () => {},
                            child: const Icon(
                              Icons.filter_alt_outlined,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      if (Platform.isWindows && !context.isPhone)
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            NavBarBtn(
                              onPressed: _appController.minimizeWindow,
                              child: const Icon(FontAwesomeIcons.minus),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            NavBarBtn(
                              onPressed: _appController.targetMaximizeWindow,
                              child: Transform.scale(
                                scale: 0.8,
                                child: Obx(
                                  () => Icon(
                                    _appController.isMaximize.value
                                        ? FontAwesomeIcons.windowRestore
                                        : FontAwesomeIcons.square,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            NavBarBtn(
                              onPressed: _appController.closeWindow,
                              hoverColor: Colors.redAccent.shade100,
                              child: const Icon(
                                FontAwesomeIcons.xmark,
                                color: Colors.redAccent,
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
      Function? onPressed,
      required Widget child,
      Color? hoverColor})
      : _child = child,
        _hoverColor = hoverColor,
        _onPressed = onPressed;
  final Function? _onPressed;
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
