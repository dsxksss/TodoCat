import 'package:isar/isar.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'dart:convert';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  int order = 0;

  late String title;

  @Index()
  late int createdAt;

  String description = "";
  int finishedAt = 0;

  @enumerated
  TaskStatus status = TaskStatus.todo;

  int progress = 0;
  int reminders = 0;

  List<String> tags = [];
  String tagsWithColorJsonString = '[]';
  @ignore
  List<Todo>? _todos;

  // 默认构造函数
  Task();

  List<Todo>? get todos => _todos;
  set todos(List<Todo>? value) {
    _todos = value != null ? List<Todo>.from(value) : null;
  }

  // JSON序列化
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'order': order,
      'title': title,
      'createdAt': createdAt,
      'description': description,
      'finishedAt': finishedAt,
      'status': status.name,
      'progress': progress,
      'reminders': reminders,
      'tags': tags,
      'tagsWithColor': tagsWithColorJsonString,
      'todos': todos?.map((todo) => todo.toJson()).toList(),
    };
  }

  // JSON反序列化
  factory Task.fromJson(Map<String, dynamic> json) {
    final task = Task()
      ..uuid = json['uuid'] as String
      ..order = json['order'] as int
      ..title = json['title'] as String
      ..createdAt = json['createdAt'] as int
      ..description = json['description'] as String? ?? ''
      ..finishedAt = json['finishedAt'] as int? ?? 0
      ..status = TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      )
      ..progress = json['progress'] as int? ?? 0
      ..reminders = json['reminders'] as int? ?? 0
      ..tags = List<String>.from(json['tags'] ?? [])
      ..tagsWithColorJsonString = json['tagsWithColor'] as String? ?? '[]';
    
    if (json['todos'] != null) {
      task.todos = (json['todos'] as List)
          .map((todoJson) => Todo.fromJson(todoJson))
          .toList();
    }
    
    return task;
  }

  /// 获取带颜色的标签列表
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

enum TaskStatus {
  todo,
  inProgress,
  done,
}
