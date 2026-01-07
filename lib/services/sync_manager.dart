import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import '../data/database/database.dart';
import 'webdav_service.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final _logger = Logger();
  WebDavService? _webDavService;

  WebDavConfig? _currentConfig;
  WebDavConfig? get currentConfig => _currentConfig;

  bool get isConfigured => _webDavService != null;

  Future<void> init() async {
    await loadConfig();
  }

  Future<void> saveConfig(WebDavConfig config) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'sync_config.json'));
      await file.writeAsString(jsonEncode(config.toJson()));
      _currentConfig = config;
      _webDavService = WebDavService(config);
      _logger.i('Sync config saved');
    } catch (e) {
      _logger.e('Failed to save sync config: $e');
      rethrow;
    }
  }

  Future<void> loadConfig() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'sync_config.json'));
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        final config = WebDavConfig.fromJson(json);
        _currentConfig = config;
        _webDavService = WebDavService(config);
        _logger.i('Sync config loaded');
      }
    } catch (e) {
      _logger.e('Failed to load sync config: $e');
    }
  }

  Future<void> clearConfig() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'sync_config.json'));
      if (await file.exists()) {
        await file.delete();
      }
      _currentConfig = null;
      _webDavService = null;
      _logger.i('Sync config cleared');
    } catch (e) {
      _logger.e('Failed to clear sync config: $e');
    }
  }

  /// Syncs the current workspace to the cloud
  Future<void> syncWorkspace(String workspaceUuid) async {
    if (_webDavService == null) throw Exception('WebDAV not configured');

    try {
      final db = await AppDatabase.getInstance();

      // 1. Fetch Local Data
      final workspace = await (db.select(db.workspaces)
            ..where((tbl) => tbl.uuid.equals(workspaceUuid)))
          .getSingle();
      final tasks = await (db.select(db.tasks)
            ..where((tbl) => tbl.workspaceId.equals(workspaceUuid)))
          .get();

      // Fetch Todos for these tasks
      final taskUuids = tasks.map((t) => t.uuid).toList();
      final todos = await (db.select(db.todos)
            ..where((tbl) => tbl.taskUuid.isIn(taskUuids)))
          .get();

      // 2. Prepare JSON
      final exportData = {
        'version': 1,
        'syncedAt': DateTime.now().millisecondsSinceEpoch,
        'workspace': {
          'uuid': workspace.uuid,
          'name': workspace.name,
          'order': workspace.order,
          'createdAt': workspace.createdAt,
        },
        'tasks': tasks
            .map((t) => {
                  'uuid': t.uuid,
                  'title': t.title,
                  'workspaceId': t.workspaceId,
                  'order': t.order,
                  'createdAt': t.createdAt,
                  'status': t.status,
                  'description': t.description,
                  'tags': t.tags,
                  'tagsWithColorJsonString': t.tagsWithColorJsonString,
                  'finishedAt': t.finishedAt,
                  'progress': t.progress,
                })
            .toList(),
        'todos': todos
            .map((t) => {
                  'uuid': t.uuid,
                  'taskUuid': t.taskUuid,
                  'title': t.title,
                  'description': t.description,
                  'status': t.status,
                  'priority': t.priority,
                  'createdAt': t.createdAt,
                  'dueDate': t.dueDate,
                  'tags': t.tags,
                  'tagsWithColorJsonString': t.tagsWithColorJsonString,
                  'finishedAt': t.finishedAt,
                  'reminders': t.reminders,
                  'progress': t.progress,
                  'images': t.images,
                })
            .toList(),
      };

      // 3. Upload
      await _webDavService!.ensureDirectory('TodoCat');
      await _webDavService!.uploadFile(
        'TodoCat/workspace_$workspaceUuid.json',
        jsonEncode(exportData),
      );

      // 4. Update Manifest
      await _updateManifest(workspace);

      _logger.i('Workspace $workspaceUuid synced successfully');
    } catch (e) {
      _logger.e('Sync failed: $e');
      rethrow;
    }
  }

  /// Updates the remote manifest.json with the given workspace info
  Future<void> _updateManifest(dynamic workspace) async {
    try {
      final manifestContent =
          await _webDavService!.downloadFile('TodoCat/manifest.json');
      Map<String, dynamic> manifest = {};
      if (manifestContent != null) {
        try {
          manifest = jsonDecode(manifestContent);
        } catch (_) {}
      }

      List<dynamic> workspaces = [];
      if (manifest['workspaces'] is List) {
        workspaces = List.from(manifest['workspaces']);
      }

      // Update or add current workspace
      final index = workspaces.indexWhere((w) => w['uuid'] == workspace.uuid);
      final workspaceInfo = {
        'uuid': workspace.uuid,
        'name': workspace.name,
        'syncedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (index >= 0) {
        workspaces[index] = workspaceInfo;
      } else {
        workspaces.add(workspaceInfo);
      }

      manifest['workspaces'] = workspaces;
      manifest['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _webDavService!.uploadFile(
        'TodoCat/manifest.json',
        jsonEncode(manifest),
      );
    } catch (e) {
      _logger.w('Failed to update manifest: $e');
    }
  }

  /// Downloads workspace data and merges/overwrites local
  Future<void> restoreWorkspace(String workspaceUuid) async {
    if (_webDavService == null) throw Exception('WebDAV not configured');

    try {
      final jsonStr = await _webDavService!
          .downloadFile('TodoCat/workspace_$workspaceUuid.json');
      if (jsonStr == null) {
        throw Exception('Remote workspace file not found');
      }

      final data = jsonDecode(jsonStr);
      final tasksList = (data['tasks'] as List).cast<Map<String, dynamic>>();
      final todosList = (data['todos'] as List).cast<Map<String, dynamic>>();

      // Metadata from file (if available) or assume from manifest
      final workspaceInfo = data['workspace'];

      final db = await AppDatabase.getInstance();

      await db.transaction(() async {
        // 1. Workspaces (Upsert)
        if (workspaceInfo != null) {
          final existing = await (db.select(db.workspaces)
                ..where((tbl) => tbl.uuid.equals(workspaceInfo['uuid'])))
              .getSingleOrNull();

          if (existing != null) {
            // Update existing workspace
            await (db.update(db.workspaces)
                  ..where((tbl) => tbl.uuid.equals(workspaceInfo['uuid'])))
                .write(WorkspacesCompanion(
              name: Value(workspaceInfo['name']),
              order: Value(workspaceInfo['order'] ?? 0),
              createdAt: Value(workspaceInfo['createdAt'] ??
                  DateTime.now().millisecondsSinceEpoch),
              deletedAt: const Value(0),
            ));
          } else {
            // Insert new workspace
            await db.into(db.workspaces).insert(WorkspacesCompanion.insert(
                  uuid: workspaceInfo['uuid'],
                  name: workspaceInfo['name'],
                  order: Value(workspaceInfo['order'] ?? 0),
                  createdAt: workspaceInfo['createdAt'] ??
                      DateTime.now().millisecondsSinceEpoch,
                  deletedAt: const Value(0),
                ));
          }
        }

        // 2. Tasks
        for (var t in tasksList) {
          await db.into(db.tasks).insertOnConflictUpdate(TasksCompanion.insert(
                uuid: t['uuid'],
                title: t['title'],
                workspaceId: Value(t['workspaceId']),
                order: Value(t['order'] ?? 0),
                createdAt: t['createdAt'] ?? 0,
                description: Value(t['description'] ?? ''),
                status: Value(t['status'] ?? 0),
                tags: Value(t['tags'] ?? '[]'),
                tagsWithColorJsonString:
                    Value(t['tagsWithColorJsonString'] ?? '[]'),
                finishedAt: Value(t['finishedAt'] ?? 0),
                progress: Value(t['progress'] ?? 0),
              ));
        }

        // 3. Todos
        for (var t in todosList) {
          await db.into(db.todos).insertOnConflictUpdate(TodosCompanion.insert(
                uuid: t['uuid'],
                taskUuid: t['taskUuid'],
                title: t['title'],
                description: Value(t['description'] ?? ''),
                status: Value(t['status'] ?? 0),
                priority: Value(t['priority'] ?? 0),
                createdAt: t['createdAt'] ?? 0,
                dueDate: Value(t['dueDate'] ?? 0),
                tags: Value(t['tags'] ?? '[]'),
                tagsWithColorJsonString:
                    Value(t['tagsWithColorJsonString'] ?? '[]'),
                finishedAt: Value(t['finishedAt'] ?? 0),
                reminders: Value(t['reminders'] ?? 0),
                progress: Value(t['progress'] ?? 0),
                images: Value(t['images'] ?? '[]'),
              ));
        }
      });

      _logger.i('Workspace restored successfully');
    } catch (e) {
      _logger.e('Restore failed: $e');
      rethrow;
    }
  }

  /// Lists available workspaces on remote
  Future<List<Map<String, dynamic>>> listRemoteWorkspaces() async {
    if (_webDavService == null) return [];
    try {
      final manifestContent =
          await _webDavService!.downloadFile('TodoCat/manifest.json');
      if (manifestContent == null) return [];

      final manifest = jsonDecode(manifestContent);
      if (manifest['workspaces'] is List) {
        return List<Map<String, dynamic>>.from(manifest['workspaces']);
      }
      return [];
    } catch (e) {
      _logger.e('Failed to list remote workspaces: $e');
      return [];
    }
  }
}
