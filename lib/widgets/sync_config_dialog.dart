import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/services/webdav_service.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/services/sync_manager.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/trash_ctr.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'dart:io';
import 'package:todo_cat/data/schemas/workspace.dart';
import 'package:intl/intl.dart';
import 'package:todo_cat/widgets/platform_dialog_wrapper.dart';
import 'package:todo_cat/widgets/sync_history_dialog.dart';
import 'package:todo_cat/data/database/database.dart' show AppDatabase;

import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/responsive.dart';

class SyncConfigDialog extends ConsumerStatefulWidget {
  const SyncConfigDialog({super.key});

  @override
  ConsumerState<SyncConfigDialog> createState() => _SyncConfigDialogState();
}

class _SyncConfigDialogState extends ConsumerState<SyncConfigDialog> {
  // Default Credentials (Hidden from User)
  final _defaultUrl = 'https://dav.jianguoyun.com/dav/';
  final _defaultUser = '2546650292@qq.com';
  final _defaultPass = 'au7gnvf89xg46myj';

  final _importKeyController = TextEditingController();
  bool _isLoading = false;
  String? _connectionStatus;
  bool _isConnected = false;
  String _workspaceKey = '';

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  Future<void> _initConnection() async {
    // Initialize SyncManager (loads config and status)
    await SyncManager().init();

    // Check if config exists, if not use default
    if (SyncManager().currentConfig == null) {
      await _useDefaultConfig();
    } else {
      _checkConnection();
    }

    if (mounted) {
      setState(() {
        _workspaceKey = _generateWorkspaceKey();
      });
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
          _connectionStatus = success ? l10n.connected : l10n.syncFailed;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _connectionStatus = l10n.syncFailed;
        });
      }
    }
  }

  String _generateWorkspaceKey() {
    final config = SyncManager().currentConfig ??
        WebDavConfig(
            url: _defaultUrl, username: _defaultUser, password: _defaultPass);

    final wsState = ref.read(workspaceControllerProvider);
    final wsId = wsState.currentWorkspaceId;
    // Find workspace name safely
    String wsName = 'Unknown';
    try {
      final ws = wsState.workspaces.firstWhere((w) => w.uuid == wsId,
          orElse: () => Workspace()..name = 'Unknown');
      wsName = ws.name;
    } catch (_) {}

    final data = config.toJson();
    data['wsId'] = wsId;
    data['wsName'] = wsName;

    final base64Key = base64Encode(utf8.encode(jsonEncode(data)));

    final lastSyncTime = SyncManager().getLastSyncTime(wsId);
    String lastSyncStr = 'Never';
    if (lastSyncTime != null) {
      lastSyncStr = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.fromMillisecondsSinceEpoch(lastSyncTime));
    }

    return '''${l10n.shareContentWorkspace}: "$wsName"
${l10n.shareContentId}: $wsId
${l10n.shareContentLastSynced}: $lastSyncStr
${l10n.shareContentKey}: $base64Key''';
  }

  void _copyWorkspaceKey() {
    final key = _generateWorkspaceKey();
    Clipboard.setData(ClipboardData(text: key));
    showToast(l10n.keyCopied, toastStyleType: TodoCatToastStyleType.success);
  }

  Future<void> _importWorkspaceKey() async {
    if (_importKeyController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      var text = _importKeyController.text.trim();

      // Robust Parsing: Try to find the key line
      // Strategy: Split by newlines, for each line try to decode.
      // If direct decode matches JSON with 'url', valid.
      // Or try to split by ':' in case of labeled line.

      String? foundJsonStr;

      final lines = text.split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        // Try raw line
        try {
          final decoded = utf8.decode(base64Decode(line));
          final json = jsonDecode(decoded);
          if (json is Map && json.containsKey('url')) {
            foundJsonStr = decoded;
            break;
          }
        } catch (_) {}

        // Try split by ':' (last part)
        if (line.contains(':')) {
          final potentialKey = line.split(':').last.trim();
          try {
            final decoded = utf8.decode(base64Decode(potentialKey));
            final json = jsonDecode(decoded);
            if (json is Map && json.containsKey('url')) {
              foundJsonStr = decoded;
              break;
            }
          } catch (_) {}
        }
      }

      if (foundJsonStr == null) {
        throw Exception('Invalid Key Format');
      }

      final data = jsonDecode(foundJsonStr);

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
      showToast(l10n.invalidKey, toastStyleType: TodoCatToastStyleType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncToCloud() async {
    showToast(
      '${l10n.confirmSyncToCloud}\n${l10n.confirmSyncToCloudDesc}',
      confirmMode: true,
      alwaysShow: true,
      onYesCallback: () async {
        if (!mounted) return;
        setState(() => _isLoading = true);
        try {
          final currentWsId =
              ref.read(workspaceControllerProvider).currentWorkspaceId;
          await SyncManager().syncWorkspace(currentWsId);
          showToast(l10n.syncSuccess,
              toastStyleType: TodoCatToastStyleType.success);
          if (mounted) {
            setState(() {}); // Refresh UI including last sync time
          }
        } catch (e) {
          showToast('${l10n.syncFailed}: $e',
              toastStyleType: TodoCatToastStyleType.error);
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
    );
  }

  Future<void> _downloadFromCloud() async {
    showToast(
      '${l10n.confirmDownloadFromCloud}\n${l10n.confirmDownloadFromCloudDesc}',
      confirmMode: true,
      alwaysShow: true,
      onYesCallback: () async {
        if (!mounted) return;
        setState(() => _isLoading = true);
        try {
          final currentWsId =
              ref.read(workspaceControllerProvider).currentWorkspaceId;
          await SyncManager().restoreWorkspace(currentWsId);
          // 刷新工作空间数据
          await ref.read(workspaceControllerProvider.notifier).loadWorkspaces();
          await ref
              .read(homeControllerProvider.notifier)
              .refreshData(showEmptyPrompt: false, clearBeforeRefresh: true);
          // 刷新回收站数据
          await ref.read(trashControllerProvider.notifier).refresh();

          showToast(l10n.restoreSuccess,
              toastStyleType: TodoCatToastStyleType.success);
          if (mounted) {
            setState(() {}); // Refresh UI including last sync time
          }
        } catch (e) {
          showToast('${l10n.syncFailed}: $e',
              toastStyleType: TodoCatToastStyleType.error);
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
    );
  }

  Future<void> _restoreRemoteWorkspace(String uuid) async {
    try {
      await SyncManager().restoreWorkspace(uuid);

      final workspaceCtrl = ref.read(workspaceControllerProvider.notifier);
      await workspaceCtrl.loadWorkspaces();

      // 导入成功后自动切换到该工作空间
      // 切换到新导入的工作空间
      await workspaceCtrl.switchWorkspace(uuid);

      // 刷新数据以显示新工作空间的内容
      await ref.read(homeControllerProvider.notifier).refreshData(
            showEmptyPrompt: false,
            clearBeforeRefresh: true,
          );

      // 刷新回收站数据
      await ref.read(trashControllerProvider.notifier).refresh();

      showToast(l10n.restoreSuccess,
          toastStyleType: TodoCatToastStyleType.success);
      setState(() {}); // Refresh UI including last sync time
    } catch (e) {
      rethrow;
    }
  }

  void _showHistoryDialog() {
    final currentWsId =
        ref.read(workspaceControllerProvider).currentWorkspaceId;
    PlatformDialogWrapper.show(
      tag: 'sync_history_dialog',
      content: SyncHistoryDialog(workspaceUuid: currentWsId),
      clickMaskDismiss: true,
      useFixedSize: false,
    );
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
      padding: context.isPhone ? const EdgeInsets.only(top: 12) : null,
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
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min, // 自适应高度
            children: [
              DialogHeader(
                title: l10n.syncConfiguration,
                onCancel: () => SmartDialog.dismiss(tag: 'sync_config_dialog'),
                showConfirm: false,
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                      24, 0, 24, 24), // 顶部padding由头部控制
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Status Card
                      _buildStatusCard(context),
                      const SizedBox(height: 24),

                      // Import Section (Moved here)
                      Text(l10n.importWorkspace,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.8))),
                      const SizedBox(height: 12),
                      _buildImportSection(context),
                      const SizedBox(height: 24),

                      // Sync Info Section
                      Text(l10n.syncInfo,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.8))),
                      const SizedBox(height: 12),
                      _buildSyncInfoSection(context),
                      const SizedBox(height: 24),

                      // Share/Current Workspace Section
                      Text(l10n.workspaceShare,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.8))),
                      const SizedBox(height: 12),
                      _buildShareSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: context.theme.scaffoldBackgroundColor
                    .withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
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
              Text(l10n.webDavDetails,
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
            Row(
              children: [
                // Upload (Push)
                IconButton(
                  onPressed: _syncToCloud,
                  tooltip: l10n.syncToCloud,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 22),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                // Download (Pull)
                IconButton(
                  onPressed: _downloadFromCloud,
                  tooltip: l10n.restoreFromCloud,
                  icon: const Icon(Icons.cloud_download_outlined, size: 22),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                // History
                IconButton(
                  onPressed: _showHistoryDialog,
                  tooltip: '历史版本',
                  icon: const Icon(Icons.history, size: 22),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildShareSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: context.theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key,
                  color: context.theme.iconTheme.color?.withValues(alpha: 0.7),
                  size: 18),
              const SizedBox(width: 8),
              Text(l10n.syncKey,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: context.theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _workspaceKey,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: Platform.isWindows ? 'Consolas' : 'monospace',
                      color: context.theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: LabelBtn(
                    onPressed: _copyWorkspaceKey,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    label: Text(
                      l10n.copy,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.syncKeyHint,
              style: TextStyle(
                  fontSize: 12,
                  color: context.theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 16),
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
              hintText: l10n.syncKeyHint,
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
          height: 40,
          child: LabelBtn(
            onPressed: _importWorkspaceKey,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            icon: const Icon(Icons.download, size: 16, color: Colors.white),
            label: Text(
              l10n.importLabel,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncInfoSection(BuildContext context) {
    final wsState = ref.read(workspaceControllerProvider);
    if (wsState.workspaces.isEmpty) {
      return const SizedBox();
    }

    final currentWsId = wsState.currentWorkspaceId;
    final lastSyncTime = SyncManager().getLastSyncTime(currentWsId);

    // Find workspace name safely
    String wsName = 'Unknown';
    try {
      final ws = wsState.workspaces.firstWhere((w) => w.uuid == currentWsId,
          orElse: () => Workspace()..name = 'Unknown');
      wsName = ws.name;
    } catch (_) {}

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(context, l10n.workspaceName, wsName),
          const SizedBox(height: 8),
          _buildInfoRow(context, l10n.workspaceId, currentWsId),
          const SizedBox(height: 8),
          FutureBuilder<int>(
            future: () async {
              final db = await AppDatabase.getInstance();
              return (db.select(db.tasks)
                    ..where((t) => t.workspaceId.equals(currentWsId)))
                  .get()
                  .then((l) => l.length);
            }(),
            builder: (context, snapshot) {
              final dbCount = snapshot.data ?? -1;
              final homeCount = ref.read(homeControllerProvider).tasks.length;
              return _buildInfoRow(
                  context, 'Debug Tasks', 'UI: $homeCount / DB: $dbCount');
            },
          ),
          const SizedBox(height: 8),

          // 异步获取同步状态
          FutureBuilder<String>(
            future: SyncManager().getSyncStatus(currentWsId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildInfoRow(
                  context,
                  l10n.syncStatus,
                  '检查中...',
                  valueColor: Colors.grey,
                );
              }

              final status = snapshot.data ?? 'unknown';
              String statusText;
              Color statusColor;
              IconData statusIcon;

              switch (status) {
                case 'synced':
                  statusText = l10n.synced;
                  statusColor = Colors.green;
                  statusIcon = Icons.cloud_done;
                  break;
                case 'notSynced':
                  statusText = l10n.notSynced;
                  statusColor = Colors.orange;
                  statusIcon = Icons.cloud_off;
                  break;
                case 'localChanges':
                  statusText = l10n.statusLocalChanges;
                  statusColor = Colors.blue;
                  statusIcon = Icons.cloud_upload;
                  break;
                case 'remoteUpdate':
                  statusText = l10n.statusRemoteUpdate;
                  statusColor = Colors.purple;
                  statusIcon = Icons.cloud_download;
                  break;
                case 'conflict':
                  statusText = l10n.statusConflict;
                  statusColor = Colors.red;
                  statusIcon = Icons.sync_problem;
                  break;
                default:
                  statusText = l10n.unknown;
                  statusColor = Colors.grey;
                  statusIcon = Icons.help_outline;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      l10n.syncStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          if (lastSyncTime != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
                context,
                l10n.lastSyncedAt,
                DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format(DateTime.fromMillisecondsSinceEpoch(lastSyncTime))),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? context.theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
}
