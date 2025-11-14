import 'package:TodoCat/data/schemas/workspace.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:TodoCat/data/database/converters.dart';
import 'package:TodoCat/data/database/database.dart' as drift_db;
import 'package:drift/drift.dart';

class WorkspaceRepository {
  static WorkspaceRepository? _instance;
  drift_db.AppDatabase? _db;
  bool _isInitialized = false;

  WorkspaceRepository._();

  static Future<WorkspaceRepository> getInstance() async {
    _instance ??= WorkspaceRepository._();
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
      throw StateError('WorkspaceRepository not initialized');
    }
    return _db!;
  }

  /// 读取所有未删除的工作空间
  Future<List<Workspace>> readAll() async {
    final rows = await (db.select(db.workspaces)
          ..where((w) => w.deletedAt.equals(0))
          ..orderBy([(w) => OrderingTerm(expression: w.order)]))
        .get();
    return rows.map((row) => DbConverters.workspaceFromRow(row)).toList();
  }

  /// 读取单个工作空间（包括已删除的）
  Future<Workspace?> readOne(String uuid) async {
    final row = await (db.select(db.workspaces)
          ..where((w) => w.uuid.equals(uuid)))
        .getSingleOrNull();
    if (row == null) return null;
    return DbConverters.workspaceFromRow(row);
  }

  /// 写入工作空间（如果不存在则创建，存在则更新）
  Future<void> write(String uuid, Workspace workspace) async {
    await db.transaction(() async {
      final existing = await (db.select(db.workspaces)
            ..where((w) => w.uuid.equals(uuid)))
          .getSingleOrNull();

      if (existing != null) {
        workspace.id = existing.id;
        workspace.order = existing.order;
      } else {
        // 获取当前工作空间数量作为新工作空间的 order
        final countQuery = db.selectOnly(db.workspaces)..addColumns([db.workspaces.id.count()]);
        final count = await countQuery.getSingle();
        workspace.order = count.read(db.workspaces.id.count()) ?? 0;
      }

      final companion = DbConverters.workspaceToCompanion(workspace, isUpdate: existing != null);
      if (existing != null) {
        await (db.update(db.workspaces)..where((w) => w.id.equals(existing.id))).write(companion);
      } else {
        final insertedId = await db.into(db.workspaces).insert(companion);
        workspace.id = insertedId;
      }
    });
  }

  /// 更新工作空间
  Future<void> update(String uuid, Workspace workspace) async {
    await write(uuid, workspace);
  }

  /// 标记工作空间为已删除（移到回收站）
  Future<void> delete(String uuid) async {
    await db.transaction(() async {
      final workspaceRow = await (db.select(db.workspaces)
            ..where((w) => w.uuid.equals(uuid)))
          .getSingleOrNull();

      if (workspaceRow != null) {
        final deletedAt = DateTime.now().millisecondsSinceEpoch;
        await (db.update(db.workspaces)..where((w) => w.id.equals(workspaceRow.id)))
          .write(drift_db.WorkspacesCompanion(deletedAt: Value(deletedAt)));
      }
    });
  }

  /// 恢复已删除的工作空间
  Future<void> restore(String uuid) async {
    await db.transaction(() async {
      await (db.update(db.workspaces)..where((w) => w.uuid.equals(uuid)))
        .write(const drift_db.WorkspacesCompanion(deletedAt: Value(0)));
    });
  }

  /// 永久删除工作空间
  Future<void> permanentDelete(String uuid) async {
    await db.transaction(() async {
      final workspaceRow = await (db.select(db.workspaces)
            ..where((w) => w.uuid.equals(uuid)))
          .getSingleOrNull();
      if (workspaceRow != null) {
        await (db.delete(db.workspaces)..where((w) => w.id.equals(workspaceRow.id))).go();
      }
    });
  }

  /// 检查工作空间是否存在（包括已删除的）
  Future<bool> has(String uuid) async {
    final row = await (db.select(db.workspaces)
          ..where((w) => w.uuid.equals(uuid)))
        .getSingleOrNull();
    return row != null;
  }
}

