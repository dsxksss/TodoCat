import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:TodoCat/config/default_data.dart';
import 'package:TodoCat/controllers/app_ctr.dart';
import 'package:TodoCat/controllers/home_ctr.dart';
import 'package:TodoCat/data/services/database.dart';
import 'package:TodoCat/keys/dialog_keys.dart';
import 'package:TodoCat/pages/settings/settings_page.dart';
import 'package:TodoCat/widgets/dpd_menu_btn.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:TodoCat/widgets/show_toast.dart';
import 'package:TodoCat/services/auto_update_service.dart';
import 'package:logger/logger.dart';

class SettingsController extends GetxController {
  static final _logger = Logger();
  final AppController appCtrl = Get.find();
  final HomeController homeCtrl = Get.find();
  late final Rx<String> currentLanguage;
  var isAnimating = false.obs;
  // 开机自启动状态（仅桌面端）
  final RxBool launchAtStartupEnabled = false.obs;
  // 当前应用版本号
  final RxString appVersion = 'Loading...'.obs;
  // 更新检查状态
  final RxDouble updateProgress = 0.0.obs; // 0.0 = 未开始, 0.0-1.0 = 进行中, 1.0 = 完成, -1.0 = 错误
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
      
      // 显示确认对话框，让用户选择是否下载
      // toast 不显示更新内容，只显示版本号
      showToast(
        '${'newVersionAvailable'.tr}: $version',
        confirmMode: true,
        alwaysShow: true,
        toastStyleType: TodoCatToastStyleType.info,
        tag: 'update_confirm_toast',
        onYesCallback: () {
          // 用户确认下载，关闭确认 toast
          SmartDialog.dismiss(tag: 'update_confirm_toast');
          
          // 更新状态为"更新新版本中"，显示下载进度
          isDownloading.value = true; // 标记为正在下载
          updateProgress.value = 0.1; // 初始进度
          updateStatus.value = 'downloadingUpdate'.tr;
          
          // 触发 desktop_updater 的下载流程
          _logger.i('用户确认下载更新: $version');
          _triggerDesktopUpdaterDownload();
        },
        onNoCallback: () {
          // 用户取消下载，关闭确认 toast
          SmartDialog.dismiss(tag: 'update_confirm_toast');
          
          _logger.i('用户取消下载更新');
          updateProgress.value = 0.0;
          updateStatus.value = '';
        },
      );
    };
    
    updateService.onUpdateComplete = () {
      // 重置下载状态
      isDownloading.value = false;
      
      _logger.i('更新完成');
      updateProgress.value = 1.0;
      updateStatus.value = 'updateComplete'.tr;
      showToast('updateComplete'.tr, toastStyleType: TodoCatToastStyleType.success);
      
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
      showToast('alreadyLatestVersion'.tr, toastStyleType: TodoCatToastStyleType.success);
      
      // 3秒后重置状态
      Future.delayed(const Duration(seconds: 3), () {
        if (updateProgress.value == 1.0) {
          updateProgress.value = 0.0;
          updateStatus.value = '';
        }
      });
    };
  }

  /// 触发下载和安装更新
  Future<void> _triggerDesktopUpdaterDownload() async {
    try {
      // 设置下载进度监听
      final updateService = appCtrl.autoUpdateService;
      updateService.onProgress = (progress, status) {
        updateProgress.value = progress;
        updateStatus.value = status.isNotEmpty ? status : 'downloadingUpdate'.tr;
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

  /// 选择背景图片
  Future<void> selectBackgroundImage() async {
    try {
      // 先选择图片文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // 直接使用选择的图片（桌面端暂不支持裁剪）
          // 更新应用配置
          appCtrl.appConfig.value = appCtrl.appConfig.value.copyWith(
            backgroundImagePath: file.path,
          );
          appCtrl.appConfig.refresh();
          
          showToast('backgroundImageSetSuccess'.tr);
          _logger.i('背景图片已设置: ${file.path}');
        }
      }
    } catch (e) {
      _logger.e('选择背景图片失败: $e');
      showToast('selectBackgroundImageFailed'.tr);
    }
  }

  /// 选择默认背景模板
  Future<void> selectDefaultBackground(String templateId) async {
    try {
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
      currentConfig.backgroundImagePath = null;  // 清除背景图片路径
      
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
      
      // 1. 清除数据库中的所有数据
      final db = await Database.getInstance();
      await db.clearAllData();
      
      // 2. 重置应用配置为默认值
      appCtrl.appConfig.value = defaultAppConfig.copyWith();
      appCtrl.appConfig.refresh();
      
      // 3. 刷新主页数据
      try {
        await homeCtrl.refreshData();
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
