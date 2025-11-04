import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:TodoCat/keys/dialog_keys.dart';

/// 滚动控制器Mixin
/// 提供通用的滚动控制功能，包括自动隐藏对话框等
mixin ScrollControllerMixin on GetxController {
  final ScrollController scrollController = ScrollController();
  double currentScrollOffset = 0.0;

  /// 初始化滚动控制器
  void initScrollController() {
    scrollController.addListener(_scrollListener);
  }

  /// 释放滚动控制器
  void disposeScrollController() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
  }

  /// 滚动监听器
  void _scrollListener() {
    if (_isScrolledToTop() || _isScrolledToBottom()) {
      return;
    }

    if (scrollController.offset != currentScrollOffset &&
        !scrollController.position.outOfRange) {
      // 滚动时自动隐藏下拉菜单
      SmartDialog.dismiss(tag: dropDownMenuBtnTag);
      onScrollChanged(scrollController.offset);
    }

    currentScrollOffset = scrollController.offset;
  }

  /// 检查是否滚动到顶部
  bool _isScrolledToTop() {
    return scrollController.offset <=
            scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange;
  }

  /// 检查是否滚动到底部
  bool _isScrolledToBottom() {
    return scrollController.offset >=
            scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange;
  }

  /// 滚动到底部
  Future<void> scrollToBottom({
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeOutCubic,
  }) async {
    await 0.1.delay(() => scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: duration,
          curve: curve,
        ));
  }

  /// 滚动到顶部
  Future<void> scrollToTop({
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = Curves.easeOutCubic,
  }) async {
    await 0.1.delay(() => scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: duration,
          curve: curve,
        ));
  }

  /// 滚动到指定位置
  Future<void> scrollToPosition(
    double position, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOut,
  }) async {
    await scrollController.animateTo(
      position,
      duration: duration,
      curve: curve,
    );
  }

  /// 平滑滚动到指定的项目
  Future<void> scrollToItem(
    int index, {
    double itemHeight = 100.0,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOut,
  }) async {
    final position = index * itemHeight;
    await scrollToPosition(position, duration: duration, curve: curve);
  }

  /// 当滚动位置改变时调用（子类可以重写）
  void onScrollChanged(double offset) {
    // 子类可以重写此方法来响应滚动变化
  }

  /// 获取当前滚动进度（0.0 到 1.0）
  double get scrollProgress {
    if (!scrollController.hasClients) return 0.0;
    
    final max = scrollController.position.maxScrollExtent;
    if (max <= 0) return 0.0;
    
    return (scrollController.offset / max).clamp(0.0, 1.0);
  }

  /// 检查是否可以滚动
  bool get canScroll => scrollController.hasClients && 
                       scrollController.position.maxScrollExtent > 0;

  /// 检查是否在顶部
  bool get isAtTop => _isScrolledToTop();

  /// 检查是否在底部
  bool get isAtBottom => _isScrolledToBottom();

  /// 向上翻页
  Future<void> pageUp({double? viewportFraction}) async {
    if (!canScroll) return;
    
    final viewport = viewportFraction ?? 0.8;
    final pageSize = scrollController.position.viewportDimension * viewport;
    final newPosition = (scrollController.offset - pageSize).clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent,
    );
    
    await scrollToPosition(newPosition);
  }

  /// 向下翻页
  Future<void> pageDown({double? viewportFraction}) async {
    if (!canScroll) return;
    
    final viewport = viewportFraction ?? 0.8;
    final pageSize = scrollController.position.viewportDimension * viewport;
    final newPosition = (scrollController.offset + pageSize).clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent,
    );
    
    await scrollToPosition(newPosition);
  }
}