import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:todo_cat/services/auto_update_service.dart';
import 'package:todo_cat/widgets/label_btn.dart';

/// 更新进度对话框组件
class UpdateProgressDialogWidget extends StatefulWidget {
  final AutoUpdateService updateService;
  
  const UpdateProgressDialogWidget({
    super.key,
    required this.updateService,
  });

  @override
  State<UpdateProgressDialogWidget> createState() => _UpdateProgressDialogWidgetState();
}

class _UpdateProgressDialogWidgetState extends State<UpdateProgressDialogWidget> {
  double _progress = 0.0;
  String _status = 'checkingForUpdates'.tr;
  bool _isDownloading = false;
  final bool _isInstalling = false;

  @override
  void initState() {
    super.initState();
    _setupProgressListeners();
  }

  void _setupProgressListeners() {
    // 监听进度更新
    widget.updateService.onProgress = (progress, status) {
      if (mounted) {
        setState(() {
          _progress = progress;
          _status = status;
          _isDownloading = progress > 0.0 && progress < 1.0;
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
        });
      }
    };
    
    // 监听更新错误
    widget.updateService.onUpdateError = (error) {
      if (mounted) {
        setState(() {
          _status = 'updateError'.tr;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isPhone ? 0.9.sw : 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
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
              if (!_isDownloading && !_isInstalling && _progress == 0.0)
                LabelBtn(
                  label: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  ghostStyle: true,
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 进度条
          if (_progress > 0.0) ...[
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
          
          // 取消按钮（仅在检查阶段显示）
          if (!_isDownloading && !_isInstalling && _progress == 0.0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('cancel'.tr),
              ),
            ),
        ],
      ),
    );
  }
}

