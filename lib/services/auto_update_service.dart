import 'dart:io';
import 'package:desktop_updater/desktop_updater.dart' show DesktopUpdateLocalization;
import 'package:desktop_updater/updater_controller.dart' show DesktopUpdaterController;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';

/// 自动更新服务
/// 支持 Windows、macOS 和 Linux 平台的应用内更新
/// 支持多个更新源，自动回退
class AutoUpdateService {
  static final _logger = Logger();
  
  // 更新源 URL 列表（按优先级排序）
  static const List<String> _appArchiveUrls = [
    'https://gitee.com/dsxksss/TodoCat/raw/main/updates/app-archive.json', // Gitee 主源
    'https://raw.githubusercontent.com/dsxksss/TodoCat/refs/heads/main/updates/app-archive.json', // GitHub 备用源
  ];
  
  DesktopUpdaterController? _controller;
  bool _isInitialized = false;
  int _currentSourceIndex = 0; // 当前使用的更新源索引
  
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
    
    // 尝试从多个更新源初始化
    await _tryInitializeWithFallback();
  }
  
  /// 尝试从多个更新源初始化（带回退机制）
  Future<void> _tryInitializeWithFallback() async {
    for (int i = 0; i < _appArchiveUrls.length; i++) {
      try {
        final url = _appArchiveUrls[i];
        _logger.d('尝试初始化更新服务，使用源 ${i + 1}/${_appArchiveUrls.length}: $url');
        
        // 先验证 URL 是否可访问
        final isAccessible = await _checkUrlAccessibility(url);
        if (!isAccessible) {
          _logger.w('更新源不可访问: $url，尝试下一个源');
          continue;
        }
        
        // 创建 DesktopUpdaterController
        // 根据 desktop_updater 包的文档：https://github.com/MarlonJD/flutter_desktop_updater
        _controller = DesktopUpdaterController(
          appArchiveUrl: Uri.parse(url),
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
        
        _currentSourceIndex = i;
        _isInitialized = true;
        _logger.i('更新服务初始化成功，使用源 ${i + 1}: $url');
        return;
      } catch (e) {
        _logger.w('使用源 ${i + 1} 初始化失败: $e');
        if (i < _appArchiveUrls.length - 1) {
          _logger.d('尝试下一个更新源...');
        } else {
          _logger.e('所有更新源都初始化失败');
        }
      }
    }
    
    // 如果所有源都失败，至少尝试使用第一个源（让 desktop_updater 自己处理错误）
    if (!_isInitialized && _appArchiveUrls.isNotEmpty) {
      try {
        _logger.w('所有源验证失败，尝试使用主源（可能工作）');
        _controller = DesktopUpdaterController(
          appArchiveUrl: Uri.parse(_appArchiveUrls[0]),
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
        _currentSourceIndex = 0;
        _isInitialized = true;
      } catch (e) {
        _logger.e('最终初始化失败: $e');
      }
    }
  }
  
  /// 检查 URL 是否可访问
  Future<bool> _checkUrlAccessibility(String url) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      
      final response = await dio.head(url);
      return response.statusCode == 200;
    } catch (e) {
      _logger.d('URL 访问检查失败: $url, 错误: $e');
      return false;
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
  
  /// 获取当前使用的更新源 URL
  String? get currentUpdateSource {
    if (_currentSourceIndex >= 0 && _currentSourceIndex < _appArchiveUrls.length) {
      return _appArchiveUrls[_currentSourceIndex];
    }
    return null;
  }
  
  /// 获取当前使用的更新源名称
  String get currentUpdateSourceName {
    if (_currentSourceIndex >= 0 && _currentSourceIndex < _appArchiveUrls.length) {
      final url = _appArchiveUrls[_currentSourceIndex];
      if (url.contains('gitee.com')) {
        return 'Gitee';
      } else if (url.contains('github.com')) {
        return 'GitHub';
      }
      return '更新源 ${_currentSourceIndex + 1}';
    }
    return '未知';
  }
  
  /// 清理资源
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _currentSourceIndex = 0;
  }
}
