import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:TodoCat/core/notification_center_manager.dart';
import 'package:TodoCat/data/schemas/notification_history.dart';
import 'package:TodoCat/widgets/show_toast.dart';

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
  
  bool _isInitialized = false;
  int _currentSourceIndex = 0; // 当前使用的更新源索引
  
  // 下载相关
  CancelToken? _downloadCancelToken;
  Dio? _downloadDio;
  DateTime? _lastProgressUpdate; // 上次进度更新时间（用于节流）
  static const Duration _progressUpdateInterval = Duration(milliseconds: 200); // 进度更新间隔（200ms）
  
  // 更新进度回调
  Function(double progress, String status)? onProgress;
  Function(String version, String? changelog)? onUpdateAvailable;
  Function()? onUpdateComplete;
  Function(String error)? onUpdateError;
  Function()? onAlreadyLatestVersion; // 已是最新版本的回调
  
  // 当前更新信息
  Map<String, dynamic>? _currentUpdateInfo;
  
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
    
    // 如果所有源都失败，至少尝试使用第一个源
    if (!_isInitialized && _appArchiveUrls.isNotEmpty) {
      _logger.w('所有源验证失败，使用主源（可能工作）');
      _currentSourceIndex = 0;
      _isInitialized = true;
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
      // 通知开始检查更新
      onProgress?.call(0.0, 'checkingForUpdates'.tr);
      
      // 手动检查版本（用于显示进度和通知）
      await _checkUpdateManually();
      
      if (!silent) {
        // 显示自定义 toast 提示
        showToast(
          'checkingForUpdates'.tr,
          toastStyleType: TodoCatToastStyleType.info,
          position: TodoCatToastPosition.bottomLeft,
          displayTime: const Duration(seconds: 2),
        );
      }
      
      return true;
    } catch (e) {
      _logger.e('Error checking for updates: $e');
      onUpdateError?.call(e.toString());
      
      if (!silent) {
        // 显示自定义 toast 错误提示
        showToast(
          'updateError'.tr,
          toastStyleType: TodoCatToastStyleType.error,
          position: TodoCatToastPosition.bottomLeft,
          displayTime: const Duration(seconds: 3),
        );
      }
      
      return false;
    }
  }
  
  /// 手动检查更新（通过解析 app-archive.json）
  Future<void> _checkUpdateManually() async {
    try {
      final currentVersion = await getCurrentVersion();
      if (currentVersion == null) {
        _logger.w('无法获取当前版本');
        return;
      }
      
      // 从当前使用的更新源获取更新信息
      final archiveUrl = currentUpdateSource;
      if (archiveUrl == null) {
        _logger.w('更新源未设置');
        return;
      }
      
      onProgress?.call(0.1, 'downloadingUpdateInfo'.tr);
      
      // 下载并解析 app-archive.json
      final dio = Dio();
      final response = await dio.get(archiveUrl);
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;
        
        if (items != null && items.isNotEmpty) {
          // 找到当前平台的更新项
          String? platform;
          if (Platform.isWindows) {
            platform = 'windows';
          } else if (Platform.isMacOS) {
            platform = 'macos';
          } else if (Platform.isLinux) {
            platform = 'linux';
          }
          
          // 筛选出匹配当前平台的所有项
          final platformItems = items.where((item) => item['platform'] == platform).toList();
          
          // 如果没有匹配平台的项，使用所有项
          final itemsToCheck = platformItems.isNotEmpty ? platformItems : items;
          
          // 找到版本号最大的项（最新版本）
          Map<String, dynamic>? latestItem;
          String? latestVersion;
          
          for (var item in itemsToCheck) {
            final version = item['version'] as String;
            if (latestVersion == null || _compareVersions(version, latestVersion) > 0) {
              latestVersion = version;
              latestItem = item as Map<String, dynamic>;
            }
          }
          
          if (latestItem != null && latestVersion != null) {
            final newVersion = latestVersion;
            final changes = latestItem['changes'] as List<dynamic>?;
            
            _logger.d('当前版本: $currentVersion, 最新版本: $newVersion');
            
            // 比较版本
            if (_compareVersions(newVersion, currentVersion) > 0) {
              // 发现新版本，保存更新信息
              _currentUpdateInfo = latestItem;
              
              // 发现新版本
              final changelog = changes?.map((c) => c['message'] as String).join('\n');
              onUpdateAvailable?.call(newVersion, changelog);
              
              // 发送通知到通知中心
              _notifyUpdateAvailable(newVersion, changelog);
              
              _logger.i('发现新版本 $newVersion');
            } else {
              // 已是最新版本
              onProgress?.call(1.0, 'alreadyLatestVersion'.tr);
              onAlreadyLatestVersion?.call();
              _logger.i('当前已是最新版本: $currentVersion');
            }
          }
        }
      }
    } catch (e) {
      _logger.e('检查更新失败: $e');
      onUpdateError?.call(e.toString());
    }
  }
  
  /// 比较版本号
  int _compareVersions(String version1, String version2) {
    try {
      // 移除 build number（如果有）
      final v1 = version1.split('+')[0];
      final v2 = version2.split('+')[0];
      
      final v1Parts = v1.split('.').map(int.parse).toList();
      final v2Parts = v2.split('.').map(int.parse).toList();
      
      for (int i = 0; i < v1Parts.length || i < v2Parts.length; i++) {
        final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
        final v2Part = i < v2Parts.length ? v2Parts[i] : 0;
        
        if (v1Part > v2Part) return 1;
        if (v1Part < v2Part) return -1;
      }
      
      return 0;
    } catch (e) {
      _logger.e('版本比较失败: $e');
      return 0;
    }
  }
  
  /// 发送更新可用通知到通知中心
  /// 使用版本号进行去重，避免重复通知
  Future<void> _notifyUpdateAvailable(String version, String? changelog) async {
    try {
      if (Get.isRegistered<NotificationCenterManager>()) {
        final notificationCenter = Get.find<NotificationCenterManager>();
        
        // 检查是否已经有相同版本的通知（基于消息中的版本号去重）
        final now = DateTime.now();
        final windowStart = now.subtract(const Duration(hours: 24)); // 24小时内相同版本不重复通知
        
        final hasVersionDuplicate = notificationCenter.notifications.any((n) {
          return n.title == 'updateAvailable'.tr && 
                 n.message.contains(version) &&
                 n.timestamp.isAfter(windowStart);
        });
        
        if (hasVersionDuplicate) {
          _logger.d('版本 $version 的通知已存在，跳过重复通知');
          return;
        }
        
        await notificationCenter.addNotification(
          title: 'updateAvailable'.tr,
          message: '${'newVersionAvailable'.tr}: $version${changelog != null ? '\n\n$changelog' : ''}',
          level: NotificationLevel.info,
          skipDuplicateCheck: true, // 跳过通用的重复检查，因为我们用了版本号检查
        );
        _logger.i('已发送更新通知到通知中心: $version');
      }
    } catch (e) {
      _logger.w('发送更新通知失败: $e');
    }
  }
  
  /// 获取当前版本信息
  static Future<String?> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      AutoUpdateService._logger.e('Error getting version: $e');
      return null;
    }
  }
  
  /// 检查更新是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 下载并安装更新
  Future<void> downloadAndInstallUpdate() async {
    if (_currentUpdateInfo == null) {
      _logger.e('没有可用的更新信息');
      onUpdateError?.call('没有可用的更新信息');
      return;
    }
    
    try {
      final downloadUrl = _currentUpdateInfo!['url'] as String?;
      if (downloadUrl == null || downloadUrl.isEmpty) {
        _logger.e('更新 URL 为空');
        onUpdateError?.call('更新 URL 为空');
        return;
      }
      
      _logger.d('开始下载更新: $downloadUrl');
      onProgress?.call(0.0, 'downloadingUpdate'.tr);
      
      // 创建取消令牌
      _downloadCancelToken = CancelToken();
      
      // 创建下载目录
      final tempDir = await getTemporaryDirectory();
      final downloadDir = Directory(path.join(tempDir.path, 'TodoCat_updates'));
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      
      // 从 URL 获取文件名
      final fileName = path.basename(downloadUrl);
      final filePath = path.join(downloadDir.path, fileName);
      
      // 创建 Dio 实例用于下载
      _downloadDio = Dio();
      
      // 配置超时和连接选项，优化下载性能
      _downloadDio!.options.connectTimeout = const Duration(seconds: 30);
      _downloadDio!.options.receiveTimeout = const Duration(hours: 1); // 大文件下载可能需要较长时间
      
      // 下载文件（带进度回调，节流更新）
      await _downloadDio!.download(
        downloadUrl,
        filePath,
        cancelToken: _downloadCancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            final now = DateTime.now();
            
            // 节流进度更新，避免过于频繁的UI更新
            if (_lastProgressUpdate == null || 
                now.difference(_lastProgressUpdate!) >= _progressUpdateInterval ||
                progress >= 1.0) { // 完成时总是更新
              _lastProgressUpdate = now;
              onProgress?.call(progress, 'downloadingUpdate'.tr);
              
              // 减少日志输出频率（每10%或完成时输出）
              if (progress >= 1.0 || (progress * 10).floor() != ((progress - 0.01) * 10).floor()) {
                _logger.d('下载进度: ${(progress * 100).toStringAsFixed(1)}%');
              }
            }
          }
        },
      );
      
      _logger.d('下载完成: $filePath');
      onProgress?.call(1.0, 'installingUpdate'.tr);
      
      // 跳过哈希验证，直接安装更新
      // 注意：Windows MSIX 包已有数字签名验证，哈希验证是额外的安全检查
      
      // 安装更新
      await _installUpdate(filePath);
      
      // 通知完成
      onUpdateComplete?.call();
      
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        _logger.i('下载已取消');
        onUpdateError?.call('下载已取消');
      } else {
        _logger.e('下载或安装更新失败: $e');
        onUpdateError?.call(e.toString());
      }
    } finally {
      _downloadCancelToken = null;
      _downloadDio = null;
      _lastProgressUpdate = null; // 重置进度更新时间戳
    }
  }
  
  /// 安装更新
  Future<void> _installUpdate(String filePath) async {
    try {
      if (Platform.isWindows) {
        // Windows: 使用 start 命令启动 MSIX 安装
        _logger.d('开始安装 MSIX 包: $filePath');
        
        // 启动安装程序（不等待完成）
        Process.start(
          'cmd',
          ['/c', 'start', '', filePath],
          runInShell: true,
          mode: ProcessStartMode.detached,
        );
        
        _logger.d('MSIX 安装已启动');
        
        // 等待一小段时间，让安装程序启动
        await Future.delayed(const Duration(seconds: 3));
        
        // 退出应用，让安装程序完成安装
        // 使用额外的延迟确保消息队列清空，避免线程通信错误
        await Future.delayed(const Duration(milliseconds: 500));
        exit(0);
      } else if (Platform.isMacOS) {
        // macOS: 使用 open 命令打开 DMG 或 PKG
        _logger.d('开始安装 macOS 包: $filePath');
        final process = await Process.start(
          'open',
          [filePath],
        );
        
        await process.exitCode;
        _logger.d('macOS 安装已启动');
        
        // 退出应用
        exit(0);
      } else if (Platform.isLinux) {
        // Linux: 根据文件类型使用不同的安装方法
        _logger.d('开始安装 Linux 包: $filePath');
        
        if (filePath.endsWith('.deb')) {
          // Debian/Ubuntu: 使用 dpkg 或 gdebi
          final process = await Process.start(
            'gdebi',
            ['-n', filePath],
            runInShell: true,
          );
          await process.exitCode;
        } else if (filePath.endsWith('.rpm')) {
          // RedHat/Fedora: 使用 rpm
          final process = await Process.start(
            'rpm',
            ['-i', filePath],
            runInShell: true,
          );
          await process.exitCode;
        } else if (filePath.endsWith('.AppImage')) {
          // AppImage: 直接执行
          final process = await Process.start(
            'chmod',
            ['+x', filePath],
          );
          await process.exitCode;
          
          final runProcess = await Process.start(
            filePath,
            [],
            runInShell: true,
          );
          await runProcess.exitCode;
        }
        
        _logger.d('Linux 安装已启动');
        exit(0);
      }
    } catch (e) {
      _logger.e('安装更新失败: $e');
      rethrow;
    }
  }
  
  /// 取消下载
  void cancelDownload() {
    if (_downloadCancelToken != null && !_downloadCancelToken!.isCancelled) {
      _downloadCancelToken!.cancel('用户取消下载');
      _logger.i('下载已取消');
    }
  }
  
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
    cancelDownload();
    _downloadDio?.close();
    _downloadDio = null;
    _downloadCancelToken = null;
    _isInitialized = false;
    _currentSourceIndex = 0;
    _currentUpdateInfo = null;
  }
}
