// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_ctr.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trashControllerHash() => r'34d9f6eb573b3986fc878edd54d08a8a411b0933';

/// 回收站控制器，管理已删除的任务和待办事项（原 GetxController -> Riverpod Notifier）。
///
/// Copied from [TrashController].
@ProviderFor(TrashController)
final trashControllerProvider =
    NotifierProvider<TrashController, TrashState>.internal(
  TrashController.new,
  name: r'trashControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trashControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrashController = Notifier<TrashState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
