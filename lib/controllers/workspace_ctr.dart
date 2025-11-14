import 'package:get/get.dart';
import 'package:TodoCat/data/schemas/workspace.dart';
import 'package:TodoCat/data/services/repositorys/workspace.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
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
      final list = await _repository!.readAll();
      workspaces.assignAll(list);
      _logger.d('加载了 ${list.length} 个工作空间');
    } catch (e) {
      _logger.e('加载工作空间失败: $e');
    }
  }

  /// 创建默认工作空间
  Future<void> createDefaultWorkspace() async {
    try {
      final workspace = Workspace()
        ..uuid = 'default'
        ..name = 'Default'
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
  Future<bool> createWorkspace(String name) async {
    try {
      if (name.trim().isEmpty) {
        _logger.w('工作空间名称不能为空');
        return false;
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
      return true;
    } catch (e) {
      _logger.e('创建工作空间失败: $e');
      return false;
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

  /// 删除工作空间
  Future<bool> deleteWorkspace(String uuid) async {
    try {
      // 不能删除默认工作空间
      if (uuid == 'default') {
        _logger.w('不能删除默认工作空间');
        return false;
      }

      // 如果删除的是当前工作空间，切换到默认工作空间
      if (uuid == currentWorkspaceId.value) {
        currentWorkspaceId.value = 'default';
      }

      await _repository!.delete(uuid);
      workspaces.removeWhere((w) => w.uuid == uuid);
      _logger.d('删除工作空间成功: $uuid');
      return true;
    } catch (e) {
      _logger.e('删除工作空间失败: $e');
      return false;
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
      
      // 刷新任务列表（通过TaskManager）
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        await homeCtrl.refreshData();
      }
    } catch (e) {
      _logger.e('切换工作空间失败: $e');
    }
  }
}

