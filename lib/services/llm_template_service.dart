import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/services/ai_settings_service.dart';
import 'package:todo_cat/data/schemas/custom_template.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:uuid/uuid.dart';

/// AI 模板生成深度：越往后步骤越多、描述越详细。
enum TemplateGenerationDepth { concise, standard, detailed, comprehensive }

/// LLM 任务模板生成服务。
///
/// 原 GetX `GetxService` + `Get.find()` 单例已移除，改为普通 Dart 单例。
/// 调用点 `LlmTemplateService.to.generateTemplate(...)` 保持不变。
class LlmTemplateService {
  LlmTemplateService._();

  static final LlmTemplateService _instance = LlmTemplateService._();

  /// 全局单例（替代原 `Get.find()`）。
  static LlmTemplateService get to => _instance;

  final _uuid = const Uuid();

  /// 不同深度对应的输出 token 上限（深度越高，给模型越多空间；DeepSeek 输出上限约 8192）。
  int _maxTokensFor(TemplateGenerationDepth depth) {
    switch (depth) {
      case TemplateGenerationDepth.concise:
        return 2000;
      case TemplateGenerationDepth.standard:
        return 4000;
      case TemplateGenerationDepth.detailed:
        return 6000;
      case TemplateGenerationDepth.comprehensive:
        return 8000;
    }
  }

  /// 不同深度注入到系统提示词里的「数量 + 详细程度」要求。
  String _depthInstruction(TemplateGenerationDepth depth) {
    switch (depth) {
      case TemplateGenerationDepth.concise:
        return 'CONCISE — generate 4-6 high-level steps. Keep each description to a single short sentence.';
      case TemplateGenerationDepth.standard:
        return 'STANDARD — generate 8-12 steps. Each description is 1-2 sentences covering the key how-to.';
      case TemplateGenerationDepth.detailed:
        return 'DETAILED — generate 14-20 steps. Break the goal into clear sub-tasks; each description (2-4 sentences) lists concrete sub-points and what "done" looks like. Order carefully by dependency.';
      case TemplateGenerationDepth.comprehensive:
        return 'COMPREHENSIVE — generate 22-35 fine-grained steps covering every phase end-to-end (preparation, setup, core execution, testing/review, wrap-up). Each description must be thorough and actionable: it MAY include a short markdown bullet list of sub-steps or a checklist, should note prerequisites/dependencies, and should state acceptance criteria. Do not omit setup, edge cases or finishing work.';
    }
  }

  /// 构建系统提示词（已优化：要求步骤具体可执行、按依赖排序、覆盖全生命周期，并按深度伸缩）。
  String _buildSystemPrompt(TemplateGenerationDepth depth) {
    return '''
You are an expert project planner and task-management coach. Given the user's goal, produce a structured Kanban template that someone could realistically follow to achieve it.

OUTPUT: Return ONLY a valid JSON array of exactly 3 task objects — no markdown code fences, no commentary. Schema:
[
  { "title": "待办", "type": "todo", "description": "short summary of the plan", "todos": [ {"title": "actionable step", "description": "the how / key sub-points / acceptance criteria", "priority": "highLevel" | "mediumLevel" | "lowLevel", "tags": ["tag"]} ] },
  { "title": "进行中", "type": "inProgress", "description": "Tasks currently being worked on", "todos": [] },
  { "title": "已完成", "type": "done", "description": "Completed tasks", "todos": [] }
]

QUALITY RULES:
1. Output ONLY the JSON array — no ```json fences, no extra text.
2. Exactly 3 task objects, using the fixed titles/types shown above.
3. Put ALL generated steps into the "待办" task; keep "进行中" and "已完成" todos empty.
4. Every step must be SPECIFIC and ACTIONABLE (start with a verb) and concrete to THIS user's goal — never generic filler like "do research" without specifics.
5. Order steps logically by dependency / chronology (prerequisites first).
6. Give each todo a clear title, a genuinely useful description, a realistic priority (do NOT make everything highLevel — reserve highLevel for critical-path / blocking items), and 1-3 relevant tags.
7. Cover the full lifecycle of the goal: preparation → core execution → review / finishing.
8. Use the SAME LANGUAGE as the user's description for every title, description and tag.

DEPTH: ${_depthInstruction(depth)}
''';
  }

