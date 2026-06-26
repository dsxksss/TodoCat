import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_cat/core/utils/platform.dart';
import 'package:todo_cat/pages/home/home_page.dart';
import 'package:todo_cat/pages/start.dart';
import 'package:todo_cat/pages/todo_detail_page.dart';
import 'package:todo_cat/pages/trash/trash_page.dart';
import 'package:todo_cat/pages/unknown_page.dart';

/// 根导航器 key —— 让无 BuildContext 的逻辑层（controller/service）也能导航，
/// 替代 GetX 的 `Get.back()` / `Get.currentRoute`。
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// 全局 go_router 实例（替代 GetX 的 GetMaterialApp 路由）。
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  // 移动端先进入闪屏页，桌面端直接进入主页（原 context.isPhone 逻辑）。
  initialLocation: AppPlatform.isMobile ? '/start' : '/',
  // 让 FlutterSmartDialog 跟随路由栈（原 navigatorObservers）。
  observers: [FlutterSmartDialog.observer],
  errorBuilder: (context, state) => const UnknownPage(),
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fadePage(const HomePage(), state),
    ),
    GoRoute(
      path: '/start',
      pageBuilder: (context, state) => _fadePage(const StartPage(), state),
    ),
    GoRoute(
      path: '/todo-detail',
      pageBuilder: (context, state) {
        final todoId = state.uri.queryParameters['todoId'] ?? '';
        final taskId = state.uri.queryParameters['taskId'] ?? '';
        return _slidePage(
          TodoDetailPage(todoId: todoId, taskId: taskId),
          state,
        );
      },
    ),
    GoRoute(
      path: '/trash',
      pageBuilder: (context, state) => _slidePage(const TrashPage(), state),
    ),
  ],
);

/// 当前路由路径（替代 GetX 的 `Get.currentRoute`）。
String get currentRoutePath =>
    appRouter.routerDelegate.currentConfiguration.uri.path;

/// 淡入过渡（带 easeOutCubic 缓出，比线性更柔和）。
CustomTransitionPage<T> _fadePage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    child: child,
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: child,
    ),
  );
}

/// 右进过渡：滑入 + 淡入组合，统一 easeOutCubic（入场更跟手、不拖沓）。
CustomTransitionPage<T> _slidePage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}
