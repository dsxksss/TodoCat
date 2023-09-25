import 'package:todo_cat/data/schemas/todo.dart';

final test1 = Todo(
  id: "1",
  title: "test1",
  description:
      "我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字",
  tags: ["hello", "你好"],
  status: TodoStatus.inProgress,
  priority: TodoPriority.lowLevel,
  finishedAt:
      DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch,
  createdAt: DateTime.now().millisecondsSinceEpoch,
);

final test2 = Todo(
  id: "2",
  title: "test2",
  description:
      "我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字",
  tags: ["BUG"],
  status: TodoStatus.done,
  priority: TodoPriority.mediumLevel,
  finishedAt:
      DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
  createdAt: DateTime.now().millisecondsSinceEpoch,
);

final test3 = Todo(
  id: "3",
  title: "test3",
  description:
      "我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字",
  tags: [],
  status: TodoStatus.inProgress,
  priority: TodoPriority.highLevel,
  finishedAt:
      DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
  createdAt: DateTime.now().millisecondsSinceEpoch,
);

final test4 = Todo(
  id: "4",
  title: "test4",
  description:
      "我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字我有很多很多字",
  tags: ["hello", "你好", "杂事"],
  status: TodoStatus.done,
  priority: TodoPriority.mediumLevel,
  createdAt: DateTime.now().millisecondsSinceEpoch,
);

List<Todo> todoTestList = [test1, test2, test3, test4];
