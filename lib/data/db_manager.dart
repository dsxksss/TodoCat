import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/schemas/locale.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();

  factory DatabaseManager() {
    return _instance;
  }

  DatabaseManager._internal();

  Future<void> initialize() async {
    await Hive.initFlutter();
    _registerAdapters();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskStatusAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TodoAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TodoStatusAdapter());
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TodoPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(LocalNoticeAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(AppConfigAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(LocaleAdapter());
  }

  Future<void> closeDatabase() async {
    await Hive.close();
  }
}
