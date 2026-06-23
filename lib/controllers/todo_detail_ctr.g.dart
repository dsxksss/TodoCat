// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_detail_ctr.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todoDetailControllerHash() =>
    r'655590a710cb807334e6af2785a09a800a5bb67d';

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

abstract class _$TodoDetailController
    extends BuildlessAutoDisposeNotifier<TodoDetailState> {
  late final ({String taskId, String todoId}) params;

  TodoDetailState build(
    ({String taskId, String todoId}) params,
  );
}

/// 待办详情控制器（autoDispose family，按 (todoId, taskId) 分实例）。
/// 生成 `todoDetailControllerProvider(params)`。
///
/// 预览模式（原 `previewTodo` 构造参数）由独立的
/// [previewTodoDetailControllerProvider] 提供，避免与从数据源加载的逻辑混淆。
///
/// Copied from [TodoDetailController].
@ProviderFor(TodoDetailController)
const todoDetailControllerProvider = TodoDetailControllerFamily();

/// 待办详情控制器（autoDispose family，按 (todoId, taskId) 分实例）。
/// 生成 `todoDetailControllerProvider(params)`。
///
/// 预览模式（原 `previewTodo` 构造参数）由独立的
/// [previewTodoDetailControllerProvider] 提供，避免与从数据源加载的逻辑混淆。
///
/// Copied from [TodoDetailController].
class TodoDetailControllerFamily extends Family<TodoDetailState> {
  /// 待办详情控制器（autoDispose family，按 (todoId, taskId) 分实例）。
  /// 生成 `todoDetailControllerProvider(params)`。
  ///
  /// 预览模式（原 `previewTodo` 构造参数）由独立的
  /// [previewTodoDetailControllerProvider] 提供，避免与从数据源加载的逻辑混淆。
  ///
  /// Copied from [TodoDetailController].
  const TodoDetailControllerFamily();

  /// 待办详情控制器（autoDispose family，按 (todoId, taskId) 分实例）。
  /// 生成 `todoDetailControllerProvider(params)`。
  ///
  /// 预览模式（原 `previewTodo` 构造参数）由独立的
  /// [previewTodoDetailControllerProvider] 提供，避免与从数据源加载的逻辑混淆。
  ///
  /// Copied from [TodoDetailController].
  TodoDetailControllerProvider call(
    ({String taskId, String todoId}) params,
  ) {
    return TodoDetailControllerProvider(
      params,
    );
  }

