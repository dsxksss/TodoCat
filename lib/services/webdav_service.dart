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
  factory WebDavConfig.fromShareKey(String key) {
    try {
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
}
