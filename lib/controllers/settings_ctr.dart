import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';
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
import 'package:todo_cat/routers/app_router.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/widgets/label_btn.dart';
import 'package:todo_cat/services/auto_update_service.dart';
import 'package:todo_cat/config/default_backgrounds.dart';
import 'package:todo_cat/services/sync_manager.dart';
import 'package:logger/logger.dart';

import 'package:todo_cat/core/utils/l10n.dart';
import 'package:todo_cat/core/utils/platform.dart';
import 'package:todo_cat/core/utils/responsive.dart';

part 'settings_ctr.g.dart';

/// 设置页状态（原 SettingsController 的各 `.obs` 字段合并为不可变 state）。
@immutable
class SettingsState {
  /// 当前语言显示名（"English" / "中文"）。
  final String currentLanguage;

  /// 主题切换动画进行中。
  final bool isAnimating;

  /// 开机自启动状态（仅桌面端）。
  final bool launchAtStartupEnabled;

  /// 显示 Todo 图片封面状态。
  final bool showTodoImageEnabled;

  /// 当前应用版本号。
  final String appVersion;

  /// 更新进度：0.0 = 未开始, 0.0-1.0 = 进行中, 1.0 = 完成, -1.0 = 错误。
  final double updateProgress;

  /// 更新状态文本。
  final String updateStatus;

  /// 是否正在下载更新。
  final bool isDownloading;

  const SettingsState({
    this.currentLanguage = 'unknown',
    this.isAnimating = false,
    this.launchAtStartupEnabled = false,
    this.showTodoImageEnabled = false,
    this.appVersion = 'Loading...',
    this.updateProgress = 0.0,
    this.updateStatus = '',
    this.isDownloading = false,
  });

  SettingsState copyWith({
    String? currentLanguage,
    bool? isAnimating,
    bool? launchAtStartupEnabled,
    bool? showTodoImageEnabled,
    String? appVersion,
    double? updateProgress,
    String? updateStatus,
    bool? isDownloading,
  }) {
    return SettingsState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isAnimating: isAnimating ?? this.isAnimating,
      launchAtStartupEnabled:
          launchAtStartupEnabled ?? this.launchAtStartupEnabled,
      showTodoImageEnabled: showTodoImageEnabled ?? this.showTodoImageEnabled,
      appVersion: appVersion ?? this.appVersion,
      updateProgress: updateProgress ?? this.updateProgress,
      updateStatus: updateStatus ?? this.updateStatus,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}

/// 设置控制器（原 GetxController -> Riverpod Notifier，常驻）。
@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  static final _logger = Logger();

  @override
  SettingsState build() {
    final config = ref.read(appControllerProvider);

    // 监听配置变化：同步 showTodoImage 与当前语言显示名
    // （替代原 `ever(appCtrl.appConfig, ...)` 两个 worker）。
    ref.listen(appControllerProvider, (previous, next) {
      state = state.copyWith(
        showTodoImageEnabled: next.showTodoImage,
        currentLanguage: _getLanguageTitle(next.locale.languageCode),
      );
    });

    // 初始化自启动状态（桌面端）
    if (AppPlatform.isDesktop) {
      _refreshLaunchAtStartupState();
    }

    // 加载应用版本号
    _loadAppVersion();

    // 下载中途销毁时取消下载（替代原 onClose）。
    ref.onDispose(() {
      if (state.isDownloading) {
        ref.read(appControllerProvider.notifier).autoUpdateService
            .cancelDownload();
      }
    });

    return SettingsState(
      showTodoImageEnabled: config.showTodoImage,
      currentLanguage: _getLanguageTitle(config.locale.languageCode),
    );
  }

