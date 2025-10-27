import 'dart:io';
import 'package:auto_updater/auto_updater.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 自动更新服务
/// 支持 Windows 和 macOS 平台的应用内更新
class AutoUpdateService {
  static final _logger = Logger();
  
  // 更新源 URL - 使用 Gitee 托管
  static const String _feedURL = 'https://gitee.com/dsxksss/TodoCat/raw/main/updates/appcast.xml';
  
  bool _isInitialized = false;
  bool _isCheckingForUpdates = false;
  
  /// 初始化自动更新服务
  Future<void> initialize() async {
    // 仅支持 Windows 和 macOS
    if (!Platform.isWindows && !Platform.isMacOS) {
      _logger.d('Auto update is only supported on Windows and macOS');
      return;
    }
    
    if (_isInitialized) {
      _logger.d('Auto update service already initialized');
      return;
    }
    
    try {
      // 设置更新源 URL
      await autoUpdater.setFeedURL(_feedURL);
      
      // 设置自动检查间隔（86400秒 = 24小时）
      // 最小值 3600 秒（1小时），0 表示禁用自动检查
      await autoUpdater.setScheduledCheckInterval(86400);
      
      _isInitialized = true;
      _logger.i('Auto update service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize auto update service: $e');
    }
  }
  
  /// 手动检查更新
  Future<bool> checkForUpdates({bool silent = false}) async {
    if (!Platform.isWindows && !Platform.isMacOS) {
      _logger.d('Auto update is only supported on Windows and macOS');
      return false;
    }
    
    if (_isCheckingForUpdates) {
      _logger.d('Update check already in progress');
      return false;
    }
    
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      _isCheckingForUpdates = true;
      
      // 检查更新 - 这会触发系统原生的更新对话框
      await autoUpdater.checkForUpdates();
      
      _logger.i('Check for updates initiated');
      
      // 延迟重置状态
      Future.delayed(const Duration(seconds: 2), () {
        _isCheckingForUpdates = false;
      });
      
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
      _isCheckingForUpdates = false;
      
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
  
  /// 检查更新是否可用
  bool get isUpdateAvailable => _isCheckingForUpdates;
  
  /// 取消当前更新检查
  void cancelUpdateCheck() {
    _isCheckingForUpdates = false;
  }
}

