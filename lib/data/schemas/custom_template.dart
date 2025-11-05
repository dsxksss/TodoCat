import 'dart:convert';
import 'package:TodoCat/data/schemas/task.dart';

/// 自定义任务模板
/// 注意：已迁移到 Drift，不再使用 Isar 注解
class CustomTemplate {
  int? id;
  
  /// 模板名称
  late String name;
  
  /// 模板描述
  String? description;
  
  /// 创建时间
  late int createdAt;
  
  /// 模板任务列表（JSON 序列化字符串）
  late String tasksJson;
  
  /// 模板图标（可选）
  String? icon;
  
  /// 是否为系统预置模板
  bool isSystem = false;
  
  // 辅助方法：从 Task 列表创建模板
  static CustomTemplate fromTasks({
    required String name,
    String? description,
    required List<Task> tasks,
    String? icon,
    bool isSystem = false,
  }) {
    final template = CustomTemplate()
      ..name = name
      ..description = description
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList())
      ..icon = icon
      ..isSystem = isSystem;
    return template;
  }
  
  // 辅助方法：获取 Task 列表
  List<Task> getTasks() {
    try {
      final List<dynamic> jsonList = jsonDecode(tasksJson);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // 辅助方法：更新 Task 列表
  void setTasks(List<Task> tasks) {
    tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
  }
}