  /// 加载应用版本号
  Future<void> _loadAppVersion() async {
    try {
      final version = await AutoUpdateService.getCurrentVersion();
      state = state.copyWith(appVersion: version ?? 'Unknown');
    } catch (e) {
      _logger.e('获取版本号失败: $e');
      state = state.copyWith(appVersion: 'Unknown');
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
    final context = rootNavigatorKey.currentContext!;
    if (context.isPhone) {
      SmartDialog.show(
        tag: 'settings',
        alignment: Alignment.bottomCenter,
        maskColor: Colors.black38,
        clickMaskDismiss: true,
        useAnimation: true,
        animationTime: const Duration(milliseconds: 200),
        builder: (_) => Container(
          width: context.width,
          height: context.height * 0.6,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
          ),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: context.theme.dialogTheme.backgroundColor,
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
      // 使用自定义遮罩以支持窗口拖拽
      SmartDialog.show(
        tag: 'settings',
        alignment: Alignment.center, // 改为 center 以便 Stack 占满全屏
        builder: (_) => const SettingsPage(),
        maskColor: Colors.transparent, // 禁用默认遮罩
        clickMaskDismiss: false, // 禁用默认点击遮罩关闭（在自定义遮罩中处理）
        animationBuilder: (controller, child, animationParam) {
          return Stack(
            children: [
              // 自定义遮罩层
              Positioned.fill(
                child: GestureDetector(
                  // 点击遮罩关闭
                  onTap: () => SmartDialog.dismiss(tag: 'settings'),
                  // 拖拽遮罩移动窗口
                  onPanStart: (_) {
                    if (AppPlatform.isDesktop) {
                      windowManager.startDragging();
                    }
                  },
                  child: FadeTransition(
                    opacity: controller,
                    child: Container(
                      color: Colors.black38,
                    ),
                  ),
                ),
              ),
              // 内容区域
              Align(
                alignment: Alignment.centerRight,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void showLanguageMenu(BuildContext context) {
    final currentLocale =
        ref.read(appControllerProvider).locale.languageCode;

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
    // 更新系统语言并写入配置（替代 GetX 的 Get.updateLocale + appConfig 刷新）。
    await ref.read(appControllerProvider.notifier).changeLanguage(local);

    // 关闭语言选择菜单
    SmartDialog.dismiss(tag: settingsDropDownMenuBtnTag);
  }

  void targetEmailReminder() {
    final appConfig = ref.read(appControllerProvider);
    ref.read(appControllerProvider.notifier).updateConfig(
          appConfig.copyWith(
            emailReminderEnabled: !appConfig.emailReminderEnabled,
          ),
        );
  }

  // 以下为开机自启动相关逻辑（桌面端）
  Future<void> _refreshLaunchAtStartupState() async {
    // 注意：必须先 await 再读 state——若在 build() 返回初始 state 之前同步读取
    // state（如 `state.copyWith(... await ...)` 中 state 作为接收者会先被求值），
    // 会抛 "Tried to read the state of an uninitialized provider"。
    try {
      final enabled = await launchAtStartup.isEnabled();
      state = state.copyWith(launchAtStartupEnabled: enabled);
    } catch (_) {
      state = state.copyWith(launchAtStartupEnabled: false);
    }
  }

  Future<void> toggleLaunchAtStartup() async {
    if (!AppPlatform.isDesktop) return;
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
    final appConfig = ref.read(appControllerProvider);
    ref.read(appControllerProvider.notifier).updateConfig(
          appConfig.copyWith(
            showTodoImage: !appConfig.showTodoImage,
          ),
        );
    // AppController 会自动保存配置；showTodoImageEnabled 由 build 内的 listen 同步
  }

  void resetConfig() {
    ref.read(appControllerProvider.notifier).updateConfig(
          defaultAppConfig.copyWith(),
        );
    changeLanguage(defaultAppConfig.locale);
  }

  void resetTasksTemplate() {
    ref.read(homeControllerProvider.notifier).resetTasksTemplate();
  }

  /// 检查更新（仅桌面端）
  Future<void> checkForUpdates() async {
    if (!AppPlatform.isDesktop) {
      return;
    }

    // 如果正在下载，不允许再次检查更新
    if (state.isDownloading) {
      _logger.w('正在下载更新，无法再次检查');
      return;
    }

    // 检查是否为 Windows、macOS 或 Linux
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      try {
        // 设置更新进度监听
        _setupUpdateProgressListeners();

        // 开始检查更新
        await ref
            .read(appControllerProvider.notifier)
            .checkForUpdates(silent: false);
      } catch (e) {
        _logger.e('检查更新失败: $e');
        state = state.copyWith(
            updateProgress: -1.0, updateStatus: l10n.updateError);
        showToast(l10n.updateError);
      }
    }
  }

  /// 取消更新下载
  Future<void> cancelUpdate() async {
    if (!state.isDownloading) {
      return;
    }

    try {
      _logger.i('用户取消更新下载');

      // 重置状态
      state = state.copyWith(
        isDownloading: false,
        updateProgress: 0.0,
        updateStatus: '',
      );

      // 取消下载
      ref.read(appControllerProvider.notifier).autoUpdateService
          .cancelDownload();

      showToast(
        l10n.updateCancelled,
        toastStyleType: TodoCatToastStyleType.info,
        position: TodoCatToastPosition.bottomLeft,
      );
    } catch (e) {
      _logger.e('取消更新失败: $e');
    }
  }

  /// 设置更新进度监听
  void _setupUpdateProgressListeners() {
    final updateService =
        ref.read(appControllerProvider.notifier).autoUpdateService;

    // 重置状态
    state = state.copyWith(
        updateProgress: 0.0, updateStatus: l10n.checkingForUpdates);

    // 设置进度回调
    updateService.onProgress = (progress, status) {
      state =
          state.copyWith(updateProgress: progress, updateStatus: status);
      _logger.d('更新进度: $progress, 状态: $status');
    };

    updateService.onUpdateAvailable = (version, changelog) {
      // 发现新版本，通知已通过 _notifyUpdateAvailable 发送到通知中心
      _logger.i('发现新版本: $version');
      state = state.copyWith(
        updateProgress: 1.0,
        updateStatus: '${l10n.newVersionAvailable}: $version',
      );

      // 显示更新方式选择对话框
      _showUpdateMethodDialog(version);
    };

    updateService.onUpdateComplete = () {
      // 重置下载状态
      _logger.i('更新完成');
      state = state.copyWith(
        isDownloading: false,
        updateProgress: 1.0,
        updateStatus: l10n.updateComplete,
      );
      showToast(l10n.updateComplete,
          toastStyleType: TodoCatToastStyleType.success);

      // 3秒后重置状态
      Future.delayed(const Duration(seconds: 3), () {
        if (state.updateProgress == 1.0) {
          state = state.copyWith(updateProgress: 0.0, updateStatus: '');
        }
      });
    };

    updateService.onUpdateError = (error) {
      // 重置下载状态
      _logger.e('更新错误: $error');
      state = state.copyWith(
        isDownloading: false,
        updateProgress: -1.0,
        updateStatus: l10n.updateError,
      );
      showToast(l10n.updateError, toastStyleType: TodoCatToastStyleType.error);

      // 3秒后重置状态
      Future.delayed(const Duration(seconds: 3), () {
        if (state.updateProgress == -1.0) {
          state = state.copyWith(updateProgress: 0.0, updateStatus: '');
        }
      });
    };

    // 监听已是最新版本的回调
    updateService.onAlreadyLatestVersion = () {
      _logger.i('已是最新版本');
      state = state.copyWith(
        updateProgress: 1.0,
        updateStatus: l10n.alreadyLatestVersion,
      );
      showToast(l10n.alreadyLatestVersion,
          toastStyleType: TodoCatToastStyleType.success);

      // 3秒后重置状态
      Future.delayed(const Duration(seconds: 3), () {
        if (state.updateProgress == 1.0) {
          state = state.copyWith(updateProgress: 0.0, updateStatus: '');
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
              l10n.selectUpdateMethod,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectUpdateMethodDesc,
              style: TextStyle(
                fontSize: 14,
                color: context.theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),
            // 直接下载更新选项
            _buildUpdateMethodOption(
              context: context,
              title: l10n.updateViaDownload,
              description: l10n.updateViaDownloadDesc,
              icon: Icons.download,
              iconColor: Colors.blueAccent,
              onTap: () {
                SmartDialog.dismiss(tag: 'update_method_dialog');
                // 更新状态为"更新新版本中"，显示下载进度
                state = state.copyWith(
                  isDownloading: true,
                  updateProgress: 0.1,
                  updateStatus: l10n.downloadingUpdate,
                );
                _logger.i('用户选择直接下载更新: $version');
                _triggerDesktopUpdaterDownload();
              },
            ),
            const SizedBox(height: 16),
            // 通过微软商店更新选项
            if (Platform.isWindows)
              _buildUpdateMethodOption(
                context: context,
                title: l10n.updateViaStore,
                description: l10n.updateViaStoreDesc,
                icon: Icons.store,
                iconColor: Colors.greenAccent,
                onTap: () async {
                  SmartDialog.dismiss(tag: 'update_method_dialog');
                  _logger.i('用户选择通过微软商店更新: $version');
                  final success = await ref
                      .read(appControllerProvider.notifier)
                      .autoUpdateService
                      .openMicrosoftStore();
                  if (success) {
                    showToast(
                      l10n.openMicrosoftStore,
                      toastStyleType: TodoCatToastStyleType.success,
                      position: TodoCatToastPosition.bottomLeft,
                    );
                    // 重置状态
                    state =
                        state.copyWith(updateProgress: 0.0, updateStatus: '');
                  } else {
                    showToast(
                      l10n.failedToOpenStore,
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
                  label: Text(l10n.cancel),
                  ghostStyle: true,
                  onPressed: () {
                    SmartDialog.dismiss(tag: 'update_method_dialog');
                    state =
                        state.copyWith(updateProgress: 0.0, updateStatus: '');
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
      final updateService =
          ref.read(appControllerProvider.notifier).autoUpdateService;
      updateService.onProgress = (progress, status) {
        state = state.copyWith(
          updateProgress: progress,
          updateStatus: status.isNotEmpty ? status : l10n.downloadingUpdate,
        );
        _logger.d('更新进度: $progress, 状态: $status');
      };

      // 下载并安装更新
      await ref
          .read(appControllerProvider.notifier)
          .autoUpdateService
          .downloadAndInstallUpdate();
    } catch (e) {
      _logger.e('下载或安装更新失败: $e');
      state =
          state.copyWith(updateProgress: -1.0, updateStatus: l10n.updateError);
      showToast(
        l10n.updateError,
        toastStyleType: TodoCatToastStyleType.error,
      );
    }
  }

  /// 选择背景图片或视频
  Future<void> selectBackgroundImage() async {
    try {
      // 移动端只允许选择图片，桌面端可以选择图片或视频
      final allowedExtensions = AppPlatform.isMobile
          ? ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
          : [
              'jpg',
              'jpeg',
              'png',
              'gif',
              'bmp',
              'webp',
              'mp4',
              'mov',
              'avi',
              'mkv',
              'webm'
            ];

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
          if (AppPlatform.isMobile) {
            final isVideo = file.path!.toLowerCase().endsWith('.mp4') ||
                file.path!.toLowerCase().endsWith('.mov') ||
                file.path!.toLowerCase().endsWith('.avi') ||
                file.path!.toLowerCase().endsWith('.mkv') ||
                file.path!.toLowerCase().endsWith('.webm');
            if (isVideo) {
              showToast('移动端不支持视频背景',
                  toastStyleType: TodoCatToastStyleType.error);
              _logger.w('移动端尝试设置视频背景，已拒绝: ${file.path}');
              return;
            }
          }

          // 直接使用选择的图片或视频（桌面端暂不支持裁剪）
          // 更新应用配置
          final appConfig = ref.read(appControllerProvider);
          await ref.read(appControllerProvider.notifier).updateConfig(
                appConfig.copyWith(backgroundImagePath: file.path),
              );

          // 检查是否为视频文件
          final isVideo = file.path!.toLowerCase().endsWith('.mp4') ||
              file.path!.toLowerCase().endsWith('.mov') ||
              file.path!.toLowerCase().endsWith('.avi') ||
              file.path!.toLowerCase().endsWith('.mkv') ||
              file.path!.toLowerCase().endsWith('.webm');

          if (isVideo) {
            showToast(l10n.backgroundVideoSetSuccess);
            _logger.i('背景视频已设置: ${file.path}');
          } else {
            showToast(l10n.backgroundImageSetSuccess);
            _logger.i('背景图片已设置: ${file.path}');
          }
        }
      }
    } catch (e) {
      _logger.e('选择背景文件失败: $e');
      showToast(l10n.selectBackgroundImageFailed);
    }
  }

  /// 选择默认背景模板
  Future<void> selectDefaultBackground(String templateId) async {
    try {
      // 移动端检查：如果选择的是视频模板，拒绝并提示
      if (AppPlatform.isMobile) {
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

      final appConfig = ref.read(appControllerProvider);
      await ref.read(appControllerProvider.notifier).updateConfig(
            appConfig.copyWith(backgroundImagePath: templatePath),
          );

      showToast(l10n.backgroundTemplateApplied);
      _logger.i('应用默认背景模板: $templateId');
    } catch (e) {
      _logger.e('应用默认背景模板失败: $e');
      showToast(l10n.applyDefaultTemplateFailed);
    }
  }

  /// 清除背景图片
  Future<void> clearBackgroundImage() async {
    try {
      // 用 copyWith 的 clearBackgroundImagePath 生成一个**新实例**（背景置 null）。
      // 之前是就地把当前 state 对象的字段改成 null 再 updateConfig，由于传回的是同一个
      // 实例，Riverpod 的 updateShouldNotify 判定 identical 不刷新，导致背景看起来没清除
      // （要重启才生效）。
      final currentConfig = ref.read(appControllerProvider);
      await ref.read(appControllerProvider.notifier).updateConfig(
            currentConfig.copyWith(clearBackgroundImagePath: true),
          );

      showToast(l10n.backgroundImageCleared);
      _logger.i('背景图片已清除');
    } catch (e) {
      _logger.e('清除背景图片设置失败: $e');
      showToast(l10n.backgroundImageClearFailed);
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
      await ref.read(appControllerProvider.notifier).updateConfig(
            defaultAppConfig.copyWith(),
          );

      // 4. 清除同步配置和状态
      await SyncManager().clearConfig();
      await SyncManager().clearSyncStatus();

      // 5. 重新初始化工作空间（会创建默认工作空间）
      try {
        final workspaceCtrl = ref.read(workspaceControllerProvider.notifier);
        // 重新加载工作空间（会触发创建默认工作空间）
        await workspaceCtrl.loadWorkspaces();
        // 如果没有工作空间，创建默认工作空间
        if (ref.read(workspaceControllerProvider).workspaces.isEmpty) {
          await workspaceCtrl.createDefaultWorkspace();
        }
        // 确保当前工作空间是默认工作空间
        await workspaceCtrl.switchWorkspace('default');
      } catch (e) {
        _logger.e('重新初始化工作空间失败: $e');
      }

      // 5. 刷新回收站数据（清空回收站显示）
      try {
        await ref.read(trashControllerProvider.notifier).refresh();
      } catch (e) {
        _logger.e('刷新回收站数据失败: $e');
      }

      // 6. 清空主页任务列表（确保不显示旧数据）
      try {
        final homeCtrl = ref.read(homeControllerProvider.notifier);

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
        // refreshData(clearBeforeRefresh: true) 会先清空内存任务再从数据库重读，
        // 替代原 GetX 的 tasks.clear() + reactiveTasks.refresh()。
        await homeCtrl.refreshData(
            showEmptyPrompt: false, clearBeforeRefresh: true);

        // 再次验证任务列表是否为空
        if (homeCtrl.tasks.isNotEmpty) {
          _logger.w('刷新后仍有 ${homeCtrl.tasks.length} 个任务，强制清空...');
          await homeCtrl.refreshData(
              showEmptyPrompt: false, clearBeforeRefresh: true);
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
