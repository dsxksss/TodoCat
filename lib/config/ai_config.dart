/// AI / LLM 服务配置。
///
/// 敏感信息（API Key 等）**不写入源码**，通过编译期
/// `--dart-define-from-file=secrets.json` 注入；`secrets.json` 已加入 .gitignore。
///
/// 本地开发：复制 `secrets.example.json` 为 `secrets.json`，填入你自己的 key，然后：
///   flutter run   -d windows --dart-define-from-file=secrets.json
///   flutter build windows    --dart-define-from-file=secrets.json
///
/// ⚠️ 注意：客户端 App 内嵌的任何 key 都可能被逆向提取，要做到真正安全需后端代理转发。
/// 本方案仅解决“明文密钥进入 git 仓库”的问题。
class AiConfig {
  const AiConfig._();

  /// API Key（来自 --dart-define-from-file，默认空 = 未配置）。
  static const String apiKey = String.fromEnvironment('DEEPSEEK_API_KEY');

  /// API Base URL（默认 DeepSeek 原生接口）。
  static const String baseUrl = String.fromEnvironment(
    'DEEPSEEK_BASE_URL',
    defaultValue: 'https://api.deepseek.com',
  );

  /// 模型 id（DeepSeek 原生：deepseek-chat / deepseek-reasoner）。
  static const String model = String.fromEnvironment(
    'DEEPSEEK_MODEL',
    defaultValue: 'deepseek-chat',
  );

  /// 是否已配置 API Key。
  static bool get isConfigured => apiKey.isNotEmpty;
}
