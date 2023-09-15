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
  final AppController controller = Get.find();

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
    updateWindowStatus();
  }

  @override
  void onWindowMove() {
    updateWindowStatus();
    super.onWindowMove();
  }

  @override
  void onWindowMaximize() {
    updateWindowStatus();
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    updateWindowStatus();
    super.onWindowUnmaximize();
  }

  @override
  void onWindowEnterFullScreen() {
    updateWindowStatus();
    super.onWindowEnterFullScreen();
  }

  @override
  void onWindowLeaveFullScreen() {
    updateWindowStatus();
    super.onWindowLeaveFullScreen();
  }

  void minimizeWindow() async {
    await windowManager.minimize();
  }

  void updateWindowStatus() async {
    final maximized = await windowManager.isMaximized();
    controller.isMaximize.value = maximized;
    final fullScreen = await windowManager.isFullScreen();
    controller.isFullScreen.value = fullScreen;
  }

  void targetMaximizeWindow() async {
    if (controller.isMaximize.value) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    updateWindowStatus();
  }

  void closeWindow() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onTapCancel: () => {windowManager.startDragging()},
      child: Column(
        children: [
          SizedBox(
            height: Platform.isMacOS ? 30 : 0,
          ),
          Container(
            width: 1.sw,
            color: context.theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                        "${"myTasks".tr} ${runMode.name}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate(delay: 1000.ms).moveY(
                            begin: -150,
                            duration: 1000.ms,
                            curve: Curves.bounceInOut,
                          ),
                    ],
                  ),
                  if (Platform.isMacOS)
                    Row(
                      children: [
                        NavBarBtn(
                          onPressed: () => controller.targetThemeMode(),
                          child: const Icon(
                            Icons.nights_stay,
                            size: 25,
                          )
                              .animate(
                                  target: controller.appConfig.value.isDarkMode
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
                                          .rotate(end: 0.1, duration: 200.ms)),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        NavBarBtn(
                          onPressed: () => controller.changeLanguage(
                            Get.locale == const Locale("zh", "CN")
                                ? const Locale("en", "US")
                                : const Locale("zh", "CN"),
                          ),
                          child: const Icon(
                            Icons.g_translate,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  if (!Platform.isMacOS)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NavBarBtn(
                          onPressed: () => controller.targetThemeMode(),
                          child: const Icon(
                            Icons.nights_stay,
                            size: 25,
                          )
                              .animate(
                                  target: controller.appConfig.value.isDarkMode
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
                                          .rotate(end: 0.1, duration: 200.ms)),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        NavBarBtn(
                          onPressed: () => controller.changeLanguage(
                            Get.locale == const Locale("zh", "CN")
                                ? const Locale("en", "US")
                                : const Locale("zh", "CN"),
                          ),
                          child: const Icon(
                            Icons.g_translate,
                            size: 22,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        NavBarBtn(
                          onPressed: minimizeWindow,
                          child: const Icon(FontAwesomeIcons.minus),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        NavBarBtn(
                          onPressed: targetMaximizeWindow,
                          child: Transform.scale(
                            scale: 0.8,
                            child: Obx(
                              () => Icon(
                                controller.isMaximize.value
                                    ? FontAwesomeIcons.windowRestore
                                    : FontAwesomeIcons.square,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        NavBarBtn(
                          onPressed: closeWindow,
                          hoverColor: Colors.redAccent.shade100,
                          child: const Icon(
                            FontAwesomeIcons.xmark,
                            color: Colors.redAccent,
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
        ],
      ),
    );
  }
}

class NavBarBtn extends StatelessWidget {
  const NavBarBtn(
      {super.key, this.onPressed, required this.child, this.hoverColor});
  final Function? onPressed;
  final Color? hoverColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimationBtn(
      onHoverScale: 1.2,
      onPressed: onPressed,
      hoverBgColor: hoverColor,
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
        child: child,
      ),
    );
  }
}
