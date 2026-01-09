import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class WebDavConfig {
  final String url;
  final String username;
  final String password;

  WebDavConfig({
    required this.url,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'username': username,
        'password': password,
      };

  factory WebDavConfig.fromJson(Map<String, dynamic> json) {
    return WebDavConfig(
      url: json['url'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  /// Convert config to a base64 "Share Key"
  String toShareKey() {
    final jsonStr = jsonEncode(toJson());
    return base64Encode(utf8.encode(jsonStr));
  }

  /// Create config from a base64 "Share Key"
  factory WebDavConfig.fromShareKey(String keyInput) {
    try {
      String key = keyInput.trim();
      // Handle metadata format:
      // TodoCat Workspace: Name
      // Key: BASE64...
      if (key.contains('Key:')) {
        key = key.split('Key:').last.trim();
      }

      final jsonStr = utf8.decode(base64Decode(key));
      return WebDavConfig.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      throw Exception('Invalid Share Key');
    }
  }
}

class WebDavService {
  final WebDavConfig config;
  late final Dio _dio;
  final _logger = Logger();

  WebDavService(this.config) {
    _dio = Dio(BaseOptions(
      baseUrl: config.url.endsWith('/') ? config.url : '${config.url}/',
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${config.username}:${config.password}'))}',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
  }

  /// Check if the connection works and create the base folder if needed
  Future<bool> checkConnection() async {
    try {
      // Try to list root
      final response = await _dio.request(
        '',
        options: Options(method: 'PROPFIND', headers: {'Depth': '1'}),
      );

      if (response.statusCode == 207 || response.statusCode == 200) {
        return true;
      }
      _logger.w(
          'WebDAV check connection failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      _logger.e('WebDAV check connection error: $e');
      return false;
    }
  }

  /// Ensure a directory exists (MKCOL)
  Future<void> ensureDirectory(String path) async {
    // Basic implementation: attempt to create. If invalid, might need recursive creation.
    // For now, assume single level for 'TodoCat'
    try {
      final response = await _dio.request(
        path,
        options: Options(method: 'MKCOL'),
      );
      if (response.statusCode == 201) return;
      if (response.statusCode == 405) {
        return; // Created (Method Not Allowed often means exists)
      }
      _logger.d('MKCOL $path status: ${response.statusCode}');
    } catch (e) {
      _logger.e('MKCOL error: $e');
    }
  }

  Future<void> uploadFile(String fileName, String content) async {
    try {
      await _dio.put(
        fileName,
        data: content,
        options: Options(contentType: 'application/json'),
      );
      _logger.d('Uploaded $fileName');
    } catch (e) {
      _logger.e('Upload error: $e');
      rethrow;
    }
  }

  Future<void> uploadFileBytes(String fileName, List<int> bytes) async {
    try {
      await _dio.put(
        fileName,
        data: Stream.fromIterable([bytes]),
        options: Options(
          contentType: 'application/octet-stream',
          headers: {
            Headers.contentLengthHeader: bytes.length,
          },
        ),
      );
      _logger.d('Uploaded bytes $fileName');
    } catch (e) {
      _logger.e('Upload bytes error: $e');
      rethrow;
    }
  }

  Future<String?> downloadFile(String fileName) async {
    try {
      final response = await _dio.get(
        fileName,
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode == 200) {
        return response.data as String;
      }
      if (response.statusCode == 404) {
        return null;
      }
      throw Exception('Download failed with status ${response.statusCode}');
    } catch (e) {
      _logger.e('Download error: $e');
      rethrow;
    }
  }

  Future<List<int>?> downloadFileBytes(String fileName) async {
    try {
      final response = await _dio.get(
        fileName,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        return response.data as List<int>;
      }
      if (response.statusCode == 404) {
        return null;
      }
      throw Exception(
          'Download bytes failed with status ${response.statusCode}');
    } catch (e) {
      _logger.e('Download bytes error: $e');
      rethrow;
    }
  }

  Future<bool> checkFileExists(String path) async {
    try {
      final response = await _dio.head(path);
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return false;
      }
      _logger.w('Check file exists error: $e');
      return false;
    }
  }

  /// Recursively ensure a directory exists
  Future<void> recursiveEnsureDirectory(String path) async {
    // Trim slashes
    var p = path;
    if (p.startsWith('/')) p = p.substring(1);
    if (p.endsWith('/')) p = p.substring(0, p.length - 1);

    final parts = p.split('/');
    String currentPath = '';

    for (final part in parts) {
      if (currentPath.isEmpty) {
        currentPath = part;
      } else {
        currentPath = '$currentPath/$part';
      }
      await ensureDirectory(currentPath);
    }
  }

  /// List files in a directory (returns simple names/paths)
  Future<List<String>> listDirectory(String path) async {
    try {
      final response = await _dio.request(
        path,
        options: Options(
          method: 'PROPFIND',
          headers: {'Depth': '1'},
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode == 207 && response.data != null) {
        final xml = response.data.toString();
        // Regex to extract hrefs. Handles <D:href> or <href> with various namespaces.
        // Captures content between > and <
        final regex = RegExp(r'<([a-zA-Z0-9]+:)?href>(.*?)<\/\1?href>');
        final matches = regex.allMatches(xml);

        final List<String> files = [];
        final rootPathEncoded = Uri.encodeFull(config.url + path);

        for (final match in matches) {
          var href = match.group(2) ?? '';
          // Decode generic URL encoding
          href = Uri.decodeFull(href);

          // Remove potential server URL prefix if present in href
          // Many WebDAV servers return full URL or absolute path
          // We want the relative path or just the filename for logic
          // But typically we just want to know what's there.

          // Optimization: just return the full hrefs or relative to the search path?
          // Let's filter out the directory itself.

          // Normalize href for comparison
          String normalizedHref = href;
          if (normalizedHref.endsWith('/')) {
            normalizedHref =
                normalizedHref.substring(0, normalizedHref.length - 1);
          }
          String normalizedPath = path;
          if (config.url.endsWith(path)) {
            // If config.url includes the path? No, path is relative to baseUrl usually?
            // Actually _dio has baseUrl. path arg is relative.
          }

          // Simple check: if it equals the requested directory, skip
          if (href.endsWith(path) || href.endsWith('$path/')) {
            // Check if it really is the root (could be a file with same name prefix?)
            // Usually the first item is the folder itself.
            // Let's just collect all and let caller filter.
          }
          files.add(href);
        }
        return files;
      }
      return [];
    } catch (e) {
      _logger.e('List directory error: $e');
      return [];
    }
  }

  Future<void> deletePath(String path) async {
    try {
      final response = await _dio.request(
        path,
        options: Options(method: 'DELETE'),
      );
      _logger.d('Delete $path status: ${response.statusCode}');
    } catch (e) {
      _logger.e('Delete error: $e');
      rethrow;
    }
  }
}
