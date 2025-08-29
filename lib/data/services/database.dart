import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/schemas/notification_history.dart';
import 'package:logger/logger.dart';

class Database {
  static final _logger = Logger();
  static Database? _instance;
  static Isar? _isar;

  Database._();

  static Future<Database> getInstance() async {
    _instance ??= Database._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    if (_isar != null) {
      _logger.d('Reusing existing Isar instance');
      return;
    }

    _logger.d('Initializing new Isar instance');
    final dir = await getApplicationDocumentsDirectory();
    _logger.d('Database path: ${dir.path}');
    _isar = await Isar.open(
      [TaskSchema, AppConfigSchema, LocalNoticeSchema, NotificationHistorySchema],
      directory: dir.path,
      inspector: true,
    );
  }

  Isar get isar {
    if (_isar == null) {
      throw StateError('Database not initialized');
    }
    return _isar!;
  }

  Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}
