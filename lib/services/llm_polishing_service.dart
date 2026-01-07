import 'package:dart_openai/dart_openai.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class LlmPolishingService extends GetxService {
  static LlmPolishingService get to => Get.find();

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
        model: "qwen3-max",
        messages: [systemMessage, userMessage],
        temperature: 0.7,
        maxTokens: 21000, // 限制回复长度，避免过长
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
      print('LLM Polishing Error: $e');
      // 在这里显示个简单的提示，或者让调用方处理
      SmartDialog.showToast("润色服务连接失败: $e");
      rethrow;
    }
  }
}
