import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/services/webdav_service.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/services/sync_manager.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/workspace.dart';

class SyncConfigDialog extends StatefulWidget {
  const SyncConfigDialog({super.key});

  @override
  State<SyncConfigDialog> createState() => _SyncConfigDialogState();
}

class _SyncConfigDialogState extends State<SyncConfigDialog> {
  // Default Credentials (Hidden from User)
  final _defaultUrl = 'https://dav.jianguoyun.com/dav/';
  final _defaultUser = '2546650292@qq.com';
  final _defaultPass = 'au7gnvf89xg46myj';

  final _importKeyController = TextEditingController();
  bool _isLoading = false;
  String? _connectionStatus;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  Future<void> _initConnection() async {
    // Check if config exists, if not use default
    if (SyncManager().currentConfig == null) {
      await _useDefaultConfig();
    } else {
      _checkConnection();
    }
  }

  Future<void> _useDefaultConfig() async {
    setState(() => _isLoading = true);
    try {
      final config = WebDavConfig(
        url: _defaultUrl,
        username: _defaultUser,
        password: _defaultPass,
      );
      await SyncManager().saveConfig(config);
      await _checkConnection();
    } catch (e) {
      // Ignore
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkConnection() async {
    try {
      if (SyncManager().currentConfig == null) return;
      final service = WebDavService(SyncManager().currentConfig!);
      final success = await service.checkConnection();
      if (mounted) {
        setState(() {
          _isConnected = success;
          _connectionStatus = success ? 'connected'.tr : 'syncFailed'.tr;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _connectionStatus = 'syncFailed'.tr;
        });
      }
    }
  }

  String _generateWorkspaceKey() {
    final config = SyncManager().currentConfig ??
        WebDavConfig(
            url: _defaultUrl, username: _defaultUser, password: _defaultPass);

    final wsCtrl = Get.find<WorkspaceController>();
    final wsId = wsCtrl.currentWorkspaceId.value;
    // Find workspace name safely
    String wsName = 'Unknown';
    try {
      final ws = wsCtrl.workspaces.firstWhere((w) => w.uuid == wsId,
          orElse: () => Workspace()..name = 'Unknown');
      wsName = ws.name;
    } catch (_) {}

    final data = config.toJson();
    data['wsId'] = wsId;
    data['wsName'] = wsName;

    return base64Encode(utf8.encode(jsonEncode(data)));
  }

  void _copyWorkspaceKey() {
    final key = _generateWorkspaceKey();
    Clipboard.setData(ClipboardData(text: key));
    showToast('keyCopied'.tr, toastStyleType: TodoCatToastStyleType.success);
  }

  Future<void> _importWorkspaceKey() async {
    if (_importKeyController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final text = _importKeyController.text.trim();
      final jsonStr = utf8.decode(base64Decode(text));
      final data = jsonDecode(jsonStr);

      // 1. Setup Config
      final config = WebDavConfig.fromJson(data);
      await SyncManager().saveConfig(config);

      // 2. Restore Workspace
      final targetWsId = data['wsId'];
      if (targetWsId != null) {
        await _restoreRemoteWorkspace(targetWsId);
        _importKeyController.clear();
        SmartDialog.dismiss(tag: 'sync_config_dialog');
      } else {
        showToast('Invalid Workspace Key',
            toastStyleType: TodoCatToastStyleType.error);
      }
    } catch (e) {
      showToast('invalidKey'.tr, toastStyleType: TodoCatToastStyleType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncToCloud() async {
    setState(() => _isLoading = true);
    try {
      final wsCtrl = Get.find<WorkspaceController>();
      await SyncManager().syncWorkspace(wsCtrl.currentWorkspaceId.value);
      showToast('syncSuccess'.tr,
          toastStyleType: TodoCatToastStyleType.success);
    } catch (e) {
      showToast('${'syncFailed'.tr}: $e',
          toastStyleType: TodoCatToastStyleType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreRemoteWorkspace(String uuid) async {
    try {
      await SyncManager().restoreWorkspace(uuid);

      if (Get.isRegistered<WorkspaceController>()) {
        await Get.find<WorkspaceController>().loadWorkspaces();
      }

      final workspaceCtrl = Get.find<WorkspaceController>();
      // Switch if it matches current (refresh data) or newly added
      if (Get.isRegistered<HomeController>()) {
        // If we are currently on this workspace, refresh.
        // If it's a new workspace, the user might want to switch to it?
        // For now, if current ID matches, refresh data.
        if (workspaceCtrl.currentWorkspaceId.value == uuid) {
          await Get.find<HomeController>()
              .refreshData(showEmptyPrompt: false, clearBeforeRefresh: true);
        }
      }

      showToast('restoreSuccess'.tr,
          toastStyleType: TodoCatToastStyleType.success);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 桌面端固定尺寸, 移动端适配屏幕
    final width = context.isPhone ? 1.sw : 460.0;

    return Container(
      width: width,
      constraints: BoxConstraints(
        // 增加高度适配 Safe Area
        maxHeight: context.isPhone ? 1.sh : 650,
      ),
      padding: context.isPhone
          ? EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12)
          : null,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        borderRadius: context.isPhone
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 自适应高度
        children: [
          DialogHeader(
            title: 'syncConfiguration'.tr,
            onCancel: () => SmartDialog.dismiss(tag: 'sync_config_dialog'),
            showConfirm: false,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(24, 0, 24, 24), // 顶部padding由头部控制
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Status Card
                  _buildStatusCard(context),
                  const SizedBox(height: 24),

                  // Share/Current Workspace Section
                  Text('workspaceShare'.tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.8))),
                  const SizedBox(height: 12),
                  _buildShareSection(context),

                  const SizedBox(height: 24),

                  // Import Section
                  Text('importWorkspace'.tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.8))),
                  const SizedBox(height: 12),
                  _buildImportSection(context),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final statusColor = _isConnected ? Colors.green : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isConnected ? Icons.check_circle_rounded : Icons.error_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('webDavDetails'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.theme.textTheme.bodySmall?.color,
                  )),
              const SizedBox(height: 2),
              Text(_connectionStatus ?? 'Connecting...',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _isConnected
                        ? statusColor
                        : context.theme.textTheme.bodyLarge?.color,
                  )),
            ],
          )),
          if (_isConnected)
            SizedBox(
              height: 32,
              child: IconButton(
                onPressed: _syncToCloud,
                tooltip: 'syncToCloud'.tr,
                icon: const Icon(Icons.sync, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                  foregroundColor: context.theme.iconTheme.color,
                  padding: const EdgeInsets.all(6),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildShareSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: context.theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Copy Key Action
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _copyWorkspaceKey,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.vpn_key,
                        color: context.theme.iconTheme.color
                            ?.withValues(alpha: 0.7),
                        size: 18),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('copyWorkspaceKey'.tr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          Text('syncKeyHint'.tr,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context
                                      .theme.textTheme.bodySmall?.color)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: context.theme.dividerColor
                                .withValues(alpha: 0.5)),
                      ),
                      child: Text('copy'.tr,
                          style: TextStyle(
                              color: context.theme.textTheme.bodyMedium?.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(
              height: 1,
              color: context.theme.dividerColor.withValues(alpha: 0.5)),
          // Sync Action (Manual Trigger)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _syncToCloud,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload,
                        color: context.theme.iconTheme.color
                            ?.withValues(alpha: 0.7),
                        size: 18),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('syncToCloud'.tr,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: context.theme.disabledColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _importKeyController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'syncKeyHint'.tr,
              hintStyle:
                  TextStyle(color: context.theme.hintColor, fontSize: 13),
              filled: true,
              fillColor: context.theme.cardColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: context.theme.dividerColor.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: context.theme.primaryColor.withValues(alpha: 0.5)),
              ),
              prefixIcon:
                  Icon(Icons.key, size: 16, color: context.theme.hintColor),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: _importWorkspaceKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.download, size: 16),
                const SizedBox(width: 6),
                Text('import'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
