import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/schemas/notification_history.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:logger/logger.dart';

class Database {
  static final _logger = Logger();
  static Database? _instance;
  static bool _initialized = false;

  Database._();

  static Future<Database> getInstance() async {
    _instance ??= Database._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    if (_initialized) {
      _logger.d('Reusing existing Hive instance');
      return;
    }

    _logger.d('Initializing new Hive instance');
    final dir = await getApplicationDocumentsDirectory();
    _logger.d('Database path: ${dir.path}');
    
    await Hive.initFlutter(dir.path);
    
    // 注册适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TodoAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TodoStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TodoPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AppConfigAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(LocalNoticeAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(NotificationHistoryAdapter());
    }
    
    _initialized = true;
  }

  Future<Box<T>> getBox<T>(String boxName) async {
    if (!_initialized) {
      await _init();
    }
    return await Hive.openBox<T>(boxName);
  }

  Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
