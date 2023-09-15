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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

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

  @JsonKey(ignore: true)
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
      @HiveField(2) Locale locale});
}

/// @nodoc
class _$AppConfigCopyWithImpl<$Res, $Val extends AppConfig>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configName = null,
    Object? isDarkMode = null,
    Object? locale = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AppConfigCopyWith<$Res> implements $AppConfigCopyWith<$Res> {
  factory _$$_AppConfigCopyWith(
          _$_AppConfig value, $Res Function(_$_AppConfig) then) =
      __$$_AppConfigCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String configName,
      @HiveField(1) bool isDarkMode,
      @HiveField(2) Locale locale});
}

/// @nodoc
class __$$_AppConfigCopyWithImpl<$Res>
    extends _$AppConfigCopyWithImpl<$Res, _$_AppConfig>
    implements _$$_AppConfigCopyWith<$Res> {
  __$$_AppConfigCopyWithImpl(
      _$_AppConfig _value, $Res Function(_$_AppConfig) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configName = null,
    Object? isDarkMode = null,
    Object? locale = null,
  }) {
    return _then(_$_AppConfig(
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
    ));
  }
}

/// @nodoc

class _$_AppConfig implements _AppConfig {
  _$_AppConfig(
      {@HiveField(0) required this.configName,
      @HiveField(1) required this.isDarkMode,
      @HiveField(2) required this.locale});

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
  String toString() {
    return 'AppConfig(configName: $configName, isDarkMode: $isDarkMode, locale: $locale)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AppConfigCopyWith<_$_AppConfig> get copyWith =>
      __$$_AppConfigCopyWithImpl<_$_AppConfig>(this, _$identity);
}

abstract class _AppConfig implements AppConfig {
  factory _AppConfig(
      {@HiveField(0) required String configName,
      @HiveField(1) required bool isDarkMode,
      @HiveField(2) required Locale locale}) = _$_AppConfig;

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
  @JsonKey(ignore: true)
  _$$_AppConfigCopyWith<_$_AppConfig> get copyWith =>
      throw _privateConstructorUsedError;
}
