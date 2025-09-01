import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 2)
class Todo extends HiveObject {
  @HiveField(0)
  late String uuid;
  
  @HiveField(1)
  late String title;
  
  @HiveField(2)
  List<String> tags = [];
  
  @HiveField(3)
  late int createdAt;
  
  @HiveField(4)
  String description = '';
  
  @HiveField(5)
  TodoPriority priority = TodoPriority.lowLevel;
  
  @HiveField(6)
  int finishedAt = 0; // 实际完成时间
  
  @HiveField(7)
  int dueDate = 0; // 截止日期
  
  @HiveField(8)
  TodoStatus status = TodoStatus.todo;
  
  @HiveField(9)
  int reminders = 0;
  
  @HiveField(10)
  int progress = 0;

  // 默认构造函数
  Todo();

  // JSON序列化
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'tags': tags,
      'createdAt': createdAt,
      'description': description,
      'priority': priority.name,
      'finishedAt': finishedAt,
      'dueDate': dueDate,
      'status': status.name,
      'reminders': reminders,
      'progress': progress,
    };
  }

  // JSON反序列化
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo()
      ..uuid = json['uuid'] as String
      ..title = json['title'] as String
      ..tags = List<String>.from(json['tags'] ?? [])
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
      ..progress = json['progress'] as int? ?? 0;
  }
}

@HiveType(typeId: 3)
enum TodoStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}

@HiveType(typeId: 4)
enum TodoPriority {
  @HiveField(0)
  lowLevel,
  @HiveField(1)
  mediumLevel,
  @HiveField(2)
  highLevel,
}
