import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart' hide Value;
import 'package:todo_cat/widgets/import_conflict_dialog.dart';
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

  Map<String, int> _lastSyncTimes = {};

  Future<void> init() async {
    await loadConfig();
    await loadSyncStatus();
  }

  Future<void> loadSyncStatus() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'sync_status.json'));
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        if (json['lastSyncTimes'] != null) {
          _lastSyncTimes = Map<String, int>.from(json['lastSyncTimes']);
        }
      }
    } catch (e) {
      _logger.e('Failed to load sync status: $e');
    }
  }

  Future<void> saveSyncStatus() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'sync_status.json'));
      final data = {
        'lastSyncTimes': _lastSyncTimes,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      _logger.e('Failed to save sync status: $e');
    }
  }

  Future<void> clearSyncStatus() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'sync_status.json'));
      if (await file.exists()) {
        await file.delete();
      }
      _lastSyncTimes.clear();
      _logger.i('Sync status cleared');
    } catch (e) {
      _logger.e('Failed to clear sync status: $e');
    }
  }

  int? getLastSyncTime(String workspaceUuid) {
    return _lastSyncTimes[workspaceUuid];
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
                  'deletedAt': t.deletedAt, // 同步回收站数据
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
                  'deletedAt': t.deletedAt, // 同步回收站数据
                })
            .toList(),
      };

      // 3. Upload Images & Backup
      await _webDavService!.ensureDirectory('TodoCat');

      // Handle Images Syncing
      final todosWithRelativePaths = await _syncImages(todos, workspaceUuid);
      // Update export data with processed todos (relative paths)
      exportData['todos'] = todosWithRelativePaths
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
                'deletedAt': t.deletedAt, // 同步回收站数据
              })
          .toList();

      await _webDavService!.uploadFile(
        'TodoCat/workspace_$workspaceUuid.json',
        jsonEncode(exportData),
      );

      // 4. Update Manifest and Local Status
      final now = DateTime.now().millisecondsSinceEpoch;
      await _updateManifest(workspace, now);

      _lastSyncTimes[workspaceUuid] = now;
      await saveSyncStatus();

      _logger.i('Workspace $workspaceUuid synced successfully');
    } catch (e) {
      _logger.e('Sync failed: $e');
      rethrow;
    }
  }

  /// Updates the remote manifest.json with the given workspace info
  Future<void> _updateManifest(dynamic workspace, int syncedAt) async {
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
        'syncedAt': syncedAt,
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

      // Restore Images
      final todosListProcessed = await _restoreImages(todosList, workspaceUuid);

      final db = await AppDatabase.getInstance();

      // Check for conflicts before transaction
      final existingTasks = await (db.select(db.tasks)
            ..where((tbl) => tbl.workspaceId.equals(workspaceUuid)))
          .get();

      final existingTaskMap = <String, Task>{}; // Title -> Task
      for (final task in existingTasks) {
        existingTaskMap[task.title.toLowerCase()] = task;
      }

      final conflictTasks = <String>[];
      for (var t in tasksList) {
        final title = t['title']?.toString().toLowerCase() ?? '';
        final uuid = t['uuid'];

        if (title.isNotEmpty && existingTaskMap.containsKey(title)) {
          final existingTask = existingTaskMap[title]!;
          // If UUIDs are different, it's a conflict
          if (existingTask.uuid != uuid) {
            conflictTasks.add(t['title']);
          }
        }
      }

      ConflictAction conflictAction = ConflictAction.skip;
      if (conflictTasks.isNotEmpty) {
        conflictAction = await _showConflictDialog(conflictTasks);
        if (conflictAction == ConflictAction.cancel) {
          throw Exception('User cancelled restore');
        }
      }

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
          final title = t['title']?.toString().toLowerCase() ?? '';
          final uuid = t['uuid'];
          final isConflict = title.isNotEmpty &&
              existingTaskMap.containsKey(title) &&
              existingTaskMap[title]!.uuid != uuid;

          if (isConflict) {
            if (conflictAction == ConflictAction.skip) {
              continue;
            } else if (conflictAction == ConflictAction.replace) {
              // Delete existing task
              final existingTask = existingTaskMap[title]!;
              await (db.delete(db.tasks)
                    ..where((tbl) => tbl.uuid.equals(existingTask.uuid)))
                  .go();
            }
          }

          // Manual Upsert for Task to avoid UNIQUE constraint failure on non-PK
          final existingTask = await (db.select(db.tasks)
                ..where((tbl) => tbl.uuid.equals(t['uuid'])))
              .getSingleOrNull();

          if (existingTask != null) {
            await (db.update(db.tasks)
                  ..where((tbl) => tbl.uuid.equals(t['uuid'])))
                .write(TasksCompanion(
              title: Value(t['title']),
              workspaceId: Value(t['workspaceId']),
              order: Value(t['order'] ?? 0),
              createdAt: Value(t['createdAt'] ?? 0),
              description: Value(t['description'] ?? ''),
              status: Value(t['status'] ?? 0),
              tags: Value(t['tags'] ?? '[]'),
              tagsWithColorJsonString:
                  Value(t['tagsWithColorJsonString'] ?? '[]'),
              finishedAt: Value(t['finishedAt'] ?? 0),
              progress: Value(t['progress'] ?? 0),
              deletedAt: Value(t['deletedAt'] ?? 0), // 恢复回收站数据
            ));
          } else {
            await db.into(db.tasks).insert(TasksCompanion.insert(
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
                  deletedAt: Value(t['deletedAt'] ?? 0), // 恢复回收站数据
                ));
          }
        }

        // 3. Todos
        for (var t in todosListProcessed) {
          // Manual Upsert for Todo
          final existingTodo = await (db.select(db.todos)
                ..where((tbl) => tbl.uuid.equals(t['uuid'])))
              .getSingleOrNull();

          if (existingTodo != null) {
            await (db.update(db.todos)
                  ..where((tbl) => tbl.uuid.equals(t['uuid'])))
                .write(TodosCompanion(
              taskUuid: Value(t['taskUuid']),
              title: Value(t['title']),
              description: Value(t['description'] ?? ''),
              status: Value(t['status'] ?? 0),
              priority: Value(t['priority'] ?? 0),
              createdAt: Value(t['createdAt'] ?? 0),
              dueDate: Value(t['dueDate'] ?? 0),
              tags: Value(t['tags'] ?? '[]'),
              tagsWithColorJsonString:
                  Value(t['tagsWithColorJsonString'] ?? '[]'),
              finishedAt: Value(t['finishedAt'] ?? 0),
              reminders: Value(t['reminders'] ?? 0),
              progress: Value(t['progress'] ?? 0),
              images: Value(t['images'] ?? '[]'),
              deletedAt: Value(t['deletedAt'] ?? 0), // 恢复回收站数据
            ));
          } else {
            await db.into(db.todos).insert(TodosCompanion.insert(
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
                  deletedAt: Value(t['deletedAt'] ?? 0), // 恢复回收站数据
                ));
          }
        }
      });

      // Update Local Status
      // Update Local Status
      final syncedAt =
          data['syncedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch;
      _lastSyncTimes[workspaceUuid] = syncedAt;
      await saveSyncStatus();

      _logger.i('Workspace restored successfully');
    } catch (e) {
      _logger.e('Restore failed: $e');
      rethrow;
    }
  }

  /// 显示冲突处理对话框
  Future<ConflictAction> _showConflictDialog(List<String> conflictTasks) async {
    ConflictAction? selectedAction;

    await SmartDialog.show(
      useSystem: false,
      debounce: true,
      keepSingle: true,
      tag: 'import_conflict_dialog',
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 200),
      alignment: Alignment.center,
      builder: (_) => ImportConflictDialog(
        conflictTasks: conflictTasks,
        onSkip: () {
          selectedAction = ConflictAction.skip;
          SmartDialog.dismiss(tag: 'import_conflict_dialog');
        },
        onReplace: () {
          selectedAction = ConflictAction.replace;
          SmartDialog.dismiss(tag: 'import_conflict_dialog');
        },
        onCancel: () {
          selectedAction = ConflictAction.cancel;
          SmartDialog.dismiss(tag: 'import_conflict_dialog');
        },
      ),
      clickMaskDismiss: false,
      animationBuilder: (controller, child, _) {
        return child
            .animate(controller: controller)
            .fade(duration: controller.duration)
            .scaleXY(
              begin: 0.95,
              duration: controller.duration,
              curve: Curves.easeOut,
            );
      },
    );

    return selectedAction ?? ConflictAction.cancel;
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

  /// Checks if there is a newer version of the workspace on the remote
  Future<bool> checkRemoteUpdate(String workspaceUuid) async {
    if (_webDavService == null) return false;
    try {
      final manifestContent =
          await _webDavService!.downloadFile('TodoCat/manifest.json');
      if (manifestContent == null) return false;

      final manifest = jsonDecode(manifestContent);
      final workspaces = manifest['workspaces'] as List?;
      if (workspaces == null) return false;

      final remoteWorkspace =
          workspaces.firstWhereOrNull((w) => w['uuid'] == workspaceUuid);
      if (remoteWorkspace == null) return false;

      final remoteTime = remoteWorkspace['syncedAt'] as int?;
      if (remoteTime == null) return false;

      final localTime = _lastSyncTimes[workspaceUuid] ?? 0;

      // Ensure that we only prompt if the remote is genuinely newer
      // A small buffer might be useful, but strict comparison is safer for now
      if (remoteTime > localTime) {
        _logger.i(
            'Remote update detected for $workspaceUuid: remote($remoteTime) > local($localTime)');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to check remote update: $e');
      return false;
    }
  }

  /// Process and upload images, return todos with relative paths
  Future<List<Todo>> _syncImages(List<Todo> todos, String workspaceUuid) async {
    final List<Todo> processedTodos = [];
    const relativePathPrefix = 'webdav_asset://';

    // Ensure remote assets directory exists
    await _webDavService!.ensureDirectory('TodoCat/assets');
    await _webDavService!.ensureDirectory('TodoCat/assets/$workspaceUuid');

    for (var todo in todos) {
      String description = todo.description;
      final imageRegex = RegExp(r'!\[.*?\]\((.*?)\)');
      final matches = imageRegex.allMatches(description);

      for (var match in matches) {
        final pathStr = match.group(1);
        if (pathStr != null &&
            (pathStr.startsWith('file:///') || File(pathStr).existsSync())) {
          // Extract file path
          String localPath = pathStr.replaceFirst('file:///', '');
          // Handle Windows path if needed, usually regex matches the raw string
          if (Platform.isWindows && localPath.contains(':')) {
            // Keep it as is if it looks like C:/...
          } else if (pathStr.startsWith('file://')) {
            // unix style file:///path
            // localPath is /path
          }

          // Basic clean up for Windows
          // If regex matched `file:///C:/Users/...`, localPath is `C:/Users/...`

          final file = File(localPath);
          if (await file.exists()) {
            final fileName = p.basename(localPath);
            // Upload
            try {
              final bytes = await file.readAsBytes();
              await _webDavService!.uploadFileBytes(
                  'TodoCat/assets/$workspaceUuid/$fileName', bytes);

              // Replace in description
              final relativePath = '$relativePathPrefix$fileName';
              description = description.replaceFirst(pathStr, relativePath);
            } catch (e) {
              _logger.e('Failed to upload image $localPath: $e');
            }
          }
        }
      }
      processedTodos.add(todo.copyWith(description: description));
    }
    return processedTodos;
  }

  /// Download and restore images, return todosList with local paths
  Future<List<Map<String, dynamic>>> _restoreImages(
      List<Map<String, dynamic>> todosList, String workspaceUuid) async {
    final appDir = await getApplicationDocumentsDirectory();
    final localAssetsDir = Directory(p.join(
        appDir.path, 'pasted_images')); // Consistent with ImagePasteService
    if (!await localAssetsDir.exists()) {
      await localAssetsDir.create(recursive: true);
    }

    const relativePathPrefix = 'webdav_asset://';
    final List<Map<String, dynamic>> processedList = [];

    for (var todoMap in todosList) {
      String description = todoMap['description'] ?? '';

      // Simple string check to avoid regex if not needed
      if (description.contains(relativePathPrefix)) {
        final imageRegex = RegExp(r'!\[.*?\]\((webdav_asset:\/\/.*?)\)');
        final matches = imageRegex.allMatches(description);

        for (var match in matches) {
          final relativeUrl = match.group(1);
          if (relativeUrl != null) {
            final fileName = relativeUrl.replaceFirst(relativePathPrefix, '');

            // Download
            try {
              final bytes = await _webDavService!
                  .downloadFileBytes('TodoCat/assets/$workspaceUuid/$fileName');
              if (bytes != null) {
                final localFile = File(p.join(localAssetsDir.path, fileName));
                await localFile.writeAsBytes(bytes);

                // Replace with local path
                // Windows requires file:///C:/...
                // Others file:///
                final localUri = Uri.file(localFile.path).toString();
                description = description.replaceFirst(relativeUrl, localUri);
              }
            } catch (e) {
              _logger.e('Failed to restore image $fileName: $e');
            }
          }
        }

        final newTodoMap = Map<String, dynamic>.from(todoMap);
        newTodoMap['description'] = description;
        processedList.add(newTodoMap);
      } else {
        processedList.add(todoMap);
      }
    }
    return processedList;
  }
}
