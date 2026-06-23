import 'package:flutter/widgets.dart';
import 'package:todo_cat/l10n/gen/app_localizations.dart';

export 'package:todo_cat/l10n/gen/app_localizations.dart';

Locale _currentLocale = const Locale('en');
AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

/// 当前语言（替代 GetX 的 `Get.locale`，供无 BuildContext 的逻辑层使用）。
Locale get currentLocale => _currentLocale;

/// 全局 AppLocalizations（替代 GetX 的 `.tr`，供 controller/service 等无 context 场景使用）。
///
/// 在语言切换时由 [updateGlobalLocalizations] 同步刷新；widget 内也可用
/// `context.l10n` / `AppLocalizations.of(context)` 获取可随 locale 变化重建的实例。
AppLocalizations get l10n => _l10n;

/// 在语言切换 / 启动时同步更新全局实例（由 AppController/根组件调用）。
void updateGlobalLocalizations(Locale locale) {
  _currentLocale = locale;
  _l10n = lookupAppLocalizations(locale);
}

/// 动态 key 翻译——替代 GetX 中对**变量**调用 `.tr` 的场景
/// （菜单项标题、提醒选项、月份名、itemType 等运行时才确定 key 的情况）。
///
/// 未命中的 key 会原样返回，以保持 GetX `.tr` 对未知 key（如用户自定义任务标题）
/// 的回退行为。
String dynTr(String key) {
  final t = _l10n;
  switch (key) {
    // 菜单项动作
    case 'edit':
      return t.edit;
    case 'delete':
      return t.delete;
    case 'restore':
      return t.restore;
    case 'permanentDelete':
      return t.permanentDelete;
    case 'copy':
      return t.copy;
    case 'duplicate':
      return t.duplicate;
    case 'moveToWorkspace':
      return t.moveToWorkspace;
    case 'moveTodoToWorkspace':
      return t.moveTodoToWorkspace;
    case 'createWorkspace':
      return t.createWorkspace;
    // 提醒选项（数字开头 key 已在 ARB 重命名）
    case 'noReminder':
      return t.noReminder;
    case '5minutes':
      return t.reminder5Minutes;
    case '15minutes':
      return t.reminder15Minutes;
    case '30minutes':
      return t.reminder30Minutes;
    case '1hour':
      return t.reminder1Hour;
    case '2hours':
      return t.reminder2Hours;
    case '1day':
      return t.reminder1Day;
    // 月份
    case 'january':
      return t.january;
    case 'february':
      return t.february;
    case 'march':
      return t.march;
    case 'april':
      return t.april;
    case 'may':
      return t.may;
    case 'june':
      return t.june;
    case 'july':
      return t.july;
    case 'august':
      return t.august;
    case 'september':
      return t.september;
    case 'october':
      return t.october;
    case 'november':
      return t.november;
    case 'december':
      return t.december;
    // 任务状态 / 默认模板标题 / itemType
    case 'todo':
      return t.todo;
    case 'inProgress':
      return t.inProgress;
    case 'done':
      return t.done;
    case 'another':
      return t.another;
    case 'task':
      return t.task;
    default:
      return key;
  }
}

/// BuildContext 便捷扩展，等价于 `AppLocalizations.of(context)`（会随 locale 变化重建）。
extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
