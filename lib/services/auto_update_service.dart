import 'dart:io';
import 'package:desktop_updater/desktop_updater.dart' show DesktopUpdateLocalization;
import 'package:desktop_updater/updater_controller.dart' show DesktopUpdaterController;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 自动更新服务
/// 支持 Windows、macOS 和 Linux 平台的应用内更新
class AutoUpdateService {
  static final _logger = Logger();
  
  // 更新源 URL - 使用 Gitee 托管
  static const String _appArchiveUrl = 'https://gitee.com/dsxksss/TodoCat/releases/download/test_desk_update/app-archive.json';
  
  DesktopUpdaterController? _controller;
  bool _isInitialized = false;
  
  /// 获取更新控制器
  DesktopUpdaterController? get controller => _controller;
  
  /// 初始化自动更新服务
  Future<void> initialize() async {
    // 仅支持桌面平台
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      _logger.d('Auto update is only supported on desktop platforms');
      return;
    }
    
    if (_isInitialized) {
      _logger.d('Auto update service already initialized');
      return;
    }
    
    try {
      // 创建 DesktopUpdaterController
      // 根据 desktop_updater 包的文档：https://github.com/MarlonJD/flutter_desktop_updater
      _controller = DesktopUpdaterController(
        appArchiveUrl: Uri.parse(_appArchiveUrl),
        localization: DesktopUpdateLocalization(
          updateAvailableText: 'updateAvailable'.tr,
          newVersionAvailableText: '{} {} ${'newVersionAvailable'.tr}',
          newVersionLongText: '${'newVersionAvailable'.tr}\n${'bugFixesAndImprovements'.tr}\n\n${'checkForUpdatesDescription'.tr}',
          restartText: 'updateNow'.tr,
          warningTitleText: 'update'.tr,
          restartWarningText: '${'updateAvailable'.tr}\n${'checkForUpdatesDescription'.tr}\n\n${'later'.tr}',
          warningCancelText: 'later'.tr,
          warningConfirmText: 'updateNow'.tr,
        ),
      );
      
      _isInitialized = true;
      _logger.i('Auto update service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize auto update service: $e');
    }
  }
  
  /// 手动检查更新
  Future<bool> checkForUpdates({bool silent = false}) async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      _logger.d('Auto update is only supported on desktop platforms');
      return false;
    }
    
    try {
      if (!_isInitialized || _controller == null) {
        await initialize();
      }
      
      if (_controller == null) {
        _logger.e('DesktopUpdaterController is null');
        return false;
      }
      
      // DesktopUpdaterController 会自动检查更新
      // 更新检查通过 UpdateDialogListener 监听并显示对话框
      // 不需要手动调用 checkForUpdates 方法
      _logger.i('Update check is handled automatically by DesktopUpdaterController');
      
      if (!silent) {
        // 显示简单提示
        Get.snackbar(
          'update'.tr,
          'checkForUpdatesDescription'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      
      return true;
    } catch (e) {
      _logger.e('Error checking for updates: $e');
      
      if (!silent) {
        Get.snackbar(
          'error'.tr,
          'updateError'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
      
      return false;
    }
  }
  
  /// 获取当前版本信息
  static Future<String?> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      _logger.e('Error getting version: $e');
      return null;
    }
  }
  
  /// 检查更新是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 清理资源
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
