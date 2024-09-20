// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppConfig {
  @HiveField(0)
  String get configName => throw _privateConstructorUsedError;
  @HiveField(0)
  set configName(String value) => throw _privateConstructorUsedError;
  @HiveField(1)
  bool get isDarkMode => throw _privateConstructorUsedError;
  @HiveField(1)
  set isDarkMode(bool value) => throw _privateConstructorUsedError;
  @HiveField(2)
  Locale get locale => throw _privateConstructorUsedError;
  @HiveField(2)
  set locale(Locale value) => throw _privateConstructorUsedError;
  @HiveField(3)
  bool get emailReminderEnabled => throw _privateConstructorUsedError;
  @HiveField(3)
  set emailReminderEnabled(bool value) => throw _privateConstructorUsedError;
  @HiveField(4)
  bool get isDebugMode => throw _privateConstructorUsedError;
  @HiveField(4)
  set isDebugMode(bool value) => throw _privateConstructorUsedError;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppConfigCopyWith<AppConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppConfigCopyWith<$Res> {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) then) =
      _$AppConfigCopyWithImpl<$Res, AppConfig>;
  @useResult
  $Res call(
      {@HiveField(0) String configName,
      @HiveField(1) bool isDarkMode,
      @HiveField(2) Locale locale,
      @HiveField(3) bool emailReminderEnabled,
      @HiveField(4) bool isDebugMode});
}

/// @nodoc
class _$AppConfigCopyWithImpl<$Res, $Val extends AppConfig>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configName = null,
    Object? isDarkMode = null,
    Object? locale = null,
    Object? emailReminderEnabled = null,
    Object? isDebugMode = null,
  }) {
    return _then(_value.copyWith(
      configName: null == configName
          ? _value.configName
          : configName // ignore: cast_nullable_to_non_nullable
              as String,
      isDarkMode: null == isDarkMode
          ? _value.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale,
      emailReminderEnabled: null == emailReminderEnabled
          ? _value.emailReminderEnabled
          : emailReminderEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isDebugMode: null == isDebugMode
          ? _value.isDebugMode
          : isDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppConfigImplCopyWith<$Res>
    implements $AppConfigCopyWith<$Res> {
  factory _$$AppConfigImplCopyWith(
          _$AppConfigImpl value, $Res Function(_$AppConfigImpl) then) =
      __$$AppConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String configName,
      @HiveField(1) bool isDarkMode,
      @HiveField(2) Locale locale,
      @HiveField(3) bool emailReminderEnabled,
      @HiveField(4) bool isDebugMode});
}

/// @nodoc
class __$$AppConfigImplCopyWithImpl<$Res>
    extends _$AppConfigCopyWithImpl<$Res, _$AppConfigImpl>
    implements _$$AppConfigImplCopyWith<$Res> {
  __$$AppConfigImplCopyWithImpl(
      _$AppConfigImpl _value, $Res Function(_$AppConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configName = null,
    Object? isDarkMode = null,
    Object? locale = null,
    Object? emailReminderEnabled = null,
    Object? isDebugMode = null,
  }) {
    return _then(_$AppConfigImpl(
      configName: null == configName
          ? _value.configName
          : configName // ignore: cast_nullable_to_non_nullable
              as String,
      isDarkMode: null == isDarkMode
          ? _value.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale,
      emailReminderEnabled: null == emailReminderEnabled
          ? _value.emailReminderEnabled
          : emailReminderEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isDebugMode: null == isDebugMode
          ? _value.isDebugMode
          : isDebugMode // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AppConfigImpl implements _AppConfig {
  _$AppConfigImpl(
      {@HiveField(0) required this.configName,
      @HiveField(1) required this.isDarkMode,
      @HiveField(2) required this.locale,
      @HiveField(3) required this.emailReminderEnabled,
      @HiveField(4) required this.isDebugMode});

  @override
  @HiveField(0)
  String configName;
  @override
  @HiveField(1)
  bool isDarkMode;
  @override
  @HiveField(2)
  Locale locale;
  @override
  @HiveField(3)
  bool emailReminderEnabled;
  @override
  @HiveField(4)
  bool isDebugMode;

  @override
  String toString() {
    return 'AppConfig(configName: $configName, isDarkMode: $isDarkMode, locale: $locale, emailReminderEnabled: $emailReminderEnabled, isDebugMode: $isDebugMode)';
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      __$$AppConfigImplCopyWithImpl<_$AppConfigImpl>(this, _$identity);
}

abstract class _AppConfig implements AppConfig {
  factory _AppConfig(
      {@HiveField(0) required String configName,
      @HiveField(1) required bool isDarkMode,
      @HiveField(2) required Locale locale,
      @HiveField(3) required bool emailReminderEnabled,
      @HiveField(4) required bool isDebugMode}) = _$AppConfigImpl;

  @override
  @HiveField(0)
  String get configName;
  @HiveField(0)
  set configName(String value);
  @override
  @HiveField(1)
  bool get isDarkMode;
  @HiveField(1)
  set isDarkMode(bool value);
  @override
  @HiveField(2)
  Locale get locale;
  @HiveField(2)
  set locale(Locale value);
  @override
  @HiveField(3)
  bool get emailReminderEnabled;
  @HiveField(3)
  set emailReminderEnabled(bool value);
  @override
  @HiveField(4)
  bool get isDebugMode;
  @HiveField(4)
  set isDebugMode(bool value);

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
