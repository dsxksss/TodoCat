import 'package:isar/isar.dart';
import 'package:TodoCat/data/schemas/custom_template.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:logger/logger.dart';

class CustomTemplateRepository {
  static final _logger = Logger();
  static CustomTemplateRepository? _instance;
  Isar? _isar;
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
    final db = await Database.getInstance();
    _isar = db.isar;
    _isInitialized = true;
  }

  Isar get isar {
    if (_isar == null) {
      throw StateError('CustomTemplateRepository not initialized');
    }
    return _isar!;
  }

  /// 保存自定义模板
  Future<void> save(CustomTemplate template) async {
    await isar.writeTxn(() async {
      await isar.customTemplates.put(template);
    });
    _logger.d('Custom template saved: ${template.name}');
  }

  /// 读取所有自定义模板
  Future<List<CustomTemplate>> readAll() async {
    return await isar.customTemplates
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// 根据ID读取模板
  Future<CustomTemplate?> read(Id id) async {
    return await isar.customTemplates.get(id);
  }

  /// 根据名称读取模板
  Future<CustomTemplate?> readByName(String name) async {
    return await isar.customTemplates
        .filter()
        .nameEqualTo(name)
        .findFirst();
  }

  /// 删除模板
  Future<bool> delete(Id id) async {
    bool success = false;
    await isar.writeTxn(() async {
      success = await isar.customTemplates.delete(id);
    });
    _logger.d('Custom template deleted: $id, success: $success');
    return success;
  }

  /// 更新模板
  Future<void> update(CustomTemplate template) async {
    await isar.writeTxn(() async {
      await isar.customTemplates.put(template);
    });
    _logger.d('Custom template updated: ${template.name}');
  }

  /// 检查模板名称是否已存在
  Future<bool> exists(String name) async {
    final count = await isar.customTemplates
        .filter()
        .nameEqualTo(name)
        .count();
    return count > 0;
  }

  /// 清空所有自定义模板
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.customTemplates.clear();
    });
    _logger.d('All custom templates cleared');
  }
}

