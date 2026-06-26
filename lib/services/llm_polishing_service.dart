import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/services/ai_settings_service.dart';

/// LLM 文案润色服务。
///
/// 原 GetX `GetxService` + `Get.find()` 单例已移除，改为普通 Dart 单例。
/// 调用点 `LlmPolishingService.to.polishText(...)` 保持不变。
class LlmPolishingService {
  LlmPolishingService._();

  static final LlmPolishingService _instance = LlmPolishingService._();

  /// 全局单例（替代原 `Get.find()`）。
  static LlmPolishingService get to => _instance;

  Future<String> polishText(String originalText) async {
    if (originalText.trim().isEmpty) {
      return "";
    }

    try {
      // 系统提示词：设定 AI 的角色和任务
      const systemPrompt = """
请作为一位专业的文案优化专家，润色用户提供的文本，使其更加专业、清晰且富有吸引力。
规则：
1. 语言适配：若原文是中文则输出中文，若原文是英文则输出英文。
2. 风格优化：保持原意的同时，提升表达的流畅度和专业感。
3. 格式规范：直接输出润色后的纯文本或markdown文本，严禁包含任何解释性文字（如“润色如下：”）、引号。
""";

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(originalText),
        ],
        role: OpenAIChatMessageRole.user,
      );

      // 调用 OpenAI 接口
      final completion = await OpenAI.instance.chat.create(
        model: AiSettingsService.to.model,
        messages: [systemMessage, userMessage],
        temperature: 0.7,
        maxTokens: 8000, // DeepSeek 输出上限 8192，留余量
      );

      // 解析结果
      if (completion.choices.isNotEmpty) {
        final contentList = completion.choices.first.message.content;
        if (contentList != null && contentList.isNotEmpty) {
          return contentList.first.text ?? originalText;
        }
      }

      return originalText;
    } catch (e) {
      if (kDebugMode) {
        print('LLM Polishing Error: $e');
      }
      // 在这里显示个简单的提示，或者让调用方处理
      SmartDialog.showToast("润色服务连接失败: $e");
      rethrow;
    }
  }
}
