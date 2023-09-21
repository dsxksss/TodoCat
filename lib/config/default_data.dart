import 'package:todo_cat/data/schemas/task.dart';
import 'package:uuid/uuid.dart';

final Task defaultTask1 = Task(
  id: const Uuid().v4(),
  title: "todo",
  createdAt: DateTime.now().millisecondsSinceEpoch,
  tags: ["默认", "自带"],
  todos: [],
);
final Task defaultTask2 = Task(
  id: const Uuid().v4(),
  title: "inProgress",
  createdAt: DateTime.now().millisecondsSinceEpoch + 1,
  tags: ["默认", "自带"],
  todos: [],
);
final Task defaultTask3 = Task(
  id: const Uuid().v4(),
  title: "done",
  createdAt: DateTime.now().millisecondsSinceEpoch + 2,
  tags: ["默认", "自带"],
  todos: [],
);
final Task defaultTask4 = Task(
  id: const Uuid().v4(),
  title: "another",
  createdAt: DateTime.now().millisecondsSinceEpoch + 3,
  tags: ["默认", "自带"],
  todos: [],
);

final defaultTasks = [defaultTask1, defaultTask2, defaultTask3, defaultTask4];
