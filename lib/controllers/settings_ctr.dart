import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/controllers/workspace_ctr.dart';
import 'package:todo_cat/controllers/trash_ctr.dart';
import 'package:todo_cat/data/services/database.dart';
import 'package:todo_cat/data/services/repositorys/workspace.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'package:todo_cat/data/services/repositorys/app_config.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/settings/settings_page.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/services/auto_update_service.dart';
import 'package:todo_cat/config/default_backgrounds.dart';
import 'package:logger/logger.dart';

class SettingsController extends GetxController {
  static final _logger = Logger();
  final AppController appCtrl = Get.find();
  final HomeController homeCtrl = Get.find();
  late final Rx<String> currentLanguage;
  var isAnimating = false.obs;
  // 开机自启动状态（仅桌面端）
  final RxBool launchAtStartupEnabled = false.obs;
  // 显示 Todo 图片封面状态
  final RxBool showTodoImageEnabled = false.obs;
  // 当前应用版本号
  final RxString appVersion = 'Loading...'.obs;
  // 更新检查状态
  final RxDouble updateProgress =
      0.0.obs; // 0.0 = 未开始, 0.0-1.0 = 进行中, 1.0 = 完成, -1.0 = 错误
  final RxString updateStatus = ''.obs; // 更新状态文本
  final RxBool isDownloading = false.obs; // 是否正在下载更新

  @override
  void onClose() {
    // 取消下载（如果正在下载）
    if (isDownloading.value) {
      appCtrl.autoUpdateService.cancelDownload();
    }
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // 初始化显示 Todo 图片状态
    showTodoImageEnabled.value = appCtrl.appConfig.value.showTodoImage;
    // 监听配置变化
    ever(appCtrl.appConfig, (config) {
      showTodoImageEnabled.value = config.showTodoImage;
    });
    // 监听语言变化
    ever(appCtrl.appConfig, (_) {
      currentLanguage.value = _getLanguageTitle(
        appCtrl.appConfig.value.locale.languageCode,
      );
    });

    currentLanguage = _getLanguageTitle(
      appCtrl.appConfig.value.locale.languageCode,
    ).obs;

    // 初始化自启动状态（桌面端）
    if (GetPlatform.isDesktop) {
      _refreshLaunchAtStartupState();
    }

    // 加载应用版本号
    _loadAppVersion();
  }

  /// 加载应用版本号
  Future<void> _loadAppVersion() async {
    try {
      final version = await AutoUpdateService.getCurrentVersion();
      if (version != null) {
        appVersion.value = version;
      } else {
        appVersion.value = 'Unknown';
      }
    } catch (e) {
      _logger.e('获取版本号失败: $e');
      appVersion.value = 'Unknown';
    }
  }

  String _getLanguageTitle(String locale) {
    switch (locale) {
      case "en":
        return "English";
      case "zh":
        return "中文";
      default:
        return "unknown";
    }
  }

