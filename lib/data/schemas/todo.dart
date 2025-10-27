import 'package:isar/isar.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'dart:convert';

part 'todo.g.dart';

@embedded
class Todo {
  late String uuid;
  late String title;
  List<String> tags = [];
  String tagsWithColorJsonString = '[]';
  late int createdAt;
  String description = '';
  @enumerated
  TodoPriority priority = TodoPriority.lowLevel;
  int finishedAt = 0; // 实际完成时间
  int dueDate = 0; // 截止日期
  @enumerated
  TodoStatus status = TodoStatus.todo;
  int reminders = 0;
  int progress = 0;
  List<String> images = []; // 图片路径列表

  // 默认构造函数
  Todo();

  // JSON序列化
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'tags': tags,
      'tagsWithColor': tagsWithColorJsonString,
      'createdAt': createdAt,
      'description': description,
      'priority': priority.name,
      'finishedAt': finishedAt,
      'dueDate': dueDate,
      'status': status.name,
      'reminders': reminders,
      'progress': progress,
      'images': images,
    };
  }

  // JSON反序列化
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo()
      ..uuid = json['uuid'] as String
      ..title = json['title'] as String
      ..tags = List<String>.from(json['tags'] ?? [])
      ..tagsWithColorJsonString = json['tagsWithColor'] as String? ?? '[]'
      ..createdAt = json['createdAt'] as int
      ..description = json['description'] as String? ?? ''
      ..priority = TodoPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TodoPriority.lowLevel,
      )
      ..finishedAt = json['finishedAt'] as int? ?? 0
      ..dueDate = json['dueDate'] as int? ?? 0
      ..status = TodoStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TodoStatus.todo,
      )
      ..reminders = json['reminders'] as int? ?? 0
      ..progress = json['progress'] as int? ?? 0
      ..images = List<String>.from(json['images'] ?? []);
  }
  /// 获取带颜色的标签列表
  @ignore
  List<TagWithColor> get tagsWithColor {
    try {
      if (tagsWithColorJsonString.isEmpty || tagsWithColorJsonString == '[]') {
        // 如果没有颜色数据，但有字符串标签，则转换为带默认颜色的标签
        if (tags.isNotEmpty) {
          return tags.map((tag) => TagWithColor.fromString(tag)).toList();
        }
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(tagsWithColorJsonString);
      return jsonList.map((json) => TagWithColor.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // JSON解析失败时，如果有字符串标签，则转换为带默认颜色的标签
      if (tags.isNotEmpty) {
        return tags.map((tag) => TagWithColor.fromString(tag)).toList();
      }
      return [];
    }
  }

  /// 设置带颜色的标签列表
  set tagsWithColor(List<TagWithColor> tags) {
    tagsWithColorJsonString = jsonEncode(tags.map((tag) => tag.toJson()).toList());
    // 同时更新字符串标签列表以保持兼容性
    this.tags = tags.map((tag) => tag.name).toList();
  }
}

enum TodoStatus {
  todo,
  inProgress,
  done,
}

enum TodoPriority {
  lowLevel,
  mediumLevel,
  highLevel,
}
