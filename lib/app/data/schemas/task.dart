import 'package:hive/hive.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
//flutter packages pub run build_runner build 记得使用此命令生成文件
part "task.g.dart";

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  List<Todo> todos;

  @HiveField(5)
  int createdAt;

  @HiveField(6)
  int finishedAt;

  @HiveField(7)
  TaskStatus status;

  @HiveField(8)
  int progress;

  @HiveField(9)
  int reminders;

  Task({
    required this.id,
    required this.title,
    required this.tags,
    required this.todos,
    required this.createdAt,
    this.description = '',
    this.finishedAt = 0,
    this.status = TaskStatus.todo,
    this.progress = 0,
    this.reminders = 0,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    List<String>? tags,
    List<Todo>? todos,
    int? createdAt,
    int? finishedAt,
    TaskStatus? status,
    int? progress,
    int? reminders,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        todos: todos ?? this.todos,
        createdAt: createdAt ?? this.createdAt,
        finishedAt: finishedAt ?? this.finishedAt,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        reminders: reminders ?? this.reminders,
      );

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        tags: json["tags"],
        todos: json["todos"],
        createdAt: json["createdAt"],
        finishedAt: json["finishedAt"],
        status: json["status"],
        progress: json["progress"],
        reminders: json["reminders"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "tags": tags,
        "todos": todos,
        "createdAt": createdAt,
        "finishedAt": finishedAt,
        "status": status,
        "progress": progress,
        "reminders": reminders,
      };
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
