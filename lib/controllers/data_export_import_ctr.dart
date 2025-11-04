import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:TodoCat/data/services/data_export_import_service.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/widgets/data_export_confirm_dialog.dart';
import 'package:TodoCat/widgets/data_import_confirm_dialog.dart';

class DataExportImportController extends GetxController {
  static final _logger = Logger();
  DataExportImportService? _service;
  
  final isExporting = false.obs;
  final isImporting = false.obs;
  final exportPreview = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() async {
    super.onInit();
    await _initService();
    await _loadExportPreview();
  }

  /// 初始化服务
  Future<void> _initService() async {
    try {
      _service = await DataExportImportService.getInstance();
    } catch (e) {
      _logger.e('初始化数据导出导入服务失败: $e');
    }
  }

  /// 确保服务已初始化
  Future<DataExportImportService> _ensureService() async {
    if (_service == null) {
      await _initService();
    }
    if (_service == null) {
      throw Exception('数据导出导入服务初始化失败');
    }
    return _service!;
  }

  /// 加载导出预览信息
  Future<void> _loadExportPreview() async {
    try {
      final service = await _ensureService();
      final preview = await service.getExportPreview();
      exportPreview.value = preview;
    } catch (e) {
      _logger.e('加载导出预览失败: $e');
    }
  }

  /// 执行数据导出
  Future<void> exportData() async {
    if (isExporting.value) return;
    
    try {
      isExporting.value = true;
      _logger.i('开始导出数据...');
      
      // 显示导出确认对话框
      final confirmed = await _showExportConfirmDialog();
      if (!confirmed) {
        _logger.i('用户取消了导出操作');
        return;
      }
      
      showInfoNotification('正在导出数据，请稍候...');
      
      final service = await _ensureService();
      final filePath = await service.exportData();
      
      if (filePath != null) {
        showSuccessNotification('数据导出成功！文件已保存到: $filePath');
        _logger.i('数据导出成功: $filePath');
      } else {
        showInfoNotification('exportCancelled'.tr);
      }
      
    } catch (e) {
      _logger.e('导出数据失败: $e');
      showErrorNotification('${'exportFailed'.tr}: ${e.toString()}');
    } finally {
      isExporting.value = false;
    }
  }

  /// 执行数据导入
  Future<void> importData() async {
    if (isImporting.value) return;
    
    try {
      isImporting.value = true;
      _logger.i('startingImport'.tr);
      
      // 显示导入警告对话框
      final confirmed = await _showImportConfirmDialog();
      if (!confirmed) {
        _logger.i('userCancelledImport'.tr);
        return;
      }
      
      showInfoNotification('importingDataPlease'.tr);
      
      final service = await _ensureService();
      final result = await service.importData();
      
      if (result.success) {
        showSuccessNotification(result.message);
        // 刷新导出预览
        await _loadExportPreview();
        // 通知HomeController刷新数据
        try {
          final homeController = Get.find<HomeController>();
          await homeController.refreshData();
        } catch (e) {
          _logger.w('未找到HomeController，跳过数据刷新: $e');
        }
        _logger.i('数据导入成功');
      } else {
        showErrorNotification(result.message);
        _logger.w('数据导入失败: ${result.message}');
      }
      
    } catch (e) {
      _logger.e('导入数据失败: $e');
      showErrorNotification('${'importFailed'.tr}: ${e.toString()}');
    } finally {
      isImporting.value = false;
    }
  }

  /// 显示导出确认对话框
  Future<bool> _showExportConfirmDialog() async {
    final preview = exportPreview.value;
    if (preview == null) return false;
    
    bool? confirmed;
    
    await SmartDialog.show(
      useSystem: false,
      debounce: true,
      keepSingle: true,
      tag: 'export_confirm_dialog',
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 200),
      alignment: Alignment.center,
      builder: (_) => DataExportConfirmDialog(
        preview: preview,
        onConfirm: () {
          confirmed = true;
          SmartDialog.dismiss(tag: 'export_confirm_dialog');
        },
        onCancel: () {
          confirmed = false;
          SmartDialog.dismiss(tag: 'export_confirm_dialog');
        },
      ),
      clickMaskDismiss: true,
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
    
    return confirmed ?? false;
  }

  /// 显示导入确认对话框
  Future<bool> _showImportConfirmDialog() async {
    bool? confirmed;
    
    await SmartDialog.show(
      useSystem: false,
      debounce: true,
      keepSingle: true,
      tag: 'import_confirm_dialog',
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 200),
      alignment: Alignment.center,
      builder: (_) => DataImportConfirmDialog(
        onConfirm: () {
          confirmed = true;
          SmartDialog.dismiss(tag: 'import_confirm_dialog');
        },
        onCancel: () {
          confirmed = false;
          SmartDialog.dismiss(tag: 'import_confirm_dialog');
        },
      ),
      clickMaskDismiss: true,
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
    
    return confirmed ?? false;
  }

  /// 刷新导出预览
  Future<void> refreshPreview() async {
    await _loadExportPreview();
  }
}