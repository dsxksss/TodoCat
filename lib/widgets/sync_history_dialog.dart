import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:todo_cat/services/sync_manager.dart';
import 'package:todo_cat/widgets/dialog_header.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';

class SyncHistoryDialog extends StatefulWidget {
  final String workspaceUuid;

  const SyncHistoryDialog({Key? key, required this.workspaceUuid})
      : super(key: key);

  @override
  State<SyncHistoryDialog> createState() => _SyncHistoryDialogState();
}

class _SyncHistoryDialogState extends State<SyncHistoryDialog> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history =
          await SyncManager().listWorkspaceHistory(widget.workspaceUuid);
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      showToast('加载历史记录失败: $e', toastStyleType: TodoCatToastStyleType.error);
    }
  }

  Future<void> _restoreVersion(Map<String, dynamic> version) async {
    showToast(
      '确定要恢复到此版本吗？\n这将覆盖当前的本地数据。',
      confirmMode: true,
      onYesCallback: () async {
        SmartDialog.dismiss(tag: 'sync_history_dialog'); // Close history dialog
        // Show loading in config dialog or global?
        // Let's rely on toast or global loading if possible, or blocking.
        // But since this dialog is closed, we need a way to show progress.
        SmartDialog.showLoading(msg: 'Restoring...');
        try {
          await SyncManager().restoreWorkspace(
            widget.workspaceUuid,
            historyPath: version['path'],
            historyTimestamp: version['syncedAt'],
          );

          // Refer to _restoreRemoteWorkspace logic in SyncConfigDialog
          if (Get.isRegistered<WorkspaceController>()) {
            await Get.find<WorkspaceController>().loadWorkspaces();
          }
          if (Get.isRegistered<WorkspaceController>() &&
              Get.isRegistered<HomeController>()) {
            final wsCtrl = Get.find<WorkspaceController>();
            final homeCtrl = Get.find<HomeController>();

            // If we are on the restored workspace, refresh it
            if (wsCtrl.currentWorkspaceId.value == widget.workspaceUuid) {
              await homeCtrl.refreshData(
                  showEmptyPrompt: false, clearBeforeRefresh: true);
            }
          }

          showToast('restoreSuccess'.tr,
              toastStyleType: TodoCatToastStyleType.success);
        } catch (e) {
          showToast('${'syncFailed'.tr}: $e',
              toastStyleType: TodoCatToastStyleType.error);
        } finally {
          SmartDialog.dismiss();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adaptive size
    final width = context.isPhone ? Get.width : 400.0;

    return Container(
      width: width,
      constraints: BoxConstraints(
        maxHeight: context.isPhone ? Get.height * 0.8 : 500,
      ),
      padding: context.isPhone ? const EdgeInsets.only(top: 12) : null,
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: '历史版本',
            onCancel: () => SmartDialog.dismiss(tag: 'sync_history_dialog'),
            showConfirm: false,
          ),
          Flexible(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            '暂无历史版本',
                            style: TextStyle(color: context.theme.hintColor),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final version = _history[index];
                          final timestamp = version['syncedAt'] as int;
                          final date =
                              DateTime.fromMillisecondsSinceEpoch(timestamp);
                          final dateStr =
                              DateFormat('yyyy-MM-dd HH:mm:ss').format(date);

                          return ListTile(
                            title: Text(
                              dateStr,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _restoreVersion(version),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                minimumSize: const Size(60, 32),
                              ),
                              child: const Text('恢复',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
