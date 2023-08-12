import 'package:hive/hive.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
//flutter packages pub run build_runner build 记得使用此命令生成文件
part "task.g.dart";

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  int icon;

  @HiveField(2)
  String color;

  @HiveField(3)
  List<Todo>? todos;

  Task({
    required this.title,
    required this.icon,
    required this.color,
    this.todos,
  });

  Task copyWith({
    String? title,
    int? icon,
    String? color,
    List<Todo>? todos,
  }) =>
      Task(
          title: title ?? this.title,
          icon: icon ?? this.icon,
          color: color ?? this.color,
          todos: todos ?? this.todos);

  factory Task.fromJson(Map<String, dynamic> json) => Task(
      title: json["title"],
      icon: json["icon"],
      color: json["color"],
      todos: json["todos"]);

  Map<String, dynamic> toJson() =>
      {"title": title, "icon": icon, "color": color, "todos": todos};
}
