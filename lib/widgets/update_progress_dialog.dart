import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/services/auto_update_service.dart';
import 'package:todo_cat/widgets/label_btn.dart';

/// 更新进度对话框
class UpdateProgressDialog extends StatefulWidget {
  final AutoUpdateService updateService;
  
  const UpdateProgressDialog({
    super.key,
    required this.updateService,
  });

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  double _progress = 0.0;
  String _status = 'checkingForUpdates'.tr;
  bool _isDownloading = false;
  bool _isInstalling = false;

  @override
  void initState() {
    super.initState();
    _setupProgressListeners();
    // 开始检查更新
    _checkForUpdates();
  }

  void _setupProgressListeners() {
    // 监听进度更新
    widget.updateService.onProgress = (progress, status) {
      if (mounted) {
        setState(() {
          _progress = progress;
          _status = status;
          _isDownloading = progress > 0.0 && progress < 1.0;
          _isInstalling = status.contains('installing') || status.contains('安装');
        });
      }
    };
    
    // 监听更新可用
    widget.updateService.onUpdateAvailable = (version, changelog) {
      if (mounted) {
        setState(() {
          _status = '${'newVersionAvailable'.tr}: $version';
          _progress = 1.0;
        });
      }
    };
    
    // 监听更新完成
    widget.updateService.onUpdateComplete = () {
      if (mounted) {
        setState(() {
          _status = 'updateComplete'.tr;
          _progress = 1.0;
          _isDownloading = false;
          _isInstalling = false;
        });
      }
    };
    
    // 监听更新错误
    widget.updateService.onUpdateError = (error) {
      if (mounted) {
        setState(() {
          _status = 'updateError'.tr;
          _isDownloading = false;
          _isInstalling = false;
        });
      }
    };
    
    // 监听已是最新版本
    widget.updateService.onAlreadyLatestVersion = () {
      if (mounted) {
        setState(() {
          _status = 'alreadyLatestVersion'.tr;
          _progress = 1.0;
        });
      }
    };
  }

  Future<void> _checkForUpdates() async {
    try {
      setState(() {
        _status = 'checkingForUpdates'.tr;
        _progress = 0.0;
      });

      // 触发更新检查
      await widget.updateService.checkForUpdates(silent: false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'updateError'.tr;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: context.isPhone ? 0.9.sw : 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.system_update, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'checkingForUpdates'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isDownloading && !_isInstalling)
                  LabelBtn(
                    label: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    ghostStyle: true,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 进度条
            if (_isDownloading || _isInstalling) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 状态文本
            Text(
              _status,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // 停止/取消按钮（仅在检查阶段或下载阶段显示）
            if ((!_isDownloading && !_isInstalling && _progress == 0.0) || _isDownloading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isDownloading) {
                      // 停止下载
                      widget.updateService.cancelDownload();
                      setState(() {
                        _isDownloading = false;
                        _status = 'downloadCancelled'.tr;
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDownloading ? Colors.red : null,
                    foregroundColor: _isDownloading ? Colors.white : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isDownloading) ...[
                        const Icon(Icons.stop, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(_isDownloading ? 'stop'.tr : 'cancel'.tr),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

