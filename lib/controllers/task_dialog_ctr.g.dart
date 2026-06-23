// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dialog_ctr.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskDialogControllerHash() =>
    r'2e5453698ecc1056435f822698fd056fe471e0ba';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$TaskDialogController
    extends BuildlessAutoDisposeNotifier<TaskFormState> {
  late final String tag;

  TaskFormState build(
    String tag,
  );
}

/// 新增/编辑 Task 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
/// 生成 `taskDialogControllerProvider(tag)`。
///
/// Copied from [TaskDialogController].
@ProviderFor(TaskDialogController)
const taskDialogControllerProvider = TaskDialogControllerFamily();

/// 新增/编辑 Task 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
/// 生成 `taskDialogControllerProvider(tag)`。
///
/// Copied from [TaskDialogController].
class TaskDialogControllerFamily extends Family<TaskFormState> {
  /// 新增/编辑 Task 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
  /// 生成 `taskDialogControllerProvider(tag)`。
  ///
  /// Copied from [TaskDialogController].
  const TaskDialogControllerFamily();

  /// 新增/编辑 Task 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
  /// 生成 `taskDialogControllerProvider(tag)`。
  ///
  /// Copied from [TaskDialogController].
  TaskDialogControllerProvider call(
    String tag,
  ) {
    return TaskDialogControllerProvider(
      tag,
    );
  }

  @override
  TaskDialogControllerProvider getProviderOverride(
    covariant TaskDialogControllerProvider provider,
  ) {
    return call(
      provider.tag,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskDialogControllerProvider';
}

/// 新增/编辑 Task 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
/// 生成 `taskDialogControllerProvider(tag)`。
///
/// Copied from [TaskDialogController].
class TaskDialogControllerProvider extends AutoDisposeNotifierProviderImpl<
    TaskDialogController, TaskFormState> {
  /// 新增/编辑 Task 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
  /// 生成 `taskDialogControllerProvider(tag)`。
  ///
  /// Copied from [TaskDialogController].
  TaskDialogControllerProvider(
    String tag,
  ) : this._internal(
          () => TaskDialogController()..tag = tag,
          from: taskDialogControllerProvider,
          name: r'taskDialogControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$taskDialogControllerHash,
          dependencies: TaskDialogControllerFamily._dependencies,
          allTransitiveDependencies:
              TaskDialogControllerFamily._allTransitiveDependencies,
          tag: tag,
        );

  TaskDialogControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tag,
  }) : super.internal();

  final String tag;

  @override
  TaskFormState runNotifierBuild(
    covariant TaskDialogController notifier,
  ) {
    return notifier.build(
      tag,
    );
  }

  @override
  Override overrideWith(TaskDialogController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TaskDialogControllerProvider._internal(
        () => create()..tag = tag,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tag: tag,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TaskDialogController, TaskFormState>
      createElement() {
    return _TaskDialogControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskDialogControllerProvider && other.tag == tag;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tag.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskDialogControllerRef on AutoDisposeNotifierProviderRef<TaskFormState> {
  /// The parameter `tag` of this provider.
  String get tag;
}

class _TaskDialogControllerProviderElement
    extends AutoDisposeNotifierProviderElement<TaskDialogController,
        TaskFormState> with TaskDialogControllerRef {
  _TaskDialogControllerProviderElement(super.provider);

  @override
  String get tag => (origin as TaskDialogControllerProvider).tag;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
