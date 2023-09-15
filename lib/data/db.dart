import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/schemas/locale.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';

Future<void> initDB() async {
  // 初始化hive本地数据库
  await Hive.initFlutter();

  // 注册Hive数据模板
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(TodoStatusAdapter());
  Hive.registerAdapter(TodoPriorityAdapter());
  Hive.registerAdapter(LocalNoticeAdapter());
  Hive.registerAdapter(AppConfigAdapter());
  Hive.registerAdapter(LocaleAdapter());
}
