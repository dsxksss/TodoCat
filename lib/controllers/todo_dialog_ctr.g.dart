// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_dialog_ctr.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addTodoDialogControllerHash() =>
    r'5f4c120d8fbac8880389ba83c671d4135edd73d0';

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

abstract class _$AddTodoDialogController
    extends BuildlessAutoDisposeNotifier<AddTodoFormState> {
  late final String tag;

  AddTodoFormState build(
    String tag,
  );
}

/// 新增/编辑 Todo 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
/// 生成 `addTodoDialogControllerProvider(tag)`。
///
/// Copied from [AddTodoDialogController].
@ProviderFor(AddTodoDialogController)
const addTodoDialogControllerProvider = AddTodoDialogControllerFamily();

/// 新增/编辑 Todo 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
/// 生成 `addTodoDialogControllerProvider(tag)`。
///
/// Copied from [AddTodoDialogController].
class AddTodoDialogControllerFamily extends Family<AddTodoFormState> {
  /// 新增/编辑 Todo 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
  /// 生成 `addTodoDialogControllerProvider(tag)`。
  ///
  /// Copied from [AddTodoDialogController].
  const AddTodoDialogControllerFamily();

  /// 新增/编辑 Todo 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
  /// 生成 `addTodoDialogControllerProvider(tag)`。
  ///
  /// Copied from [AddTodoDialogController].
  AddTodoDialogControllerProvider call(
    String tag,
  ) {
    return AddTodoDialogControllerProvider(
      tag,
    );
  }

  @override
  AddTodoDialogControllerProvider getProviderOverride(
    covariant AddTodoDialogControllerProvider provider,
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
  String? get name => r'addTodoDialogControllerProvider';
}

/// 新增/编辑 Todo 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
/// 生成 `addTodoDialogControllerProvider(tag)`。
///
/// Copied from [AddTodoDialogController].
class AddTodoDialogControllerProvider extends AutoDisposeNotifierProviderImpl<
    AddTodoDialogController, AddTodoFormState> {
  /// 新增/编辑 Todo 对话框控制器（autoDispose，按 `tag` 分实例的 family）。
  /// 生成 `addTodoDialogControllerProvider(tag)`。
  ///
  /// Copied from [AddTodoDialogController].
  AddTodoDialogControllerProvider(
    String tag,
  ) : this._internal(
          () => AddTodoDialogController()..tag = tag,
          from: addTodoDialogControllerProvider,
          name: r'addTodoDialogControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$addTodoDialogControllerHash,
          dependencies: AddTodoDialogControllerFamily._dependencies,
          allTransitiveDependencies:
              AddTodoDialogControllerFamily._allTransitiveDependencies,
          tag: tag,
        );

  AddTodoDialogControllerProvider._internal(
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
  AddTodoFormState runNotifierBuild(
    covariant AddTodoDialogController notifier,
  ) {
    return notifier.build(
      tag,
    );
  }

  @override
  Override overrideWith(AddTodoDialogController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AddTodoDialogControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<AddTodoDialogController, AddTodoFormState>
      createElement() {
    return _AddTodoDialogControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddTodoDialogControllerProvider && other.tag == tag;
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
mixin AddTodoDialogControllerRef
    on AutoDisposeNotifierProviderRef<AddTodoFormState> {
  /// The parameter `tag` of this provider.
  String get tag;
}

class _AddTodoDialogControllerProviderElement
    extends AutoDisposeNotifierProviderElement<AddTodoDialogController,
        AddTodoFormState> with AddTodoDialogControllerRef {
  _AddTodoDialogControllerProviderElement(super.provider);

  @override
  String get tag => (origin as AddTodoDialogControllerProvider).tag;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
