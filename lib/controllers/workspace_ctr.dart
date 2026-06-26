import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:todo_cat/data/schemas/workspace.dart';
import 'package:todo_cat/data/services/repositorys/workspace.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/trash_ctr.dart';
import 'package:todo_cat/data/database/converters.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/services/sync_manager.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/core/utils/l10n.dart';

part 'workspace_ctr.g.dart';

/// 工作空间状态（列表 + 当前工作空间 id）。
@immutable
class WorkspaceState {
  final List<Workspace> workspaces;
  final String currentWorkspaceId;

  const WorkspaceState({
    this.workspaces = const [],
    this.currentWorkspaceId = 'default',
  });

  Workspace? get currentWorkspace =>
      workspaces.firstWhereOrNull((w) => w.uuid == currentWorkspaceId);

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    String? currentWorkspaceId,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      currentWorkspaceId: currentWorkspaceId ?? this.currentWorkspaceId,
    );
  }
}

@Riverpod(keepAlive: true)
class WorkspaceController extends _$WorkspaceController {
  static final _logger = Logger();
  static const _uuid = Uuid();

  WorkspaceRepository? _repository;
  bool _isInitialized = false;

  @override
  WorkspaceState build() {
    _init();
    return const WorkspaceState();
  }

  /// 便捷写入列表（保持引用变化以触发重建）。
  void _setWorkspaces(List<Workspace> list) {
    state = state.copyWith(workspaces: List<Workspace>.from(list));
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      _repository = await WorkspaceRepository.getInstance();
      await loadWorkspaces();

      if (state.workspaces.isEmpty) {
        await createDefaultWorkspace();
      }

      final lastWorkspaceId = await _readLastWorkspaceId();
      if (lastWorkspaceId != null &&
          state.workspaces.any((w) => w.uuid == lastWorkspaceId)) {
        state = state.copyWith(currentWorkspaceId: lastWorkspaceId);
        await ref.read(homeControllerProvider.notifier).refreshData(
              clearBeforeRefresh: true,
              showEmptyPrompt: true,
            );
      } else {
        if (state.workspaces
                .firstWhereOrNull((w) => w.uuid == state.currentWorkspaceId) ==
            null) {
          state =
              state.copyWith(currentWorkspaceId: state.workspaces.first.uuid);
        }
        await ref
            .read(homeControllerProvider.notifier)
            .refreshData(showEmptyPrompt: true);
      }

      _isInitialized = true;
      _checkRemoteUpdate(state.currentWorkspaceId);
    } catch (e) {
      _logger.e('初始化工作空间控制器失败: $e');
    }
  }

  /// 加载所有工作空间
  Future<void> loadWorkspaces() async {
    try {
      _repository ??= await WorkspaceRepository.getInstance();
      final list = await _repository!.readAll();
      _setWorkspaces(list);

      final defaultWorkspace =
          state.workspaces.firstWhereOrNull((w) => w.uuid == 'default');
      if (defaultWorkspace != null && defaultWorkspace.name == 'Default') {
        defaultWorkspace.name = l10n.defaultWorkspace;
        await _repository!.update('default', defaultWorkspace);
        _setWorkspaces(state.workspaces);
      }

      _logger.d('加载了 ${list.length} 个工作空间');
    } catch (e) {
      _logger.e('加载工作空间失败: $e');
    }
  }

  /// 创建默认工作空间
  Future<String> createDefaultWorkspace() async {
    try {
      _repository ??= await WorkspaceRepository.getInstance();
      final uuid = _uuid.v4();
      final workspace = Workspace()
        ..uuid = uuid
        ..name = l10n.defaultWorkspace
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..order = 0
        ..deletedAt = 0;

      await _repository!.write(uuid, workspace);
      _setWorkspaces([...state.workspaces, workspace]);
      _logger.d('创建默认工作空间成功: $uuid');
      return uuid;
    } catch (e) {
      _logger.e('创建默认工作空间失败: $e');
      return 'default';
    }
  }

  /// 创建工作空间，返回 UUID（失败返回 null）。
  Future<String?> createWorkspace(String name, {bool autoSwitch = true}) async {
    try {
      if (name.trim().isEmpty) {
        _logger.w('工作空间名称不能为空');
        return null;
      }

      final workspace = Workspace()
        ..uuid = _uuid.v4()
        ..name = name.trim()
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..order = state.workspaces.length
        ..deletedAt = 0;

      _repository ??= await WorkspaceRepository.getInstance();
      await _repository!.write(workspace.uuid, workspace);
      _setWorkspaces([...state.workspaces, workspace]);
      _logger.d('创建工作空间成功: ${workspace.name}');

      if (autoSwitch) {
        await switchWorkspace(workspace.uuid);
      }
      return workspace.uuid;
    } catch (e) {
      _logger.e('创建工作空间失败: $e');
      return null;
    }
  }

  /// 更新工作空间
  Future<bool> updateWorkspace(String uuid, String newName) async {
    try {
      if (newName.trim().isEmpty) {
        _logger.w('工作空间名称不能为空');
        return false;
      }
      final workspace =
          state.workspaces.firstWhereOrNull((w) => w.uuid == uuid);
      if (workspace == null) {
        _logger.w('工作空间不存在: $uuid');
        return false;
      }
      workspace.name = newName.trim();
      _repository ??= await WorkspaceRepository.getInstance();
      await _repository!.update(uuid, workspace);
      _setWorkspaces(state.workspaces);
      _logger.d('更新工作空间成功: ${workspace.name}');
      return true;
    } catch (e) {
      _logger.e('更新工作空间失败: $e');
      return false;
    }
  }

  /// 删除工作空间（标记删除，移到回收站）
  Future<bool> deleteWorkspace(String uuid) async {
    try {
      if (state.workspaces.length <= 1) {
        _logger.w('不能删除最后一个工作空间');
        return false;
      }

      if (uuid == state.currentWorkspaceId) {
        final nextWorkspace = state.workspaces.firstWhere((w) => w.uuid != uuid);
        await switchWorkspace(nextWorkspace.uuid);
      }

      _repository ??= await WorkspaceRepository.getInstance();
      await _repository!.delete(uuid);
      _setWorkspaces(state.workspaces.where((w) => w.uuid != uuid).toList());
      _logger.d('删除工作空间成功: $uuid');
      return true;
    } catch (e) {
      _logger.e('删除工作空间失败: $e');
      return false;
    }
  }

  /// 恢复已删除的工作空间
  Future<bool> restoreWorkspace(String uuid) async {
    try {
      _repository ??= await WorkspaceRepository.getInstance();
      await _repository!.restore(uuid);
      await loadWorkspaces();
      _logger.d('恢复工作空间成功: $uuid');
      await switchWorkspace(uuid);
      return true;
    } catch (e) {
      _logger.e('恢复工作空间失败: $e');
      return false;
    }
  }

  /// 读取所有已删除的工作空间
  Future<List<Workspace>> readDeleted() async {
    try {
      _repository ??= await WorkspaceRepository.getInstance();
      final rows = await (_repository!.db.select(_repository!.db.workspaces)
            ..where((w) => w.deletedAt.isBiggerThanValue(0))
            ..orderBy([
              (w) =>
                  OrderingTerm(expression: w.deletedAt, mode: OrderingMode.desc)
            ]))
          .get();
      return rows.map((row) => DbConverters.workspaceFromRow(row)).toList();
    } catch (e) {
      _logger.e('读取已删除工作空间失败: $e');
      return [];
    }
  }

  /// 切换工作空间
  Future<void> switchWorkspace(String workspaceId) async {
    try {
      if (state.workspaces.firstWhereOrNull((w) => w.uuid == workspaceId) ==
          null) {
        _logger.w('工作空间不存在: $workspaceId');
        return;
      }

      state = state.copyWith(currentWorkspaceId: workspaceId);
      _saveLastWorkspaceId(workspaceId);
      _logger.d('切换到工作空间: $workspaceId');

      final homeCtrl = ref.read(homeControllerProvider.notifier);
      homeCtrl.setSwitchingWorkspace(true);
      await Future.delayed(const Duration(milliseconds: 300));
      await homeCtrl.refreshData(
          showEmptyPrompt: true, clearBeforeRefresh: true);
      await Future.delayed(const Duration(milliseconds: 50));
      homeCtrl.setSwitchingWorkspace(false);

      _checkRemoteUpdate(workspaceId);
    } catch (e) {
      _logger.e('切换工作空间失败: $e');
      ref.read(homeControllerProvider.notifier).setSwitchingWorkspace(false);
    }
  }

  Future<void> _saveLastWorkspaceId(String uuid) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'last_workspace.json'));
      await file.writeAsString(jsonEncode({'uuid': uuid}));
    } catch (e) {
      _logger.e('保存最后工作空间失败: $e');
    }
  }

  Future<String?> _readLastWorkspaceId() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'last_workspace.json'));
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        return data['uuid'];
      }
    } catch (e) {
      _logger.e('读取最后工作空间失败: $e');
    }
    return null;
  }

  Future<void> _checkRemoteUpdate(String workspaceId) async {
    await Future.delayed(const Duration(seconds: 1));
    final hasUpdate = await SyncManager().checkRemoteUpdate(workspaceId);
    if (hasUpdate) {
      showToast(
        l10n.remoteUpdateAvailable,
        confirmMode: true,
        onYesCallback: () async {
          try {
            await SyncManager().restoreWorkspace(workspaceId);
            await ref.read(homeControllerProvider.notifier).refreshData();
            await ref.read(trashControllerProvider.notifier).refresh();
            showSuccessNotification(l10n.syncCompleted);
          } catch (e) {
            showErrorNotification('${l10n.syncFailed}: $e');
            _logger.e('Sync failed: $e');
          }
        },
      );
    }
  }
}
