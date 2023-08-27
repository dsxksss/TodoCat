import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

//记得使用此命令生成hive模板文件
//flutter packages pub run build_runner build

part "task.g.dart";
part 'task.freezed.dart';

@HiveType(typeId: 0)
@unfreezed
class Task with _$Task {
  factory Task({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required List<String> tags,
    @HiveField(3) required List<Todo> todos,
    @HiveField(4) required int createdAt,
    @HiveField(5) @Default("") String description,
    @HiveField(6) @Default(0) int finishedAt,
    @HiveField(7) @Default(TaskStatus.todo) TaskStatus status,
    @HiveField(8) @Default(0) int progress,
    @HiveField(9) @Default(0) int reminders,
  }) = _Task;
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
