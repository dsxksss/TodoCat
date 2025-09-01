import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/services/database.dart';
import 'package:logger/logger.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final AppController _appController = Get.find();
  static final _logger = Logger();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _logger.d('App lifecycle state changed to: $state');

    switch (state) {
      case AppLifecycleState.inactive:
        // 应用程序处于非活动状态（例如，来电或锁屏）
        _logger.d('App is inactive');
        break;
      case AppLifecycleState.paused:
        // 应用程序被挂起（进入后台）
        _logger.d('App is paused, saving data...');
        _saveDataBeforeBackground();
        break;
      case AppLifecycleState.resumed:
        // 应用程序从后台恢复到前台
        _logger.d('App is resumed');
        _appController.changeSystemOverlayUI();
        break;
      case AppLifecycleState.detached:
        // 应用程序已分离（例如，iOS上应用程序已被强制退出）
        _logger.d('App is detached, saving data before exit...');
        _saveDataBeforeExit();
        break;
      case AppLifecycleState.hidden:
        // 应用程序被隐藏
        _logger.d('App is hidden');
        break;
    }
  }

  /// 在应用进入后台前保存数据
  void _saveDataBeforeBackground() async {
    try {
      _logger.d('Saving task data before going to background...');
      final homeController = Get.find<HomeController>();
      await homeController.taskManager.forceSave();
      _logger.d('Task data saved successfully');
    } catch (e) {
      _logger.e('Error saving data before background: $e');
    }
  }

  /// 在应用退出前保存数据并关闭数据库
  void _saveDataBeforeExit() async {
    try {
      _logger.d('Saving all data before app exit...');
      
      // 保存任务数据
      final homeController = Get.find<HomeController>();
      await homeController.taskManager.forceSave();
      
      // 关闭数据库连接
      final database = await Database.getInstance();
      await database.close();
      
      _logger.d('All data saved and database closed successfully');
    } catch (e) {
      _logger.e('Error saving data before exit: $e');
    }
  }
}
