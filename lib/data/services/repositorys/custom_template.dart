import 'package:TodoCat/data/schemas/custom_template.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:TodoCat/data/database/database.dart' as drift_db;
import 'package:TodoCat/data/database/converters.dart';
import 'package:logger/logger.dart';
import 'package:drift/drift.dart';

class CustomTemplateRepository {
  static final _logger = Logger();
  static CustomTemplateRepository? _instance;
  drift_db.AppDatabase? _db;
  bool _isInitialized = false;

  CustomTemplateRepository._();

  static Future<CustomTemplateRepository> getInstance() async {
    _instance ??= CustomTemplateRepository._();
    if (!_instance!._isInitialized) {
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    final dbService = await Database.getInstance();
    _db = dbService.appDatabase;
    _isInitialized = true;
  }

  drift_db.AppDatabase get db {
    if (_db == null) {
      throw StateError('CustomTemplateRepository not initialized');
    }
    return _db!;
  }

  /// 保存自定义模板
  Future<void> save(CustomTemplate template) async {
    await db.transaction(() async {
      final companion = DbConverters.customTemplateToCompanion(template, isUpdate: template.id != null);
      
      if (template.id != null) {
        // 更新
        await (db.update(db.customTemplates)..where((t) => t.id.equals(template.id!)))
            .write(companion);
      } else {
        // 插入
        final id = await db.into(db.customTemplates).insert(companion);
        template.id = id;
      }
    });
    _logger.d('Custom template saved: ${template.name}');
  }

  /// 读取所有自定义模板
  Future<List<CustomTemplate>> readAll() async {
    final rows = await (db.select(db.customTemplates)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map((row) => DbConverters.customTemplateFromRow(row)).toList();
  }

  /// 根据ID读取模板
  Future<CustomTemplate?> read(int id) async {
    final row = await (db.select(db.customTemplates)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? DbConverters.customTemplateFromRow(row) : null;
  }

  /// 根据名称读取模板
  Future<CustomTemplate?> readByName(String name) async {
    final row = await (db.select(db.customTemplates)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    return row != null ? DbConverters.customTemplateFromRow(row) : null;
  }

  /// 删除模板
  Future<bool> delete(int id) async {
    bool success = false;
    await db.transaction(() async {
      final deleted = await (db.delete(db.customTemplates)..where((t) => t.id.equals(id))).go();
      success = deleted > 0;
    });
    _logger.d('Custom template deleted: $id, success: $success');
    return success;
  }

  /// 更新模板
  Future<void> update(CustomTemplate template) async {
    await save(template);
    _logger.d('Custom template updated: ${template.name}');
  }

  /// 检查模板名称是否已存在
  Future<bool> exists(String name) async {
    final rows = await (db.select(db.customTemplates)
          ..where((t) => t.name.equals(name)))
        .get();
    return rows.isNotEmpty;
  }

  /// 清空所有自定义模板
  Future<void> clear() async {
    await db.delete(db.customTemplates).go();
    _logger.d('All custom templates cleared');
  }
}