  @override
  TodoDetailControllerProvider getProviderOverride(
    covariant TodoDetailControllerProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'todoDetailControllerProvider';
}

/// 待办详情控制器（autoDispose family，按 (todoId, taskId) 分实例）。
/// 生成 `todoDetailControllerProvider(params)`。
///
/// 预览模式（原 `previewTodo` 构造参数）由独立的
/// [previewTodoDetailControllerProvider] 提供，避免与从数据源加载的逻辑混淆。
///
/// Copied from [TodoDetailController].
class TodoDetailControllerProvider extends AutoDisposeNotifierProviderImpl<
    TodoDetailController, TodoDetailState> {
  /// 待办详情控制器（autoDispose family，按 (todoId, taskId) 分实例）。
  /// 生成 `todoDetailControllerProvider(params)`。
  ///
  /// 预览模式（原 `previewTodo` 构造参数）由独立的
  /// [previewTodoDetailControllerProvider] 提供，避免与从数据源加载的逻辑混淆。
  ///
  /// Copied from [TodoDetailController].
  TodoDetailControllerProvider(
    ({String taskId, String todoId}) params,
  ) : this._internal(
          () => TodoDetailController()..params = params,
          from: todoDetailControllerProvider,
          name: r'todoDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$todoDetailControllerHash,
          dependencies: TodoDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              TodoDetailControllerFamily._allTransitiveDependencies,
          params: params,
        );

  TodoDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final ({String taskId, String todoId}) params;

  @override
  TodoDetailState runNotifierBuild(
    covariant TodoDetailController notifier,
  ) {
    return notifier.build(
      params,
    );
  }

  @override
  Override overrideWith(TodoDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TodoDetailControllerProvider._internal(
        () => create()..params = params,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TodoDetailController, TodoDetailState>
      createElement() {
    return _TodoDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodoDetailControllerProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TodoDetailControllerRef
    on AutoDisposeNotifierProviderRef<TodoDetailState> {
  /// The parameter `params` of this provider.
  ({String taskId, String todoId}) get params;
}

class _TodoDetailControllerProviderElement
    extends AutoDisposeNotifierProviderElement<TodoDetailController,
        TodoDetailState> with TodoDetailControllerRef {
  _TodoDetailControllerProviderElement(super.provider);

  @override
  ({String taskId, String todoId}) get params =>
      (origin as TodoDetailControllerProvider).params;
}

String _$previewTodoDetailControllerHash() =>
    r'32e43183e25c3ee3ee70d5c791e606f9b672185b';

abstract class _$PreviewTodoDetailController
    extends BuildlessAutoDisposeNotifier<TodoDetailState> {
  late final Todo previewTodo;

  TodoDetailState build(
    Todo previewTodo,
  );
}

/// 预览模式的待办详情控制器（autoDispose family，按预览的 [Todo] 分实例）。
/// 生成 `previewTodoDetailControllerProvider(previewTodo)`。
///
/// 与 [TodoDetailController] 共享同样的文本辅助方法（[getPriorityText] /
/// [getStatusText]），但不从数据源加载、不监听变化、不导航。
///
/// Copied from [PreviewTodoDetailController].
@ProviderFor(PreviewTodoDetailController)
const previewTodoDetailControllerProvider = PreviewTodoDetailControllerFamily();

/// 预览模式的待办详情控制器（autoDispose family，按预览的 [Todo] 分实例）。
/// 生成 `previewTodoDetailControllerProvider(previewTodo)`。
///
/// 与 [TodoDetailController] 共享同样的文本辅助方法（[getPriorityText] /
/// [getStatusText]），但不从数据源加载、不监听变化、不导航。
///
/// Copied from [PreviewTodoDetailController].
class PreviewTodoDetailControllerFamily extends Family<TodoDetailState> {
  /// 预览模式的待办详情控制器（autoDispose family，按预览的 [Todo] 分实例）。
  /// 生成 `previewTodoDetailControllerProvider(previewTodo)`。
  ///
  /// 与 [TodoDetailController] 共享同样的文本辅助方法（[getPriorityText] /
  /// [getStatusText]），但不从数据源加载、不监听变化、不导航。
  ///
  /// Copied from [PreviewTodoDetailController].
  const PreviewTodoDetailControllerFamily();

  /// 预览模式的待办详情控制器（autoDispose family，按预览的 [Todo] 分实例）。
  /// 生成 `previewTodoDetailControllerProvider(previewTodo)`。
  ///
  /// 与 [TodoDetailController] 共享同样的文本辅助方法（[getPriorityText] /
  /// [getStatusText]），但不从数据源加载、不监听变化、不导航。
  ///
  /// Copied from [PreviewTodoDetailController].
  PreviewTodoDetailControllerProvider call(
    Todo previewTodo,
  ) {
    return PreviewTodoDetailControllerProvider(
      previewTodo,
    );
  }

  @override
  PreviewTodoDetailControllerProvider getProviderOverride(
    covariant PreviewTodoDetailControllerProvider provider,
  ) {
    return call(
      provider.previewTodo,
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
  String? get name => r'previewTodoDetailControllerProvider';
}

/// 预览模式的待办详情控制器（autoDispose family，按预览的 [Todo] 分实例）。
/// 生成 `previewTodoDetailControllerProvider(previewTodo)`。
///
/// 与 [TodoDetailController] 共享同样的文本辅助方法（[getPriorityText] /
/// [getStatusText]），但不从数据源加载、不监听变化、不导航。
///
/// Copied from [PreviewTodoDetailController].
class PreviewTodoDetailControllerProvider
    extends AutoDisposeNotifierProviderImpl<PreviewTodoDetailController,
        TodoDetailState> {
  /// 预览模式的待办详情控制器（autoDispose family，按预览的 [Todo] 分实例）。
  /// 生成 `previewTodoDetailControllerProvider(previewTodo)`。
  ///
  /// 与 [TodoDetailController] 共享同样的文本辅助方法（[getPriorityText] /
  /// [getStatusText]），但不从数据源加载、不监听变化、不导航。
  ///
  /// Copied from [PreviewTodoDetailController].
  PreviewTodoDetailControllerProvider(
    Todo previewTodo,
  ) : this._internal(
          () => PreviewTodoDetailController()..previewTodo = previewTodo,
          from: previewTodoDetailControllerProvider,
          name: r'previewTodoDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$previewTodoDetailControllerHash,
          dependencies: PreviewTodoDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              PreviewTodoDetailControllerFamily._allTransitiveDependencies,
          previewTodo: previewTodo,
        );

  PreviewTodoDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.previewTodo,
  }) : super.internal();

  final Todo previewTodo;

  @override
  TodoDetailState runNotifierBuild(
    covariant PreviewTodoDetailController notifier,
  ) {
    return notifier.build(
      previewTodo,
    );
  }

  @override
  Override overrideWith(PreviewTodoDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PreviewTodoDetailControllerProvider._internal(
        () => create()..previewTodo = previewTodo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        previewTodo: previewTodo,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PreviewTodoDetailController,
      TodoDetailState> createElement() {
    return _PreviewTodoDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PreviewTodoDetailControllerProvider &&
        other.previewTodo == previewTodo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, previewTodo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PreviewTodoDetailControllerRef
    on AutoDisposeNotifierProviderRef<TodoDetailState> {
  /// The parameter `previewTodo` of this provider.
  Todo get previewTodo;
}

class _PreviewTodoDetailControllerProviderElement
    extends AutoDisposeNotifierProviderElement<PreviewTodoDetailController,
        TodoDetailState> with PreviewTodoDetailControllerRef {
  _PreviewTodoDetailControllerProviderElement(super.provider);

  @override
  Todo get previewTodo =>
      (origin as PreviewTodoDetailControllerProvider).previewTodo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
