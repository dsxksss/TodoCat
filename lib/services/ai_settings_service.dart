import 'dart:convert';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:todo_cat/config/ai_config.dart';

/// 运行时 AI / LLM 配置（DeepSeek API Key / Base URL / Model）。
///
/// 取值优先级：用户在「设置 → AI 配置」中保存的值 > 编译期 [AiConfig]
/// （`--dart-define-from-file=secrets.json` 注入）的默认值。
///
/// 配置以明文 JSON 存储于应用文档目录的 `ai_config.json`，仅供本机使用——
/// 与 secrets.json 同样的安全级别（客户端内嵌的 key 都可能被逆向提取）。
class AiSettingsService {
  AiSettingsService._();

  static final AiSettingsService _instance = AiSettingsService._();

  /// 全局单例（与项目其余服务一致的 `.to` 取法）。
  static AiSettingsService get to => _instance;

  final _logger = Logger();

  static const _fileName = 'ai_config.json';

  String _apiKey = AiConfig.apiKey;
  String _baseUrl = AiConfig.baseUrl;
  String _model = AiConfig.model;

  /// 当前生效的 API Key（可能来自用户配置或编译期默认值）。
  String get apiKey => _apiKey;

  /// 当前生效的 API Base URL。
  String get baseUrl => _baseUrl;

  /// 当前生效的模型 id。
  String get model => _model;

  /// 是否已配置可用的 API Key。
  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<File> _configFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  /// 启动时调用：加载本地配置并应用到全局 OpenAI 客户端。
  Future<void> init() async {
    await load();
    apply();
  }

  /// 从本地文件加载用户配置（缺省项回退到编译期默认值）。
  Future<void> load() async {
    try {
      final file = await _configFile();
      if (!await file.exists()) return;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final key = (json['apiKey'] as String?)?.trim();
      final base = (json['baseUrl'] as String?)?.trim();
      final model = (json['model'] as String?)?.trim();
      if (key != null && key.isNotEmpty) _apiKey = key;
      if (base != null && base.isNotEmpty) _baseUrl = base;
      if (model != null && model.isNotEmpty) _model = model;
    } catch (e) {
      _logger.e('加载 AI 配置失败: $e');
    }
  }

  /// 保存用户输入并立即应用。
  ///
  /// [baseUrl] / [model] 传空时回退到编译期默认值（[AiConfig]）。
  Future<void> save({
    required String apiKey,
    String? baseUrl,
    String? model,
  }) async {
    _apiKey = apiKey.trim();
    _baseUrl = (baseUrl == null || baseUrl.trim().isEmpty)
        ? AiConfig.baseUrl
        : baseUrl.trim();
    _model = (model == null || model.trim().isEmpty)
        ? AiConfig.model
        : model.trim();

    try {
      final file = await _configFile();
      await file.writeAsString(jsonEncode({
        'apiKey': _apiKey,
        'baseUrl': _baseUrl,
        'model': _model,
      }));
    } catch (e) {
      _logger.e('保存 AI 配置失败: $e');
    }
    apply();
  }

  /// 清除本地配置，回退到编译期默认值。
  Future<void> clear() async {
    try {
      final file = await _configFile();
      if (await file.exists()) await file.delete();
    } catch (e) {
      _logger.e('清除 AI 配置失败: $e');
    }
    _apiKey = AiConfig.apiKey;
    _baseUrl = AiConfig.baseUrl;
    _model = AiConfig.model;
    apply();
  }

  /// 把当前配置应用到全局 OpenAI 客户端。
  void apply() {
    OpenAI.baseUrl = _baseUrl;
    if (_apiKey.isNotEmpty) {
      OpenAI.apiKey = _apiKey;
    }
  }
}
