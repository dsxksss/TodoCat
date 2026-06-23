import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 编辑状态管理 Mixin（Riverpod 版）。
///
/// 原 `mixin EditStateMixin on GetxController` 去掉了 `on GetxController` 约束，
/// 现在是一个纯 Dart mixin，供各表单 Notifier 复用。
/// `isEditing` 不再是 `RxBool`，改为各表单 state 对象里的普通 `bool`，
/// 这里只保留 “编辑原始态 / 变更比较 / 恢复” 等与 UI 无关的纯逻辑。
mixin EditStateMixin {
  static final _logger = Logger();

  Map<String, dynamic>? _originalState;
  dynamic _editingItem;

  /// 获取当前编辑的项目
  T? getEditingItem<T>() => _editingItem as T?;

  /// 初始化编辑模式（仅记录原始态与被编辑对象，编辑标记由 state 持有）
  void initEditing<T>(T item, Map<String, dynamic> state) {
    _editingItem = item;
    _originalState = Map<String, dynamic>.from(state);
    _logger.d('Editing initialized for ${T.toString()}: $_originalState');
    onEditingInitialized(item, state);
  }

  /// 退出编辑模式
  void exitEditing() {
    _editingItem = null;
    _originalState = null;
    _logger.d('Editing mode exited');
    onEditingExited();
  }

  /// 检查是否有变更
  bool hasUnsavedChanges() {
    if (_originalState == null) return false;
    return checkForChanges(_originalState!);
  }

  /// 恢复到原始状态
  void revertChanges() {
    if (_originalState == null) return;
    _logger.d('Reverting changes to original state');
    restoreToOriginalState(_originalState!);
  }

  /// 获取原始状态
  Map<String, dynamic>? get originalState => _originalState;

  /// 子类需要实现的方法

  /// 编辑初始化时调用
  void onEditingInitialized<T>(T item, Map<String, dynamic> state) {}

  /// 编辑退出时调用
  void onEditingExited() {}

  /// 检查变更（子类实现具体逻辑）
  bool checkForChanges(Map<String, dynamic> originalState);

  /// 恢复到原始状态（子类实现具体逻辑）
  void restoreToOriginalState(Map<String, dynamic> originalState);

  /// 比较列表是否相等的辅助方法
  bool compareListEquality<T>(List<T>? list1, List<T>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    return listEquals(list1, list2);
  }

  /// 安全的字符串比较
  bool compareStrings(String? str1, String? str2) {
    return (str1 ?? '') == (str2 ?? '');
  }

  /// 安全的数值比较
  bool compareNumbers<T extends num>(T? num1, T? num2) {
    return (num1 ?? 0) == (num2 ?? 0);
  }

  /// 日期时间比较
  bool compareDateTimes(DateTime? dt1, DateTime? dt2) {
    if (dt1 == null && dt2 == null) return true;
    if (dt1 == null || dt2 == null) return false;
    return dt1.millisecondsSinceEpoch == dt2.millisecondsSinceEpoch;
  }
}
