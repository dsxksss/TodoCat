import 'package:get/get.dart';
import 'package:TodoCat/data/schemas/workspace.dart';
import 'package:TodoCat/data/services/repositorys/workspace.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/data/database/converters.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

class WorkspaceController extends GetxController {
  static final _logger = Logger();
  static const _uuid = Uuid();
  
  final RxList<Workspace> workspaces = <Workspace>[].obs;
  final RxString currentWorkspaceId = 'default'.obs;
  
  WorkspaceRepository? _repository;
  bool _isInitialized = false;

  Workspace? get currentWorkspace {
    return workspaces.firstWhereOrNull((w) => w.uuid == currentWorkspaceId.value);
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
      
      // 确保当前工作空间存在
      if (workspaces.firstWhereOrNull((w) => w.uuid == currentWorkspaceId.value) == null) {
        currentWorkspaceId.value = workspaces.first.uuid;
      }
      
      _isInitialized = true;
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
      final defaultWorkspace = workspaces.firstWhereOrNull((w) => w.uuid == 'default');
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
  Future<String?> createWorkspace(String name) async {
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
      
      // 创建成功后立即切换到新工作空间
      await switchWorkspace(workspace.uuid);
      
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
            ..orderBy([(w) => OrderingTerm(expression: w.deletedAt, mode: OrderingMode.desc)]))
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
        await homeCtrl.refreshData(showEmptyPrompt: true, clearBeforeRefresh: true);
        // 再等待一小段时间，确保数据已更新到UI
        await Future.delayed(const Duration(milliseconds: 50));
        // 触发淡入动画（显示新任务）
        homeCtrl.isSwitchingWorkspace.value = false;
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
}

