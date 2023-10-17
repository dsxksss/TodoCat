import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:todo_cat/pages/controller.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final AppController _appController = Get.find();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        // 应用程序处于非活动状态（例如，来电或锁屏）
        break;
      case AppLifecycleState.paused:
        // 应用程序被挂起（进入后台）
        break;
      case AppLifecycleState.resumed:
        // 应用程序从后台恢复到前台
        _appController.changeSystemOverlayUI();
        break;
      case AppLifecycleState.detached:
        // 应用程序已分离（例如，iOS上应用程序已被强制退出）
        break;
      case AppLifecycleState.hidden:
      // 应用程序被隐藏
    }
  }
}
