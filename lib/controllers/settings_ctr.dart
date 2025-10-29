import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/controllers/app_ctr.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/pages/settings/settings_page.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:logger/logger.dart';

class SettingsController extends GetxController {
  static final _logger = Logger();
  final AppController appCtrl = Get.find();
  final HomeController homeCtrl = Get.find();
  late final Rx<String> currentLanguage;
  var isAnimating = false.obs;
  // 开机自启动状态（仅桌面端）
  final RxBool launchAtStartupEnabled = false.obs;

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
            color: Get.theme.dialogBackgroundColor,
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
    
    // 检查是否为 Windows 或 macOS
    if (Platform.isWindows || Platform.isMacOS) {
      try {
        await appCtrl.checkForUpdates(silent: false);
      } catch (e) {
        // ignore errors
      }
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
      // 清除配置，设置为空字符串以覆盖之前的值
      final currentConfig = appCtrl.appConfig.value;
      appCtrl.appConfig.value = AppConfig()
        ..configName = currentConfig.configName
        ..isDarkMode = currentConfig.isDarkMode
        ..languageCode = currentConfig.languageCode
        ..countryCode = currentConfig.countryCode
        ..emailReminderEnabled = currentConfig.emailReminderEnabled
        ..isDebugMode = currentConfig.isDebugMode
        ..backgroundImagePath = null  // 清除背景图片路径
        ..primaryColorValue = currentConfig.primaryColorValue
        ..backgroundImageOpacity = currentConfig.backgroundImageOpacity
        ..backgroundImageBlur = currentConfig.backgroundImageBlur
        ..backgroundAffectsNavBar = currentConfig.backgroundAffectsNavBar;
      
      appCtrl.appConfig.refresh();
      
      showToast('backgroundImageCleared'.tr);
      _logger.i('背景图片已清除');
    } catch (e) {
      _logger.e('清除背景图片设置失败: $e');
      showToast('backgroundImageClearFailed'.tr);
    }
  }
}
