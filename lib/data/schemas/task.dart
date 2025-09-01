import 'package:hive/hive.dart';
import 'package:todo_cat/data/schemas/todo.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String uuid;

  @HiveField(1)
  int order = 0;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late int createdAt;

  @HiveField(4)
  String description = "";
  
  @HiveField(5)
  int finishedAt = 0;

  @HiveField(6)
  TaskStatus status = TaskStatus.todo;

  @HiveField(7)
  int progress = 0;
  
  @HiveField(8)
  int reminders = 0;

  @HiveField(9)
  List<String> tags = [];
  
  @HiveField(10)
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
      ..tags = List<String>.from(json['tags'] ?? []);
    
    if (json['todos'] != null) {
      task.todos = (json['todos'] as List)
          .map((todoJson) => Todo.fromJson(todoJson))
          .toList();
    }
    
    return task;
  }
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  done,
}
