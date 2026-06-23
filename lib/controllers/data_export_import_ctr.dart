import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'package:todo_cat/data/services/data_export_import_service.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/widgets/data_export_confirm_dialog.dart';
import 'package:todo_cat/widgets/data_import_confirm_dialog.dart';
import 'package:todo_cat/core/utils/l10n.dart';

part 'data_export_import_ctr.g.dart';

/// 数据导入/导出状态。
@immutable
class DataExportImportState {
  final bool isExporting;
  final bool isImporting;
  final Map<String, dynamic>? exportPreview;

  const DataExportImportState({
    this.isExporting = false,
    this.isImporting = false,
    this.exportPreview,
  });

  DataExportImportState copyWith({
    bool? isExporting,
    bool? isImporting,
    Map<String, dynamic>? exportPreview,
  }) {
    return DataExportImportState(
      isExporting: isExporting ?? this.isExporting,
      isImporting: isImporting ?? this.isImporting,
      exportPreview: exportPreview ?? this.exportPreview,
    );
  }
}

@Riverpod(keepAlive: true)
class DataExportImportController extends _$DataExportImportController {
  static final _logger = Logger();
  DataExportImportService? _service;

  @override
  DataExportImportState build() {
    _init();
    return const DataExportImportState();
  }

  Future<void> _init() async {
    await _initService();
    await _loadExportPreview();
  }

  Future<void> _initService() async {
    try {
      _service = await DataExportImportService.getInstance();
    } catch (e) {
      _logger.e('初始化数据导出导入服务失败: $e');
    }
  }

  Future<DataExportImportService> _ensureService() async {
    if (_service == null) {
      await _initService();
    }
    if (_service == null) {
      throw Exception('数据导出导入服务初始化失败');
    }
    return _service!;
  }

  Future<void> _loadExportPreview() async {
    try {
      final service = await _ensureService();
      final preview = await service.getExportPreview();
      state = state.copyWith(exportPreview: preview);
    } catch (e) {
      _logger.e('加载导出预览失败: $e');
    }
  }

  /// 执行数据导出
  Future<void> exportData() async {
    if (state.isExporting) return;
    try {
      state = state.copyWith(isExporting: true);
      _logger.i('开始导出数据...');

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
        showInfoNotification(l10n.exportCancelled);
      }
    } catch (e) {
      _logger.e('导出数据失败: $e');
      showErrorNotification('${l10n.exportFailed}: ${e.toString()}');
    } finally {
      state = state.copyWith(isExporting: false);
    }
  }

  /// 执行数据导入
  Future<void> importData() async {
    if (state.isImporting) return;
    try {
      state = state.copyWith(isImporting: true);
      _logger.i(l10n.startingImport);

      final confirmed = await _showImportConfirmDialog();
      if (!confirmed) {
        _logger.i(l10n.userCancelledImport);
        return;
      }

      showInfoNotification(l10n.importingDataPlease);

      final service = await _ensureService();
      final result = await service.importData();

      if (result.success) {
        showSuccessNotification(result.message);
        await _loadExportPreview();
        try {
          await ref.read(homeControllerProvider.notifier).refreshData();
        } catch (e) {
          _logger.w('刷新主页数据失败: $e');
        }
        _logger.i('数据导入成功');
      } else {
        showErrorNotification(result.message);
        _logger.w('数据导入失败: ${result.message}');
      }
    } catch (e) {
      _logger.e('导入数据失败: $e');
      showErrorNotification('${l10n.importFailed}: ${e.toString()}');
    } finally {
      state = state.copyWith(isImporting: false);
    }
  }

  Future<bool> _showExportConfirmDialog() async {
    final preview = state.exportPreview;
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
