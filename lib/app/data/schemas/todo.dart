import 'package:hive/hive.dart';
//flutter packages pub run build_runner build 记得使用此命令生成文件
part "todo.g.dart";

@HiveType(typeId: 2)
class Todo extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  TodoPriority priority;

  @HiveField(5)
  int createdAt;

  @HiveField(6)
  int finishedAt;

  @HiveField(7)
  TodoStatus status;

  @HiveField(8)
  int reminders;

  @HiveField(9)
  int progress;

  Todo({
    required this.id,
    required this.title,
    required this.tags,
    required this.createdAt,
    this.description = '',
    this.priority = TodoPriority.lowLevel,
    this.finishedAt = 0,
    this.status = TodoStatus.todo,
    this.reminders = 0,
    this.progress = 0,
  });
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
  highLevel,

  @HiveField(1)
  mediumLevel,

  @HiveField(2)
  lowLevel,
}
