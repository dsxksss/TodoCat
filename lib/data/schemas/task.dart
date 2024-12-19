import 'package:isar/isar.dart';
import 'package:todo_cat/data/schemas/todo.dart';

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
  @ignore
  List<Todo>? _todos;

  List<Todo>? get todos => _todos;
  set todos(List<Todo>? value) {
    _todos = value != null ? List<Todo>.from(value) : null;
  }
}

enum TaskStatus {
  todo,
  inProgress,
  done,
}
