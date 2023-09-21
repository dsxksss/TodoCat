// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_notice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$LocalNotice {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(0)
  set id(String value) => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(1)
  set title(String value) => throw _privateConstructorUsedError;
  @HiveField(2)
  String get description => throw _privateConstructorUsedError;
  @HiveField(2)
  set description(String value) => throw _privateConstructorUsedError;
  @HiveField(3)
  int get createdAt => throw _privateConstructorUsedError;
  @HiveField(3)
  set createdAt(int value) => throw _privateConstructorUsedError;
  @HiveField(4)
  int get remindersAt => throw _privateConstructorUsedError;
  @HiveField(4)
  set remindersAt(int value) => throw _privateConstructorUsedError;
  @HiveField(5)
  String get email => throw _privateConstructorUsedError;
  @HiveField(5)
  set email(String value) => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LocalNoticeCopyWith<LocalNotice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalNoticeCopyWith<$Res> {
  factory $LocalNoticeCopyWith(
          LocalNotice value, $Res Function(LocalNotice) then) =
      _$LocalNoticeCopyWithImpl<$Res, LocalNotice>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String description,
      @HiveField(3) int createdAt,
      @HiveField(4) int remindersAt,
      @HiveField(5) String email});
}

/// @nodoc
class _$LocalNoticeCopyWithImpl<$Res, $Val extends LocalNotice>
    implements $LocalNoticeCopyWith<$Res> {
  _$LocalNoticeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? createdAt = null,
    Object? remindersAt = null,
    Object? email = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      remindersAt: null == remindersAt
          ? _value.remindersAt
          : remindersAt // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LocalNoticeCopyWith<$Res>
    implements $LocalNoticeCopyWith<$Res> {
  factory _$$_LocalNoticeCopyWith(
          _$_LocalNotice value, $Res Function(_$_LocalNotice) then) =
      __$$_LocalNoticeCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) String description,
      @HiveField(3) int createdAt,
      @HiveField(4) int remindersAt,
      @HiveField(5) String email});
}

/// @nodoc
class __$$_LocalNoticeCopyWithImpl<$Res>
    extends _$LocalNoticeCopyWithImpl<$Res, _$_LocalNotice>
    implements _$$_LocalNoticeCopyWith<$Res> {
  __$$_LocalNoticeCopyWithImpl(
      _$_LocalNotice _value, $Res Function(_$_LocalNotice) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? createdAt = null,
    Object? remindersAt = null,
    Object? email = null,
  }) {
    return _then(_$_LocalNotice(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      remindersAt: null == remindersAt
          ? _value.remindersAt
          : remindersAt // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_LocalNotice with DiagnosticableTreeMixin implements _LocalNotice {
  _$_LocalNotice(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) required this.description,
      @HiveField(3) required this.createdAt,
      @HiveField(4) required this.remindersAt,
      @HiveField(5) required this.email});

  @override
  @HiveField(0)
  String id;
  @override
  @HiveField(1)
  String title;
  @override
  @HiveField(2)
  String description;
  @override
  @HiveField(3)
  int createdAt;
  @override
  @HiveField(4)
  int remindersAt;
  @override
  @HiveField(5)
  String email;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'LocalNotice(id: $id, title: $title, description: $description, createdAt: $createdAt, remindersAt: $remindersAt, email: $email)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'LocalNotice'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('remindersAt', remindersAt))
      ..add(DiagnosticsProperty('email', email));
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LocalNoticeCopyWith<_$_LocalNotice> get copyWith =>
      __$$_LocalNoticeCopyWithImpl<_$_LocalNotice>(this, _$identity);
}

abstract class _LocalNotice implements LocalNotice {
  factory _LocalNotice(
      {@HiveField(0) required String id,
      @HiveField(1) required String title,
      @HiveField(2) required String description,
      @HiveField(3) required int createdAt,
      @HiveField(4) required int remindersAt,
      @HiveField(5) required String email}) = _$_LocalNotice;

  @override
  @HiveField(0)
  String get id;
  @HiveField(0)
  set id(String value);
  @override
  @HiveField(1)
  String get title;
  @HiveField(1)
  set title(String value);
  @override
  @HiveField(2)
  String get description;
  @HiveField(2)
  set description(String value);
  @override
  @HiveField(3)
  int get createdAt;
  @HiveField(3)
  set createdAt(int value);
  @override
  @HiveField(4)
  int get remindersAt;
  @HiveField(4)
  set remindersAt(int value);
  @override
  @HiveField(5)
  String get email;
  @HiveField(5)
  set email(String value);
  @override
  @JsonKey(ignore: true)
  _$$_LocalNoticeCopyWith<_$_LocalNotice> get copyWith =>
      throw _privateConstructorUsedError;
}
