import 'package:todo_cat/data/schemas/todo.dart';
import 'package:uuid/uuid.dart';

final todoTestList = [
  Todo()
    ..uuid = const Uuid().v4()
    ..title = "测试待办事项1"
    ..description = "这是一个测试待办事项"
    ..tags = ["测试", "待办"]
    ..status = TodoStatus.todo
    ..priority = TodoPriority.lowLevel
    ..finishedAt = 0
    ..createdAt = DateTime.now().millisecondsSinceEpoch,
  Todo()
    ..uuid = const Uuid().v4()
    ..title = "测试待办事项2"
    ..description = "这是另一个测试待办事项"
    ..tags = ["测试", "重要"]
    ..status = TodoStatus.inProgress
    ..priority = TodoPriority.mediumLevel
    ..finishedAt = 0
    ..createdAt = DateTime.now().millisecondsSinceEpoch,
  Todo()
    ..uuid = const Uuid().v4()
    ..title = "测试待办事项3"
    ..description = "这是第三个测试待办事项"
    ..tags = ["测试", "紧急"]
    ..status = TodoStatus.done
    ..priority = TodoPriority.highLevel
    ..finishedAt = DateTime.now().millisecondsSinceEpoch
    ..createdAt = DateTime.now().millisecondsSinceEpoch,
  Todo()
    ..uuid = const Uuid().v4()
    ..title = "测试待办事项4"
    ..description = "这是第四个测试待办事项"
    ..tags = ["测试", "普通"]
    ..status = TodoStatus.todo
    ..priority = TodoPriority.lowLevel
    ..finishedAt = 0
    ..createdAt = DateTime.now().millisecondsSinceEpoch,
];