  void showSettings() {
    if (Get.context!.isPhone) {
      SmartDialog.show(
        tag: 'settings',
        alignment: Alignment.bottomCenter,
        maskColor: Colors.black38,
        clickMaskDismiss: true,
        useAnimation: true,
        animationTime: const Duration(milliseconds: 200),
        builder: (_) => Container(
          width: Get.width,
          height: Get.height * 0.6,
          margin: EdgeInsets.only(
            top: MediaQuery.of(Get.context!).padding.top + 20,
          ),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Get.theme.dialogTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: SettingsPage(),
          ),
        ),
        animationBuilder: (controller, child, animationParam) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      );
    } else {
      // 桌面端保持原来的右侧滑入
      SmartDialog.show(
        tag: 'settings',
        alignment: Alignment.centerRight,
        builder: (_) => const SettingsPage(),
        maskColor: Colors.black38,
        clickMaskDismiss: true,
        animationBuilder: (controller, child, animationParam) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      );
    }
  }

  void showLanguageMenu(BuildContext context) {
    final currentLocale = appCtrl.appConfig.value.locale.languageCode;

    showDpdMenu(
      tag: settingsDropDownMenuBtnTag,
      targetContext: context,
      menuItems: [
        MenuItem(
          title: "English",
          callback: () => changeLanguage(const Locale("en", "US")),
          isDisabled: currentLocale == "en",
        ),
        MenuItem(
          title: "中文简体",
          callback: () => changeLanguage(const Locale("zh", "CN")),
          isDisabled: currentLocale == "zh",
        ),
      ],
    );
  }

  Future<void> changeLanguage(Locale local) async {
    // 先更新系统语言
    await Get.updateLocale(local);
    // 更新配置
    appCtrl.appConfig.value = appCtrl.appConfig.value.copyWith(locale: local);
    appCtrl.appConfig.refresh();

    // 关闭语言选择菜单
    SmartDialog.dismiss(tag: settingsDropDownMenuBtnTag);
  }

  void targetEmailReminder() {
    final newConfig = appCtrl.appConfig.value.copyWith(
      emailReminderEnabled: !appCtrl.appConfig.value.emailReminderEnabled,
    );
    appCtrl.appConfig.value = newConfig;
    appCtrl.appConfig.refresh();
  }

  // 以下为开机自启动相关逻辑（桌面端）
  Future<void> _refreshLaunchAtStartupState() async {
    try {
      launchAtStartupEnabled.value = await launchAtStartup.isEnabled();
    } catch (_) {
      launchAtStartupEnabled.value = false;
    }
  }

  Future<void> toggleLaunchAtStartup() async {
    if (!GetPlatform.isDesktop) return;
    try {
      final enabled = await launchAtStartup.isEnabled();
      if (enabled) {
        await launchAtStartup.disable();
      } else {
        await launchAtStartup.enable();
      }
      await _refreshLaunchAtStartupState();
    } catch (e) {
      // ignore errors silently or log if needed
    }
  }

  void toggleShowTodoImage() {
    final newConfig = appCtrl.appConfig.value.copyWith(
      showTodoImage: !appCtrl.appConfig.value.showTodoImage,
    );
    appCtrl.appConfig.value = newConfig;
    appCtrl.appConfig.refresh();
    // AppController 的 ever 监听器会自动保存配置
  }

  void resetConfig() {
    appCtrl.appConfig.value = defaultAppConfig.copyWith();
    changeLanguage(defaultAppConfig.locale);
  }

  void resetTasksTemplate() {
    homeCtrl.resetTasksTemplate();
  }

  /// 检查更新（仅桌面端）
  Future<void> checkForUpdates() async {
    if (!GetPlatform.isDesktop) {
      return;
    }

    // 如果正在下载，不允许再次检查更新
    if (isDownloading.value) {
      _logger.w('正在下载更新，无法再次检查');
      return;
    }

    // 检查是否为 Windows、macOS 或 Linux
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      try {
        // 设置更新进度监听
        _setupUpdateProgressListeners();

        // 开始检查更新
        await appCtrl.checkForUpdates(silent: false);
      } catch (e) {
        _logger.e('检查更新失败: $e');
        updateProgress.value = -1.0;
        updateStatus.value = 'updateError'.tr;
        showToast('updateError'.tr);
      }
    }
  }

  /// 取消更新下载
  Future<void> cancelUpdate() async {
    if (!isDownloading.value) {
      return;
    }

    try {
      _logger.i('用户取消更新下载');

      // 重置状态
      isDownloading.value = false;
      updateProgress.value = 0.0;
      updateStatus.value = '';

      // 取消下载
      appCtrl.autoUpdateService.cancelDownload();

      showToast(
        'updateCancelled'.tr,
        toastStyleType: TodoCatToastStyleType.info,
        position: TodoCatToastPosition.bottomLeft,
      );
    } catch (e) {
      _logger.e('取消更新失败: $e');
    }
  }

  /// 设置更新进度监听
  void _setupUpdateProgressListeners() {
    final updateService = appCtrl.autoUpdateService;

    // 重置状态
    updateProgress.value = 0.0;
    updateStatus.value = 'checkingForUpdates'.tr;

    // 设置进度回调
    updateService.onProgress = (progress, status) {
      updateProgress.value = progress;
      updateStatus.value = status;
      _logger.d('更新进度: $progress, 状态: $status');
    };

    updateService.onUpdateAvailable = (version, changelog) {
      // 发现新版本，通知已通过 _notifyUpdateAvailable 发送到通知中心
      _logger.i('发现新版本: $version');
      updateProgress.value = 1.0;
      updateStatus.value = '${'newVersionAvailable'.tr}: $version';

      // 显示更新方式选择对话框
      _showUpdateMethodDialog(version);
    };

    updateService.onUpdateComplete = () {
      // 重置下载状态
      isDownloading.value = false;

      _logger.i('更新完成');
      updateProgress.value = 1.0;
      updateStatus.value = 'updateComplete'.tr;
      showToast('updateComplete'.tr,
          toastStyleType: TodoCatToastStyleType.success);

      // 3秒后重置状态
      Future.delayed(const Duration(seconds: 3), () {
        if (updateProgress.value == 1.0) {
          updateProgress.value = 0.0;
          updateStatus.value = '';
        }
      });
    };

    updateService.onUpdateError = (error) {
      // 重置下载状态
      isDownloading.value = false;

      _logger.e('更新错误: $error');
      updateProgress.value = -1.0;
      updateStatus.value = 'updateError'.tr;
      showToast('updateError'.tr, toastStyleType: TodoCatToastStyleType.error);

      // 3秒后重置状态
      Future.delayed(const Duration(seconds: 3), () {
        if (updateProgress.value == -1.0) {
          updateProgress.value = 0.0;
          updateStatus.value = '';
        }
      });
    };

    // 监听已是最新版本的回调
    updateService.onAlreadyLatestVersion = () {
      _logger.i('已是最新版本');
      updateProgress.value = 1.0;
      updateStatus.value = 'alreadyLatestVersion'.tr;
      showToast('alreadyLatestVersion'.tr,
          toastStyleType: TodoCatToastStyleType.success);

      // 3秒后重置状态
      Future.delayed(const Duration(seconds: 3), () {
        if (updateProgress.value == 1.0) {
          updateProgress.value = 0.0;
          updateStatus.value = '';
        }
      });
    };
  }

  /// 显示更新方式选择对话框
  void _showUpdateMethodDialog(String version) {
    SmartDialog.show(
      tag: 'update_method_dialog',
      alignment: Alignment.center,
      maskColor: Colors.black.withValues(alpha: 0.5),
      clickMaskDismiss: true,
      useAnimation: true,
      animationTime: const Duration(milliseconds: 300),
      builder: (context) => Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.theme.dialogTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              'selectUpdateMethod'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'selectUpdateMethodDesc'.tr,
              style: TextStyle(
                fontSize: 14,
                color: context.theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),
            // 直接下载更新选项
            _buildUpdateMethodOption(
              context: context,
              title: 'updateViaDownload'.tr,
              description: 'updateViaDownloadDesc'.tr,
              icon: Icons.download,
              iconColor: Colors.blueAccent,
              onTap: () {
                SmartDialog.dismiss(tag: 'update_method_dialog');
                // 更新状态为"更新新版本中"，显示下载进度
                isDownloading.value = true;
                updateProgress.value = 0.1;
                updateStatus.value = 'downloadingUpdate'.tr;
                _logger.i('用户选择直接下载更新: $version');
                _triggerDesktopUpdaterDownload();
              },
            ),
            const SizedBox(height: 16),
            // 通过微软商店更新选项
            if (Platform.isWindows)
              _buildUpdateMethodOption(
                context: context,
                title: 'updateViaStore'.tr,
                description: 'updateViaStoreDesc'.tr,
                icon: Icons.store,
                iconColor: Colors.greenAccent,
                onTap: () async {
                  SmartDialog.dismiss(tag: 'update_method_dialog');
                  _logger.i('用户选择通过微软商店更新: $version');
                  final success =
                      await appCtrl.autoUpdateService.openMicrosoftStore();
                  if (success) {
                    showToast(
                      'openMicrosoftStore'.tr,
                      toastStyleType: TodoCatToastStyleType.success,
                      position: TodoCatToastPosition.bottomLeft,
                    );
                    // 重置状态
                    updateProgress.value = 0.0;
                    updateStatus.value = '';
                  } else {
                    showToast(
                      'failedToOpenStore'.tr,
                      toastStyleType: TodoCatToastStyleType.error,
                      position: TodoCatToastPosition.bottomLeft,
                    );
                  }
                },
              ),
            const SizedBox(height: 24),
            // 取消按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LabelBtn(
                  label: Text('cancel'.tr),
                  ghostStyle: true,
                  onPressed: () {
                    SmartDialog.dismiss(tag: 'update_method_dialog');
                    updateProgress.value = 0.0;
                    updateStatus.value = '';
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      animationBuilder: (controller, child, animationParam) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: controller,
            child: child,
          ),
        );
      },
    );
  }

  /// 构建更新方式选项
  Widget _buildUpdateMethodOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    // 如果没有指定颜色，根据图标类型选择颜色
    final Color finalIconColor = iconColor ??
        (icon == Icons.download ? Colors.blueAccent : Colors.greenAccent);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.theme.dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: finalIconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: finalIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 触发下载和安装更新
  Future<void> _triggerDesktopUpdaterDownload() async {
    try {
      // 设置下载进度监听
      final updateService = appCtrl.autoUpdateService;
      updateService.onProgress = (progress, status) {
        updateProgress.value = progress;
        updateStatus.value =
            status.isNotEmpty ? status : 'downloadingUpdate'.tr;
        _logger.d('更新进度: $progress, 状态: $status');
      };

      // 下载并安装更新
      await appCtrl.autoUpdateService.downloadAndInstallUpdate();
    } catch (e) {
      _logger.e('下载或安装更新失败: $e');
      updateProgress.value = -1.0;
      updateStatus.value = 'updateError'.tr;
      showToast(
        'updateError'.tr,
        toastStyleType: TodoCatToastStyleType.error,
      );
    }
  }

  /// 选择背景图片或视频
  Future<void> selectBackgroundImage() async {
    try {
      // 移动端只允许选择图片，桌面端可以选择图片或视频
      final allowedExtensions = GetPlatform.isMobile
          ? ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
          : ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'mp4', 'mov', 'avi', 'mkv', 'webm'];
      
      // 选择图片或视频文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // 移动端检查：如果选择了视频文件，拒绝并提示
          if (GetPlatform.isMobile) {
            final isVideo = file.path!.toLowerCase().endsWith('.mp4') ||
                           file.path!.toLowerCase().endsWith('.mov') ||
                           file.path!.toLowerCase().endsWith('.avi') ||
                           file.path!.toLowerCase().endsWith('.mkv') ||
                           file.path!.toLowerCase().endsWith('.webm');
            if (isVideo) {
              showToast('移动端不支持视频背景', toastStyleType: TodoCatToastStyleType.error);
              _logger.w('移动端尝试设置视频背景，已拒绝: ${file.path}');
              return;
            }
          }
          
          // 直接使用选择的图片或视频（桌面端暂不支持裁剪）
          // 更新应用配置
          appCtrl.appConfig.value = appCtrl.appConfig.value.copyWith(
            backgroundImagePath: file.path,
          );
          appCtrl.appConfig.refresh();

          // 检查是否为视频文件
          final isVideo = file.path!.toLowerCase().endsWith('.mp4') ||
                         file.path!.toLowerCase().endsWith('.mov') ||
                         file.path!.toLowerCase().endsWith('.avi') ||
                         file.path!.toLowerCase().endsWith('.mkv') ||
                         file.path!.toLowerCase().endsWith('.webm');
          
          if (isVideo) {
            showToast('backgroundVideoSetSuccess'.tr);
            _logger.i('背景视频已设置: ${file.path}');
          } else {
            showToast('backgroundImageSetSuccess'.tr);
            _logger.i('背景图片已设置: ${file.path}');
          }
        }
      }
    } catch (e) {
      _logger.e('选择背景文件失败: $e');
      showToast('selectBackgroundImageFailed'.tr);
    }
  }

  /// 选择默认背景模板
  Future<void> selectDefaultBackground(String templateId) async {
    try {
      // 移动端检查：如果选择的是视频模板，拒绝并提示
      if (GetPlatform.isMobile) {
        final template = DefaultBackgrounds.getById(templateId);
        if (template != null && template.isVideo) {
          showToast('移动端不支持视频背景', toastStyleType: TodoCatToastStyleType.error);
          _logger.w('移动端尝试应用视频背景模板，已拒绝: $templateId');
          return;
        }
      }
      
      // 使用特殊标记来表示这是默认模板
      // 格式: default_template:{templateId}
      final templatePath = 'default_template:$templateId';

      appCtrl.appConfig.value = appCtrl.appConfig.value.copyWith(
        backgroundImagePath: templatePath,
      );
      appCtrl.appConfig.refresh();

      showToast('backgroundTemplateApplied'.tr);
      _logger.i('应用默认背景模板: $templateId');
    } catch (e) {
      _logger.e('应用默认背景模板失败: $e');
      showToast('applyDefaultTemplateFailed'.tr);
    }
  }

  /// 清除背景图片
  Future<void> clearBackgroundImage() async {
    try {
      // 直接设置backgroundImagePath为null，因为copyWith方法无法正确处理null值
      final currentConfig = appCtrl.appConfig.value;
      currentConfig.backgroundImagePath = null; // 清除背景图片路径

      // 触发更新，这会自动保存到数据库
      appCtrl.appConfig.refresh();

      showToast('backgroundImageCleared'.tr);
      _logger.i('背景图片已清除');
    } catch (e) {
      _logger.e('清除背景图片设置失败: $e');
      showToast('backgroundImageClearFailed'.tr);
    }
  }

  /// 清除所有应用数据
  Future<bool> clearAllData() async {
    try {
      _logger.w('开始清除所有应用数据...');

      // 1. 重置数据库（删除数据库文件并重新创建，清除所有残留数据）
      final db = await Database.getInstance();
      await db.resetDatabase();
      
      // 确保数据库已重新初始化（重新获取实例）
      await Database.getInstance();

      // 2. 强制重新初始化所有 Repository
      // 这很重要，因为 resetDatabase() 会重置所有 Repository，需要重新获取实例
      // 等待一小段时间，确保数据库连接已完全建立
      await Future.delayed(const Duration(milliseconds: 200));
      
      try {
        // 重新初始化所有 Repository 实例
        await WorkspaceRepository.getInstance();
        await TaskRepository.getInstance();
        await AppConfigRepository.getInstance();
        _logger.d('所有 Repository 已重新初始化');
      } catch (e) {
        _logger.e('重新初始化 Repository 失败: $e');
        // 即使失败也继续，因为 Controller 会在使用时重新获取
      }

      // 3. 重置应用配置为默认值
      appCtrl.appConfig.value = defaultAppConfig.copyWith();
      appCtrl.appConfig.refresh();

      // 4. 重新初始化工作空间（会创建默认工作空间）
      try {
        if (Get.isRegistered<WorkspaceController>()) {
          final workspaceCtrl = Get.find<WorkspaceController>();
          // 重新加载工作空间（会触发创建默认工作空间）
          await workspaceCtrl.loadWorkspaces();
          // 如果没有工作空间，创建默认工作空间
          if (workspaceCtrl.workspaces.isEmpty) {
            await workspaceCtrl.createDefaultWorkspace();
          }
          // 确保当前工作空间是默认工作空间
          workspaceCtrl.currentWorkspaceId.value = 'default';
        }
      } catch (e) {
        _logger.e('重新初始化工作空间失败: $e');
      }

      // 5. 刷新回收站数据（清空回收站显示）
      try {
        if (Get.isRegistered<TrashController>()) {
          final trashCtrl = Get.find<TrashController>();
          await trashCtrl.refresh();
        }
      } catch (e) {
        _logger.e('刷新回收站数据失败: $e');
      }

      // 6. 清空主页任务列表（确保不显示旧数据）
      try {
        // 先清空内存中的任务列表
        homeCtrl.tasks.clear();
        homeCtrl.reactiveTasks.refresh();
        
        // 验证数据库是否真的被清空（检查任务数量）
        final taskRepo = await TaskRepository.getInstance();
        final allTasks = await taskRepo.readAll();
        if (allTasks.isNotEmpty) {
          _logger.w('数据库重置后仍有 ${allTasks.length} 个任务，强制清除...');
          // 如果还有任务，强制清除
          for (var task in allTasks) {
            await taskRepo.permanentDelete(task.uuid);
          }
        }
        
        // 然后刷新数据（不显示空任务提示，因为这是清除操作）
        await homeCtrl.refreshData(showEmptyPrompt: false, clearBeforeRefresh: true);
        
        // 再次验证任务列表是否为空
        if (homeCtrl.tasks.isNotEmpty) {
          _logger.w('刷新后仍有 ${homeCtrl.tasks.length} 个任务，强制清空...');
          homeCtrl.tasks.clear();
          homeCtrl.reactiveTasks.refresh();
        }
      } catch (e) {
        _logger.e('刷新主页数据失败: $e');
      }

      _logger.i('所有应用数据已清除并重新初始化');
      return true;
    } catch (e) {
      _logger.e('清除所有数据失败: $e');
      return false;
    }
  }
}
