import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

//记得使用此命令生成文件
//flutter packages pub run build_runner build

part "todo.g.dart";
part 'todo.freezed.dart';

@HiveType(typeId: 2)
@unfreezed
class Todo with _$Todo {
  factory Todo({
    @HiveField(0) required int id,
    @HiveField(1) required String title,
    @HiveField(2) required List<String> tags,
    @HiveField(3) required int createdAt,
    @HiveField(4) @Default('') String description,
    @HiveField(5) @Default(TodoPriority.lowLevel) TodoPriority priority,
    @HiveField(6) @Default(0) int finishedAt,
    @HiveField(7) @Default(TodoStatus.todo) TodoStatus status,
    @HiveField(8) @Default(0) int reminders,
    @HiveField(9) @Default(0) int progress,
  }) = _Todo;
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
