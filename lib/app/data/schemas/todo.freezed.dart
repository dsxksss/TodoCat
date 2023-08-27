// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Todo {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(0)
  set id(String value) => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(1)
  set title(String value) => throw _privateConstructorUsedError;
  @HiveField(2)
  List<String> get tags => throw _privateConstructorUsedError;
  @HiveField(2)
  set tags(List<String> value) => throw _privateConstructorUsedError;
  @HiveField(3)
  int get createdAt => throw _privateConstructorUsedError;
  @HiveField(3)
  set createdAt(int value) => throw _privateConstructorUsedError;
  @HiveField(4)
  String get description => throw _privateConstructorUsedError;
  @HiveField(4)
  set description(String value) => throw _privateConstructorUsedError;
  @HiveField(5)
  TodoPriority get priority => throw _privateConstructorUsedError;
  @HiveField(5)
  set priority(TodoPriority value) => throw _privateConstructorUsedError;
  @HiveField(6)
  int get finishedAt => throw _privateConstructorUsedError;
  @HiveField(6)
  set finishedAt(int value) => throw _privateConstructorUsedError;
  @HiveField(7)
  TodoStatus get status => throw _privateConstructorUsedError;
  @HiveField(7)
  set status(TodoStatus value) => throw _privateConstructorUsedError;
  @HiveField(8)
  int get reminders => throw _privateConstructorUsedError;
  @HiveField(8)
  set reminders(int value) => throw _privateConstructorUsedError;
  @HiveField(9)
  int get progress => throw _privateConstructorUsedError;
  @HiveField(9)
  set progress(int value) => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TodoCopyWith<Todo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoCopyWith<$Res> {
  factory $TodoCopyWith(Todo value, $Res Function(Todo) then) =
      _$TodoCopyWithImpl<$Res, Todo>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) List<String> tags,
      @HiveField(3) int createdAt,
      @HiveField(4) String description,
      @HiveField(5) TodoPriority priority,
      @HiveField(6) int finishedAt,
      @HiveField(7) TodoStatus status,
      @HiveField(8) int reminders,
      @HiveField(9) int progress});
}

/// @nodoc
class _$TodoCopyWithImpl<$Res, $Val extends Todo>
    implements $TodoCopyWith<$Res> {
  _$TodoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? description = null,
    Object? priority = null,
    Object? finishedAt = null,
    Object? status = null,
    Object? reminders = null,
    Object? progress = null,
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
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as TodoPriority,
      finishedAt: null == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TodoStatus,
      reminders: null == reminders
          ? _value.reminders
          : reminders // ignore: cast_nullable_to_non_nullable
              as int,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TodoCopyWith<$Res> implements $TodoCopyWith<$Res> {
  factory _$$_TodoCopyWith(_$_Todo value, $Res Function(_$_Todo) then) =
      __$$_TodoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String title,
      @HiveField(2) List<String> tags,
      @HiveField(3) int createdAt,
      @HiveField(4) String description,
      @HiveField(5) TodoPriority priority,
      @HiveField(6) int finishedAt,
      @HiveField(7) TodoStatus status,
      @HiveField(8) int reminders,
      @HiveField(9) int progress});
}

/// @nodoc
class __$$_TodoCopyWithImpl<$Res> extends _$TodoCopyWithImpl<$Res, _$_Todo>
    implements _$$_TodoCopyWith<$Res> {
  __$$_TodoCopyWithImpl(_$_Todo _value, $Res Function(_$_Todo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? description = null,
    Object? priority = null,
    Object? finishedAt = null,
    Object? status = null,
    Object? reminders = null,
    Object? progress = null,
  }) {
    return _then(_$_Todo(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as TodoPriority,
      finishedAt: null == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TodoStatus,
      reminders: null == reminders
          ? _value.reminders
          : reminders // ignore: cast_nullable_to_non_nullable
              as int,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_Todo implements _Todo {
  _$_Todo(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) required this.tags,
      @HiveField(3) required this.createdAt,
      @HiveField(4) this.description = '',
      @HiveField(5) this.priority = TodoPriority.lowLevel,
      @HiveField(6) this.finishedAt = 0,
      @HiveField(7) this.status = TodoStatus.todo,
      @HiveField(8) this.reminders = 0,
      @HiveField(9) this.progress = 0});

  @override
  @HiveField(0)
  String id;
  @override
  @HiveField(1)
  String title;
  @override
  @HiveField(2)
  List<String> tags;
  @override
  @HiveField(3)
  int createdAt;
  @override
  @JsonKey()
  @HiveField(4)
  String description;
  @override
  @JsonKey()
  @HiveField(5)
  TodoPriority priority;
  @override
  @JsonKey()
  @HiveField(6)
  int finishedAt;
  @override
  @JsonKey()
  @HiveField(7)
  TodoStatus status;
  @override
  @JsonKey()
  @HiveField(8)
  int reminders;
  @override
  @JsonKey()
  @HiveField(9)
  int progress;

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, tags: $tags, createdAt: $createdAt, description: $description, priority: $priority, finishedAt: $finishedAt, status: $status, reminders: $reminders, progress: $progress)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TodoCopyWith<_$_Todo> get copyWith =>
      __$$_TodoCopyWithImpl<_$_Todo>(this, _$identity);
}

abstract class _Todo implements Todo {
  factory _Todo(
      {@HiveField(0) required String id,
      @HiveField(1) required String title,
      @HiveField(2) required List<String> tags,
      @HiveField(3) required int createdAt,
      @HiveField(4) String description,
      @HiveField(5) TodoPriority priority,
      @HiveField(6) int finishedAt,
      @HiveField(7) TodoStatus status,
      @HiveField(8) int reminders,
      @HiveField(9) int progress}) = _$_Todo;

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
  List<String> get tags;
  @HiveField(2)
  set tags(List<String> value);
  @override
  @HiveField(3)
  int get createdAt;
  @HiveField(3)
  set createdAt(int value);
  @override
  @HiveField(4)
  String get description;
  @HiveField(4)
  set description(String value);
  @override
  @HiveField(5)
  TodoPriority get priority;
  @HiveField(5)
  set priority(TodoPriority value);
  @override
  @HiveField(6)
  int get finishedAt;
  @HiveField(6)
  set finishedAt(int value);
  @override
  @HiveField(7)
  TodoStatus get status;
  @HiveField(7)
  set status(TodoStatus value);
  @override
  @HiveField(8)
  int get reminders;
  @HiveField(8)
  set reminders(int value);
  @override
  @HiveField(9)
  int get progress;
  @HiveField(9)
  set progress(int value);
  @override
  @JsonKey(ignore: true)
  _$$_TodoCopyWith<_$_Todo> get copyWith => throw _privateConstructorUsedError;
}
