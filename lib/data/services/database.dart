import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:TodoCat/data/schemas/app_config.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/schemas/local_notice.dart';
import 'package:TodoCat/data/schemas/notification_history.dart';
import 'package:TodoCat/data/schemas/custom_template.dart';
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
      [TaskSchema, AppConfigSchema, LocalNoticeSchema, NotificationHistorySchema, CustomTemplateSchema],
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

  /// 清除所有数据（保留数据库结构）
  Future<void> clearAllData() async {
    if (_isar == null) {
      throw StateError('Database not initialized');
    }
    
    _logger.w('Clearing all data from database...');
    
    await _isar!.writeTxn(() async {
      // 清除所有集合的数据
      await _isar!.tasks.clear();
      await _isar!.appConfigs.clear();
      await _isar!.localNotices.clear();
      await _isar!.notificationHistorys.clear();
      await _isar!.customTemplates.clear();
      
      _logger.d('All data cleared successfully');
    });
  }
}
