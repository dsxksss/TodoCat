import 'package:isar/isar.dart';

part 'todo.g.dart';

@embedded
class Todo {
  late String uuid;
  late String title;
  List<String> tags = [];
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