  Future<CustomTemplate?> generateTemplate(
    String userPrompt, {
    TemplateGenerationDepth depth = TemplateGenerationDepth.standard,
  }) async {
    if (userPrompt.trim().isEmpty) {
      return null;
    }

    try {
      final systemPrompt = _buildSystemPrompt(depth);

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(userPrompt),
        ],
        role: OpenAIChatMessageRole.user,
      );

      final completion = await OpenAI.instance.chat.create(
        model: AiSettingsService.to.model,
        messages: [systemMessage, userMessage],
        temperature: 0.7,
        maxTokens: _maxTokensFor(depth),
      );

      if (completion.choices.isNotEmpty) {
        final contentList = completion.choices.first.message.content;
        if (contentList != null && contentList.isNotEmpty) {
          String jsonStr = contentList.first.text ?? "[]";
          // Clean up potential markdown formatting
          int startIndex = jsonStr.indexOf('[');
          int endIndex = jsonStr.lastIndexOf(']');
          if (startIndex != -1 && endIndex != -1) {
            jsonStr = jsonStr.substring(startIndex, endIndex + 1);
          } else {
            // Fallback cleanup if [] not found clearly
            jsonStr =
                jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
          }

          dynamic decodedJson;
          try {
            decodedJson = jsonDecode(jsonStr);
          } catch (e) {
            if (kDebugMode) {
              print("JSON Decode error: $e");
            }
          }

          final List<Task> tasks = [];

          if (decodedJson is List) {
            for (var item in decodedJson) {
              if (item is! Map) {
                continue; // Skip if not a map (e.g. accidental list)
              }

              final task = Task();
              task.uuid = _uuid.v4();
              task.title = item['title'] ?? "Untitled Task";
              task.description = item['description'] ?? "";
              task.createdAt = DateTime.now().millisecondsSinceEpoch;

              // Parse Task Type/Status
              final typeStr = item['type'] as String?;
              if (typeStr == 'inProgress') {
                task.status = TaskStatus.inProgress;
              } else if (typeStr == 'done') {
                task.status = TaskStatus.done;
              } else {
                task.status = TaskStatus.todo;
              }

              task.todos = [];

              if (item['todos'] != null && item['todos'] is List) {
                for (var todoItem in item['todos']) {
                  if (todoItem is! Map) continue; // Skip if not a map

                  final todo = Todo();
                  todo.uuid = _uuid.v4();
                  todo.title = todoItem['title'] ?? "Untitled Todo";
                  todo.description = todoItem['description'] ?? "";
                  todo.createdAt = DateTime.now().millisecondsSinceEpoch;
                  todo.status = TodoStatus.todo;

                  // Parse Priority
                  final pStr = todoItem['priority'] as String?;
                  if (pStr == 'highLevel') {
                    todo.priority = TodoPriority.highLevel;
                  } else if (pStr == 'mediumLevel') {
                    todo.priority = TodoPriority.mediumLevel;
                  } else {
                    todo.priority = TodoPriority.lowLevel;
                  }

                  // Parse Tags
                  if (todoItem['tags'] != null && todoItem['tags'] is List) {
                    todo.tags = List<String>.from(todoItem['tags']);
                  }

                  task.todos!.add(todo);
                }
              }
              tasks.add(task);
            }
          }

          if (tasks.isNotEmpty) {
            return CustomTemplate.fromTasks(
              name: "AI 生成模板",
              description: "基于提示词: $userPrompt",
              tasks: tasks,
              icon: "✨",
            );
          }
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('LLM Template Error: $e');
      }
      SmartDialog.showToast("生成模板失败: $e");
      return null;
    }
  }
}
