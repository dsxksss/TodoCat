import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:TodoCat/data/schemas/app_config.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/services/repositorys/app_config.dart';
import 'package:TodoCat/data/services/repositorys/task.dart';
import 'package:TodoCat/widgets/import_conflict_dialog.dart';
import 'package:logger/logger.dart';

class DataExportImportService {
  static final _logger = Logger();
  static DataExportImportService? _instance;
  TaskRepository? _taskRepository;
  AppConfigRepository? _appConfigRepository;

  DataExportImportService._();

  static Future<DataExportImportService> getInstance() async {
    _instance ??= DataExportImportService._();
    return _instance!;
  }

  /// 获取TaskRepository实例
  Future<TaskRepository> _getTaskRepository() async {
    _taskRepository ??= await TaskRepository.getInstance();
    return _taskRepository!;
  }

  /// 获取AppConfigRepository实例
  Future<AppConfigRepository> _getAppConfigRepository() async {
    _appConfigRepository ??= await AppConfigRepository.getInstance();
    return _appConfigRepository!;
  }

  /// 导出应用数据到JSON文件
  Future<String?> exportData() async {
    try {
      _logger.i('开始导出应用数据...');

      // 获取所有数据
      final taskRepository = await _getTaskRepository();
      final appConfigRepository = await _getAppConfigRepository();

      final tasks = await taskRepository.readAll();
      final appConfig = await appConfigRepository.read('defaultConfig');

      // 构建导出数据结构
      final exportData = {
        'exportInfo': {
          'version': '1.0.0',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'appName': 'TodoCat',
        },
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'appConfig': appConfig?.toJson(),
      };

      // 转换为JSON字符串
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // 选择保存位置
      final filePath = await _selectSaveLocation();
      if (filePath == null) {
        _logger.w('用户取消了文件保存');
        return null;
      }

      // 保存文件
      final file = File(filePath);
      await file.writeAsString(jsonString, encoding: utf8);

      _logger.i('数据导出成功: $filePath');
      return filePath;
    } catch (e) {
      _logger.e('导出数据失败: $e');
      rethrow;
    }
  }

  /// 从JSON文件导入数据
  Future<ImportResult> importData() async {
    try {
      _logger.i('Starting application data import...');

      // 选择要导入的文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'selectDataFileToImport'.tr,
      );

      if (result == null || result.files.isEmpty) {
        _logger.w('User cancelled file selection');
        return ImportResult(
            success: false, message: 'userCancelledOperation'.tr);
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString(encoding: utf8);

      // 检查文件是否为空
      if (jsonString.trim().isEmpty) {
        _logger.w('JSON文件为空');
        return ImportResult(success: false, message: 'invalidFileFormat'.tr);
      }

      // 解析JSON数据，添加异常处理
      Map<String, dynamic> data;
      try {
        data = json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        _logger.e('JSON解析失败: $e');
        return ImportResult(success: false, message: 'invalidFileFormat'.tr);
      }

      // 验证数据格式
      if (!_validateImportData(data)) {
        return ImportResult(success: false, message: 'invalidFileFormat'.tr);
      }

      // 开始导入
      final importResult = await _performImport(data);

      _logger.i('Data import successful');
      return importResult;
    } catch (e) {
      _logger.e('Data import failed: $e');
      return ImportResult(
          success: false,
          message: '${'importFailed'.tr}: ${e.toString()}');
    }
  }

  /// 选择保存位置
  Future<String?> _selectSaveLocation() async {
    try {
      _logger.i('开始选择保存位置...');

      // 获取默认文档目录
      final directory = await getApplicationDocumentsDirectory();
      final defaultFileName =
          'todocat_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      _logger.d('默认文档目录: ${directory.path}');
      _logger.d('默认文件名: $defaultFileName');

      // 首先尝试使用saveFile方法
      String? result;
      try {
        _logger.d('尝试使用saveFile方法...');
        result = await FilePicker.platform.saveFile(
          dialogTitle: 'selectSaveLocation'.tr,
          fileName: defaultFileName,
          allowedExtensions: ['json'],
        );
        _logger.d('saveFile结果: $result');
      } catch (e) {
        _logger.w('saveFile方法失败，尝试备用方案: $e');

        // 如果saveFile失败，直接保存到文档目录
        result = path.join(directory.path, defaultFileName);
        _logger.d('使用默认路径: $result');
      }

      return result;
    } catch (e) {
      _logger.e('选择保存位置失败: $e');
      // 最后的备用方案：直接保存到文档目录
      try {
        final directory = await getApplicationDocumentsDirectory();
        final defaultFileName =
            'todocat_backup_${DateTime.now().millisecondsSinceEpoch}.json';
        final fallbackPath = path.join(directory.path, defaultFileName);
        _logger.i('使用备用路径: $fallbackPath');
        return fallbackPath;
      } catch (fallbackError) {
        _logger.e('备用保存方案也失败: $fallbackError');
        return null;
      }
    }
  }

