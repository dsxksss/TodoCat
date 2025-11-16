import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

/// 视频下载服务
/// 负责下载视频文件并缓存到本地
class VideoDownloadService {
  static final _logger = Logger();
  static final VideoDownloadService _instance = VideoDownloadService._internal();
  factory VideoDownloadService() => _instance;
  VideoDownloadService._internal();

  Dio? _dio;
  final Map<String, CancelToken> _downloadTokens = {};
  final Map<String, DateTime> _lastProgressUpdate = {};
  static const Duration _progressUpdateInterval = Duration(milliseconds: 200);

  /// 获取缓存目录
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDir.path, 'video_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// 根据URL生成缓存文件名
  String _getCacheFileName(String url) {
    // 使用URL的哈希值作为文件名，避免特殊字符问题
    final uri = Uri.parse(url);
    final fileName = path.basename(uri.path);
    if (fileName.isEmpty || !fileName.contains('.')) {
      // 如果没有文件名或扩展名，使用URL的哈希值
      return '${url.hashCode}.mp4';
    }
    return fileName;
  }

  /// 获取缓存的视频文件路径
  Future<String?> getCachedVideoPath(String url) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final fileName = _getCacheFileName(url);
      final filePath = path.join(cacheDir.path, fileName);
      final file = File(filePath);
      
      if (await file.exists()) {
        _logger.d('找到缓存的视频文件: $filePath');
        return filePath;
      }
      return null;
    } catch (e) {
      _logger.e('获取缓存视频路径失败: $e');
      return null;
    }
  }

  /// 检查视频是否已缓存
  Future<bool> isVideoCached(String url) async {
    final cachedPath = await getCachedVideoPath(url);
    return cachedPath != null;
  }

  /// 下载视频
  /// [url] 视频下载URL
  /// [onProgress] 进度回调 (progress: 0.0-1.0)
  /// [onComplete] 完成回调 (filePath: 本地文件路径)
  /// [onError] 错误回调 (error: 错误信息)
  Future<void> downloadVideo(
    String url, {
    Function(double progress)? onProgress,
    Function(String filePath)? onComplete,
    Function(String error)? onError,
  }) async {
    try {
      // 检查是否已缓存
      final cachedPath = await getCachedVideoPath(url);
      if (cachedPath != null) {
        _logger.d('视频已缓存，直接返回: $cachedPath');
        onComplete?.call(cachedPath);
        return;
      }

      // 创建取消令牌
      final cancelToken = CancelToken();
      _downloadTokens[url] = cancelToken;

      // 创建缓存目录
      final cacheDir = await _getCacheDirectory();
      final fileName = _getCacheFileName(url);
      final filePath = path.join(cacheDir.path, fileName);

      // 创建 Dio 实例
      _dio ??= Dio();
      _dio!.options.connectTimeout = const Duration(seconds: 30);
      _dio!.options.receiveTimeout = const Duration(hours: 1);

      _logger.d('开始下载视频: $url -> $filePath');
      onProgress?.call(0.0);

      // 下载文件
      await _dio!.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            final now = DateTime.now();

            // 节流进度更新
            if (_lastProgressUpdate[url] == null ||
                now.difference(_lastProgressUpdate[url]!) >= _progressUpdateInterval ||
                progress >= 1.0) {
              _lastProgressUpdate[url] = now;
              onProgress?.call(progress);

              // 减少日志输出频率
              if (progress >= 1.0 || (progress * 10).floor() != ((progress - 0.01) * 10).floor()) {
                _logger.d('视频下载进度: ${(progress * 100).toStringAsFixed(1)}%');
              }
            }
          }
        },
      );

      _logger.d('视频下载完成: $filePath');
      onProgress?.call(1.0);
      onComplete?.call(filePath);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        _logger.i('视频下载已取消: $url');
        onError?.call('下载已取消');
      } else {
        _logger.e('视频下载失败: $e');
        onError?.call(e.toString());
      }
    } finally {
      _downloadTokens.remove(url);
      _lastProgressUpdate.remove(url);
    }
  }

  /// 取消下载
  void cancelDownload(String url) {
    final cancelToken = _downloadTokens[url];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
      _logger.d('取消视频下载: $url');
    }
    _downloadTokens.remove(url);
    _lastProgressUpdate.remove(url);
  }

  /// 删除缓存的视频
  Future<bool> deleteCachedVideo(String url) async {
    try {
      final cachedPath = await getCachedVideoPath(url);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          await file.delete();
          _logger.d('已删除缓存的视频: $cachedPath');
          return true;
        }
      }
      return false;
    } catch (e) {
      _logger.e('删除缓存视频失败: $e');
      return false;
    }
  }

  /// 清理所有缓存的视频
  Future<void> clearAllCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        _logger.d('已清理所有视频缓存');
      }
    } catch (e) {
      _logger.e('清理视频缓存失败: $e');
    }
  }
}

