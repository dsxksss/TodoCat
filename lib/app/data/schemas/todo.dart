import 'package:hive/hive.dart';
//flutter packages pub run build_runner build 记得使用此命令生成文件
part "todo.g.dart";

@HiveType(typeId: 1)
class Todo extends HiveObject {
  @HiveField(0)
  String doThing;

  @HiveField(1)
  int icon;

  @HiveField(2)
  String color;

  @HiveField(3)
  bool done;

  @HiveField(4)
  int createdAt;

  Todo({
    required this.doThing,
    required this.icon,
    required this.color,
    required this.done,
    required this.createdAt,
  });
}
