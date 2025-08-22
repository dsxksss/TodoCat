import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 编辑状态管理Mixin
/// 提供通用的编辑状态管理功能
mixin EditStateMixin on GetxController {
  static final _logger = Logger();

  final isEditing = false.obs;
  Map<String, dynamic>? _originalState;
  dynamic _editingItem;

  /// 获取当前编辑的项目
  T? getEditingItem<T>() => _editingItem as T?;

  /// 初始化编辑模式
  void initEditing<T>(T item, Map<String, dynamic> state) {
    _editingItem = item;
    isEditing.value = true;
    _originalState = Map<String, dynamic>.from(state);
    _logger.d('Editing initialized for ${T.toString()}: $_originalState');
    onEditingInitialized(item, state);
  }

  /// 退出编辑模式
  void exitEditing() {
    _editingItem = null;
    isEditing.value = false;
    _originalState = null;
    _logger.d('Editing mode exited');
    onEditingExited();
  }

  /// 检查是否有变更
  bool hasUnsavedChanges() {
    if (!isEditing.value || _originalState == null) return false;
    return checkForChanges(_originalState!);
  }

  /// 恢复到原始状态
  void revertChanges() {
    if (!isEditing.value || _originalState == null) return;
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