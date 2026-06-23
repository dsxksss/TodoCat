// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_ctr.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appControllerHash() => r'c8a5ac18857a0b4e07fc829ffcbe6abfa754061d';

/// 全局应用控制器（原 GetxController -> Riverpod Notifier）。
/// state 即当前 [AppConfig]；外部通过 [updateConfig] 更新并持久化。
///
/// Copied from [AppController].
@ProviderFor(AppController)
final appControllerProvider =
    NotifierProvider<AppController, AppConfig>.internal(
  AppController.new,
  name: r'appControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppController = Notifier<AppConfig>;
String _$windowControllerHash() => r'468bdc1ae92fd93570d769b5055ed2cdc93f40c6';

/// 窗口控制器（桌面端窗口管理）。
///
/// Copied from [WindowController].
@ProviderFor(WindowController)
final windowControllerProvider =
    NotifierProvider<WindowController, WindowState>.internal(
  WindowController.new,
  name: r'windowControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$windowControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WindowController = Notifier<WindowState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