  /// 验证导入数据格式
  bool _validateImportData(Map<String, dynamic> data) {
    try {
      // 检查必要的字段
      if (!data.containsKey('exportInfo') || !data.containsKey('tasks')) {
        return false;
      }

      final exportInfo = data['exportInfo'] as Map<String, dynamic>?;
      if (exportInfo == null ||
          !exportInfo.containsKey('appName') ||
          exportInfo['appName'] != 'TodoCat') {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 执行数据导入
  Future<ImportResult> _performImport(Map<String, dynamic> data) async {
    _logger.i('Starting data import execution...');

    final taskRepository = await _getTaskRepository();
    final appConfigRepository = await _getAppConfigRepository();

    // 获取现有任务列表以检查重复
    final existingTasks = await taskRepository.readAll();
    final existingTaskMap = <String, Task>{};
    for (final task in existingTasks) {
      existingTaskMap[task.title.toLowerCase()] = task;
    }

    // 首先检查是否有冲突的任务
    final conflictTasks = <String>[];
    final templateTasks = <String>[]; // 新增：存储模板任务
    if (data['tasks'] != null) {
      final tasksData = data['tasks'] as List;
      _logger.d('检查 ${tasksData.length} 个任务的冲突情况');
      _logger.d('现有任务: ${existingTaskMap.keys.toList()}');

      for (final taskData in tasksData) {
        try {
          final task = Task.fromJson(taskData as Map<String, dynamic>);
          _logger.d('检查任务: ${task.title} (小写: ${task.title.toLowerCase()})');

          // 检查是否是模板任务
          if (_isTemplateTask(task)) {
            _logger.d('发现模板任务: ${task.title}');
            templateTasks.add(task.title);
            // 不要continue，继续检查是否存在冲突
          }

          // 检查是否存在冲突
          if (existingTaskMap.containsKey(task.title.toLowerCase())) {
            _logger.d('发现冲突任务: ${task.title}');
            conflictTasks.add(task.title);
          } else {
            _logger.d('任务 ${task.title} 无冲突');
          }
        } catch (e) {
          _logger.w('解析任务数据失败: $e');
        }
      }
    }

    _logger.d('冲突任务列表: $conflictTasks');
    _logger.d('模板任务列表: $templateTasks');

    // 如果有冲突（包括模板任务冲突），显示对话框让用户选择
    ConflictAction conflictAction = ConflictAction.skip;
    final allConflicts = [...conflictTasks, ...templateTasks];
    if (allConflicts.isNotEmpty) {
      conflictAction = await _showConflictDialog(allConflicts);
      if (conflictAction == ConflictAction.cancel) {
        return ImportResult(success: false, message: 'userCancelledImport'.tr);
      }
    }

    int tasksImported = 0;
    int tasksSkipped = 0;
    int tasksReplaced = 0;
    bool configImported = false;

    // 导入任务数据
    if (data['tasks'] != null) {
      final tasksData = data['tasks'] as List;
      for (final taskData in tasksData) {
        try {
          final task = Task.fromJson(taskData as Map<String, dynamic>);

          // 处理模板任务冲突
          if (_isTemplateTask(task)) {
            final existingTask = existingTaskMap[task.title.toLowerCase()];
            if (existingTask != null) {
              if (conflictAction == ConflictAction.skip) {
                _logger.d('跳过模板任务: ${task.title}');
                tasksSkipped++;
                continue;
              } else if (conflictAction == ConflictAction.replace) {
                // 先删除原有任务
                await taskRepository.delete(existingTask.uuid);
                // 然后写入新任务
                await taskRepository.write(task.uuid, task);
                existingTaskMap[task.title.toLowerCase()] = task;
                tasksReplaced++;
                _logger.d('替换模板任务: ${task.title}');
                continue;
              }
            } else {
              // 模板任务不存在，直接导入
              await taskRepository.write(task.uuid, task);
              existingTaskMap[task.title.toLowerCase()] = task;
              tasksImported++;
              _logger.d('导入新模板任务: ${task.title}');
              continue;
            }
          }

          // 检查是否存在冲突
          final existingTask = existingTaskMap[task.title.toLowerCase()];
          if (existingTask != null) {
            if (conflictAction == ConflictAction.skip) {
              _logger.d('跳过重复任务: ${task.title}');
              tasksSkipped++;
              continue;
            } else if (conflictAction == ConflictAction.replace) {
              // 先删除原有任务
              await taskRepository.delete(existingTask.uuid);
              // 然后写入新任务
              await taskRepository.write(task.uuid, task);
              existingTaskMap[task.title.toLowerCase()] = task; // 更新映射
              tasksReplaced++;
              _logger.d('替换任务: ${task.title}');
              continue;
            }
          }

          // 新任务，直接导入
          await taskRepository.write(task.uuid, task);
          existingTaskMap[task.title.toLowerCase()] = task; // 添加到映射
          tasksImported++;
          _logger.d('导入新任务: ${task.title}');
        } catch (e) {
          _logger.w('导入任务失败: $e');
        }
      }
    }

    // 导入应用配置
    if (data['appConfig'] != null) {
      try {
        final configData = data['appConfig'] as Map<String, dynamic>;
        final appConfig = AppConfig.fromJson(configData);
        await appConfigRepository.write('defaultConfig', appConfig);
        configImported = true;
        _logger.d('导入应用配置成功');
      } catch (e) {
        _logger.w('导入应用配置失败: $e');
      }
    }

    _logger.i(
        '数据导入执行完成 - 新导入: $tasksImported, 替换: $tasksReplaced, 跳过: $tasksSkipped');

    // 构建结果消息
    String message;
    if (tasksImported > 0 || tasksReplaced > 0 || configImported) {
      final parts = <String>[];
      if (tasksImported > 0) {
        parts.add('${'importedNewTasks'.tr} $tasksImported');
      }
      if (tasksReplaced > 0) {
        parts.add('${'replacedTasks'.tr} $tasksReplaced');
      }
      if (tasksSkipped > 0) {
        parts.add('${'skippedTasks'.tr} $tasksSkipped');
      }
      if (configImported) {
        parts.add('updatedAppConfig'.tr);
      }
      message = parts.join('，');
    } else {
      message = 'noNewDataToImport'.tr;
    }

    return ImportResult(
      success: true,
      message: message,
      tasksImported: tasksImported + tasksReplaced,
      configImported: configImported,
    );
  }

  /// 检查是否是模板任务
  bool _isTemplateTask(Task task) {
    final templateTitles = {'todo', 'inProgress', 'done', 'another'};
    final hasDefaultTags = task.tags.contains('默认') && task.tags.contains('自带');
    final isTemplate = templateTitles.contains(task.title) && hasDefaultTags;

    _logger.d(
        '检查任务 ${task.title} 是否为模板: 标题匹配=${templateTitles.contains(task.title)}, 有默认标签=$hasDefaultTags, 结果=$isTemplate');
    _logger.d('任务标签: ${task.tags}');

    return isTemplate;
  }

  /// 显示冲突处理对话框
  Future<ConflictAction> _showConflictDialog(List<String> conflictTasks) async {
    ConflictAction? selectedAction;

    await SmartDialog.show(
      useSystem: false,
      debounce: true,
      keepSingle: true,
      tag: 'import_conflict_dialog',
      backType: SmartBackType.normal,
      animationTime: const Duration(milliseconds: 200),
      alignment: Alignment.center,
      builder: (_) => ImportConflictDialog(
        conflictTasks: conflictTasks,
        onSkip: () {
          selectedAction = ConflictAction.skip;
          SmartDialog.dismiss(tag: 'import_conflict_dialog');
        },
        onReplace: () {
          selectedAction = ConflictAction.replace;
          SmartDialog.dismiss(tag: 'import_conflict_dialog');
        },
        onCancel: () {
          selectedAction = ConflictAction.cancel;
          SmartDialog.dismiss(tag: 'import_conflict_dialog');
        },
      ),
      clickMaskDismiss: false,
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

    return selectedAction ?? ConflictAction.cancel;
  }

  /// 获取导出数据预览
  Future<Map<String, dynamic>> getExportPreview() async {
    try {
      final taskRepository = await _getTaskRepository();
      final appConfigRepository = await _getAppConfigRepository();

      final tasks = await taskRepository.readAll();
      final appConfig = await appConfigRepository.read('defaultConfig');

      return {
        'tasksCount': tasks.length,
        'todosCount':
            tasks.fold<int>(0, (sum, task) => sum + (task.todos?.length ?? 0)),
        'hasAppConfig': appConfig != null,
        'dataSize': _estimateDataSize(tasks, appConfig),
      };
    } catch (e) {
      _logger.e('获取导出预览失败: $e');
      return {
        'tasksCount': 0,
        'todosCount': 0,
        'hasAppConfig': false,
        'dataSize': 0,
      };
    }
  }

  /// 估算数据大小（KB）
  int _estimateDataSize(List<Task> tasks, AppConfig? appConfig) {
    try {
      final exportData = {
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'appConfig': appConfig?.toJson(),
      };
      final jsonString = json.encode(exportData);
      return (jsonString.length / 1024).ceil();
    } catch (e) {
      return 0;
    }
  }
}

/// 导入结果类
class ImportResult {
  final bool success;
  final String message;
  final int? tasksImported;
  final bool? configImported;

  ImportResult({
    required this.success,
    required this.message,
    this.tasksImported,
    this.configImported,
  });
}
