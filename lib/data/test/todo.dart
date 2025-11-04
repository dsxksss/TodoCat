import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/data/schemas/tag_with_color.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

// 辅助函数：创建带颜色的标签
List<TagWithColor> _createTestTagsWithColors(List<String> tagNames) {
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
  return tagNames.asMap().entries.map((entry) {
    final index = entry.key;
    final tagName = entry.value;
    final color = index < colors.length ? colors[index] : Colors.blueAccent;
    return TagWithColor(name: tagName, color: color);
  }).toList();
}

final todoTestList = [
  Todo()
    ..uuid = const Uuid().v4()
    ..title = "测试待办事项1"
    ..description = "这是一个测试待办事项"
    ..tagsWithColor = _createTestTagsWithColors(["测试", "待办"])
    ..status = TodoStatus.todo
    ..priority = TodoPriority.lowLevel
    ..finishedAt = 0
    ..createdAt = DateTime.now().millisecondsSinceEpoch,
  Todo()
    ..uuid = const Uuid().v4()
    ..title = "测试待办事项2"
    ..description = "这是另一个测试待办事项"
    ..tagsWithColor = _createTestTagsWithColors(["测试", "重要"])
    ..status = TodoStatus.inProgress
    ..priority = TodoPriority.mediumLevel
    ..finishedAt = 0
    ..createdAt = DateTime.now().millisecondsSinceEpoch,
  Todo()
    ..uuid = const Uuid().v4()
    ..title = "测试待办事项3"
    ..description = "这是第三个测试待办事项"
    ..tagsWithColor = _createTestTagsWithColors(["测试", "紧急"])
    ..status = TodoStatus.done
    ..priority = TodoPriority.highLevel
    ..finishedAt = DateTime.now().millisecondsSinceEpoch
    ..createdAt = DateTime.now().millisecondsSinceEpoch,
  Todo()
    ..uuid = const Uuid().v4()
    ..title = "测试待办事项4"
    ..description = "这是第四个测试待办事项"
    ..tagsWithColor = _createTestTagsWithColors(["测试", "普通"])
    ..status = TodoStatus.todo
    ..priority = TodoPriority.lowLevel
    ..finishedAt = 0
    ..createdAt = DateTime.now().millisecondsSinceEpoch,
];
