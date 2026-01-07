import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/data/schemas/custom_template.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:uuid/uuid.dart';

class LlmTemplateService extends GetxService {
  static LlmTemplateService get to => Get.find();
  final _uuid = const Uuid();

  Future<CustomTemplate?> generateTemplate(String userPrompt) async {
    if (userPrompt.trim().isEmpty) {
      return null;
    }

    try {
      const systemPrompt = """
You are a professional task management expert. Your goal is to generate a structured Kanban task template based on the user's description.
Output Format:
You MUST return ONLY a valid JSON string representing a list of Tasks.
Structure:
[
  {
    "title": "待办", // Fixed title for Kanban "To Do" column
    "type": "todo", // MUST be "todo"
    "description": "Planned tasks",
    "todos": [ 
      {
        "title": "Step 1",
        "description": "Details...",
        "priority": "mediumLevel",
        "tags": ["Tag1"]
      } 
    ]
  },
  {
    "title": "进行中", // Fixed title for Kanban "In Progress" column
    "type": "inProgress", // MUST be "inProgress"
    "description": "Tasks currently being worked on",
    "todos": []
  },
  {
    "title": "已完成", // Fixed title for Kanban "Done" column
    "type": "done", // MUST be "done"
    "description": "Completed tasks",
    "todos": []
  }
]
Rules:
1. Return ONLY the JSON. No markdown backticks (```json ... ```), no explanatory text.
2. You MUST generate exactly 3 Tasks.
3. Analyze the user's request. Break it down into AT LEAST 5-10 actionable steps (todos) for a complete plan.
4. Place ALL these steps into the "待办" (To Do) list todos array.
5. Do NOT return an empty "todos" array for the "待办" task. You must generate content.
6. Use the user's language for Todo titles and descriptions.
""";

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
        model: "qwen3-max",
        messages: [systemMessage, userMessage],
        temperature: 0.7,
        maxTokens: 4000,
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
            print("JSON Decode error: $e");
          }

          final List<Task> tasks = [];

          if (decodedJson is List) {
            for (var item in decodedJson) {
              if (item is! Map)
                continue; // Skip if not a map (e.g. accidental list)

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
      print('LLM Template Error: $e');
      SmartDialog.showToast("生成模板失败: $e");
      return null;
    }
  }
}
