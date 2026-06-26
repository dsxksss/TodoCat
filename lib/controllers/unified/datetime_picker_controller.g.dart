// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datetime_picker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dateTimePickerControllerHash() =>
    r'd4a4fe406f69396f5a1881f3b696f01fddb0a62d';

/// 统一的日期时间选择控制器（原 GetxController -> Riverpod Notifier）。
///
/// `state` 即 [DateTimePickerState]。原来的 `ever(...)` 监听器
/// （当 selectedHour / selectedMinute / isAM 变化时重算 selectedDateTime）
/// 改为在对应 setter 方法内部显式调用 [_updateDateTimeFromTime]。
///
/// Copied from [DateTimePickerController].
@ProviderFor(DateTimePickerController)
final dateTimePickerControllerProvider =
    NotifierProvider<DateTimePickerController, DateTimePickerState>.internal(
  DateTimePickerController.new,
  name: r'dateTimePickerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dateTimePickerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DateTimePickerController = Notifier<DateTimePickerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
