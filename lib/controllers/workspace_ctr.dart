import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:todo_cat/data/schemas/workspace.dart';
import 'package:todo_cat/data/services/repositorys/workspace.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/database/converters.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/services/sync_manager.dart';
import 'package:todo_cat/widgets/show_toast.dart';

class WorkspaceController extends GetxController {
  static final _logger = Logger();
  static const _uuid = Uuid();

  final RxList<Workspace> workspaces = <Workspace>[].obs;
  final RxString currentWorkspaceId = 'default'.obs;

  WorkspaceRepository? _repository;
  bool _isInitialized = false;

  Workspace? get currentWorkspace {
    return workspaces
        .firstWhereOrNull((w) => w.uuid == currentWorkspaceId.value);
  }

  @override
  void onInit() async {
    super.onInit();
    await _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      _repository = await WorkspaceRepository.getInstance();
      await loadWorkspaces();

      // 如果没有工作空间，创建默认工作空间
      if (workspaces.isEmpty) {
        await createDefaultWorkspace();
      }

      // 尝试恢复上次使用的工作空间
      final lastWorkspaceId = await _readLastWorkspaceId();
      if (lastWorkspaceId != null &&
          workspaces.any((w) => w.uuid == lastWorkspaceId)) {
        currentWorkspaceId.value = lastWorkspaceId;
        // 如果HomeController已注册，刷新数据以显示正确的工作空间任务
        // 如果HomeController已注册，刷新数据以显示正确的工作空间任务
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshData(
            clearBeforeRefresh: true,
            showEmptyPrompt: true, // 恢复工作空间后检查是否为空
          );
        }
      } else {
        // 确保当前工作空间存在
        if (workspaces
                .firstWhereOrNull((w) => w.uuid == currentWorkspaceId.value) ==
            null) {
          currentWorkspaceId.value = workspaces.first.uuid;
        }

        // 默认情况下也检查是否为空
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshData(showEmptyPrompt: true);
        }
      }

      _isInitialized = true;

      // Check for remote updates
      _checkRemoteUpdate(currentWorkspaceId.value);
    } catch (e) {
      _logger.e('初始化工作空间控制器失败: $e');
    }
  }

  /// 加载所有工作空间
  Future<void> loadWorkspaces() async {
    try {
      // 确保 Repository 已初始化（在数据库重置后可能需要重新获取）
      if (_repository == null || !_isInitialized) {
        _repository = await WorkspaceRepository.getInstance();
        _isInitialized = true;
      }
      final list = await _repository!.readAll();
      workspaces.assignAll(list);

      // 更新默认工作空间的本地化名称
      final defaultWorkspace =
          workspaces.firstWhereOrNull((w) => w.uuid == 'default');
      if (defaultWorkspace != null && defaultWorkspace.name == 'Default') {
        defaultWorkspace.name = 'defaultWorkspace'.tr;
        await _repository!.update('default', defaultWorkspace);
        workspaces.refresh();
      }

      _logger.d('加载了 ${list.length} 个工作空间');
    } catch (e) {
      _logger.e('加载工作空间失败: $e');
    }
  }

  /// 创建默认工作空间
  Future<void> createDefaultWorkspace() async {
    try {
      // 确保 Repository 已初始化（在数据库重置后可能需要重新获取）
      if (_repository == null || !_isInitialized) {
        _repository = await WorkspaceRepository.getInstance();
        _isInitialized = true;
      }
      final workspace = Workspace()
        ..uuid = 'default'
        ..name = 'defaultWorkspace'.tr
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..order = 0
        ..deletedAt = 0;

      await _repository!.write('default', workspace);
      workspaces.add(workspace);
      _logger.d('创建默认工作空间成功');
    } catch (e) {
      _logger.e('创建默认工作空间失败: $e');
    }
  }

  /// 创建工作空间
  /// 返回新创建的工作空间UUID，如果创建失败则返回null
  /// [autoSwitch] 是否在创建成功后自动切换到新工作空间，默认为 true
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
        ..order = workspaces.length
        ..deletedAt = 0;

      await _repository!.write(workspace.uuid, workspace);
      workspaces.add(workspace);
      _logger.d('创建工作空间成功: ${workspace.name}');

      // 如果启用自动切换，创建成功后立即切换到新工作空间
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

      final workspace = workspaces.firstWhereOrNull((w) => w.uuid == uuid);
      if (workspace == null) {
        _logger.w('工作空间不存在: $uuid');
        return false;
      }

      workspace.name = newName.trim();
      await _repository!.update(uuid, workspace);
      workspaces.refresh();
      _logger.d('更新工作空间成功: ${workspace.name}');
      return true;
    } catch (e) {
      _logger.e('更新工作空间失败: $e');
      return false;
    }
  }

  /// 删除工作空间（标记为已删除，移到回收站）
  Future<bool> deleteWorkspace(String uuid) async {
    try {
      // 不能删除默认工作空间
      if (uuid == 'default') {
        _logger.w('不能删除默认工作空间');
        return false;
      }

      // 如果删除的是当前工作空间，先切换到默认工作空间（带动画）
      if (uuid == currentWorkspaceId.value) {
        // 先触发切换动画，切换到默认工作空间
        await switchWorkspace('default');
        // 等待动画完成（switchWorkspace 内部已经处理了动画时序）
      }

      // 标记为已删除（移到回收站）
      await _repository!.delete(uuid);
      workspaces.removeWhere((w) => w.uuid == uuid);
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
      await _repository!.restore(uuid);
      await loadWorkspaces();
      _logger.d('恢复工作空间成功: $uuid');

      // 恢复后切换到恢复的工作空间（带动画）
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
      if (workspaces.firstWhereOrNull((w) => w.uuid == workspaceId) == null) {
        _logger.w('工作空间不存在: $workspaceId');
        return;
      }

      currentWorkspaceId.value = workspaceId;
      _saveLastWorkspaceId(workspaceId);
      _logger.d('切换到工作空间: $workspaceId');

      // 刷新任务列表（通过TaskManager），带动画效果
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        // 触发切换动画（淡出旧任务）
        homeCtrl.isSwitchingWorkspace.value = true;
        // 等待完整的淡出动画时间（300ms），确保旧任务完全消失
        await Future.delayed(const Duration(milliseconds: 300));
        // 刷新数据，加载新工作空间的任务（在旧任务淡出后再加载新任务）
        // 使用 clearBeforeRefresh: true 确保在刷新前清空列表，避免显示旧任务
        await homeCtrl.refreshData(
            showEmptyPrompt: true, clearBeforeRefresh: true);
        // 再等待一小段时间，确保数据已更新到UI
        await Future.delayed(const Duration(milliseconds: 50));
        // 触发淡入动画（显示新任务）
        homeCtrl.isSwitchingWorkspace.value = false;

        // Check for remote updates
        _checkRemoteUpdate(workspaceId);
      }
    } catch (e) {
      _logger.e('切换工作空间失败: $e');
      // 确保即使出错也重置动画状态
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.isSwitchingWorkspace.value = false;
      }
    }
  }

  /// 保存最后使用的工作空间ID
  Future<void> _saveLastWorkspaceId(String uuid) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'last_workspace.json'));
      final data = {'uuid': uuid};
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      _logger.e('保存最后工作空间失败: $e');
    }
  }

  /// 读取最后使用的工作空间ID
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
    // Delay slightly to not block UI/Animation
    await Future.delayed(const Duration(seconds: 1));
    final hasUpdate = await SyncManager().checkRemoteUpdate(workspaceId);
    if (hasUpdate) {
      showToast(
        'remoteUpdateAvailable'.tr,
        confirmMode: true,
        onYesCallback: () async {
          try {
            await SyncManager().restoreWorkspace(workspaceId);
            if (Get.isRegistered<HomeController>()) {
              await Get.find<HomeController>().refreshData();
            }
            showSuccessNotification('syncCompleted'.tr);
          } catch (e) {
            showErrorNotification('${'syncFailed'.tr}: $e');
            _logger.e('Sync failed: $e');
          }
        },
      );
    }
  }
}
