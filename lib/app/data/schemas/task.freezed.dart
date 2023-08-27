// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Task {
  @HiveField(0)
  int get id => throw _privateConstructorUsedError;
  @HiveField(0)
  set id(int value) => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(1)
  set title(String value) => throw _privateConstructorUsedError;
  @HiveField(2)
  List<String> get tags => throw _privateConstructorUsedError;
  @HiveField(2)
  set tags(List<String> value) => throw _privateConstructorUsedError;
  @HiveField(3)
  List<Todo> get todos => throw _privateConstructorUsedError;
  @HiveField(3)
  set todos(List<Todo> value) => throw _privateConstructorUsedError;
  @HiveField(4)
  int get createdAt => throw _privateConstructorUsedError;
  @HiveField(4)
  set createdAt(int value) => throw _privateConstructorUsedError;
  @HiveField(5)
  String get description => throw _privateConstructorUsedError;
  @HiveField(5)
  set description(String value) => throw _privateConstructorUsedError;
  @HiveField(6)
  int get finishedAt => throw _privateConstructorUsedError;
  @HiveField(6)
  set finishedAt(int value) => throw _privateConstructorUsedError;
  @HiveField(7)
  TaskStatus get status => throw _privateConstructorUsedError;
  @HiveField(7)
  set status(TaskStatus value) => throw _privateConstructorUsedError;
  @HiveField(8)
  int get progress => throw _privateConstructorUsedError;
  @HiveField(8)
  set progress(int value) => throw _privateConstructorUsedError;
  @HiveField(9)
  int get reminders => throw _privateConstructorUsedError;
  @HiveField(9)
  set reminders(int value) => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call(
      {@HiveField(0) int id,
      @HiveField(1) String title,
      @HiveField(2) List<String> tags,
      @HiveField(3) List<Todo> todos,
      @HiveField(4) int createdAt,
      @HiveField(5) String description,
      @HiveField(6) int finishedAt,
      @HiveField(7) TaskStatus status,
      @HiveField(8) int progress,
      @HiveField(9) int reminders});
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

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
    Object? todos = null,
    Object? createdAt = null,
    Object? description = null,
    Object? finishedAt = null,
    Object? status = null,
    Object? progress = null,
    Object? reminders = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      todos: null == todos
          ? _value.todos
          : todos // ignore: cast_nullable_to_non_nullable
              as List<Todo>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      finishedAt: null == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      reminders: null == reminders
          ? _value.reminders
          : reminders // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$_TaskCopyWith(_$_Task value, $Res Function(_$_Task) then) =
      __$$_TaskCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) int id,
      @HiveField(1) String title,
      @HiveField(2) List<String> tags,
      @HiveField(3) List<Todo> todos,
      @HiveField(4) int createdAt,
      @HiveField(5) String description,
      @HiveField(6) int finishedAt,
      @HiveField(7) TaskStatus status,
      @HiveField(8) int progress,
      @HiveField(9) int reminders});
}

/// @nodoc
class __$$_TaskCopyWithImpl<$Res> extends _$TaskCopyWithImpl<$Res, _$_Task>
    implements _$$_TaskCopyWith<$Res> {
  __$$_TaskCopyWithImpl(_$_Task _value, $Res Function(_$_Task) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? tags = null,
    Object? todos = null,
    Object? createdAt = null,
    Object? description = null,
    Object? finishedAt = null,
    Object? status = null,
    Object? progress = null,
    Object? reminders = null,
  }) {
    return _then(_$_Task(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      todos: null == todos
          ? _value.todos
          : todos // ignore: cast_nullable_to_non_nullable
              as List<Todo>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      finishedAt: null == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      reminders: null == reminders
          ? _value.reminders
          : reminders // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_Task with DiagnosticableTreeMixin implements _Task {
  _$_Task(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(2) required this.tags,
      @HiveField(3) required this.todos,
      @HiveField(4) required this.createdAt,
      @HiveField(5) this.description = "",
      @HiveField(6) this.finishedAt = 0,
      @HiveField(7) this.status = TaskStatus.todo,
      @HiveField(8) this.progress = 0,
      @HiveField(9) this.reminders = 0});

  @override
  @HiveField(0)
  int id;
  @override
  @HiveField(1)
  String title;
  @override
  @HiveField(2)
  List<String> tags;
  @override
  @HiveField(3)
  List<Todo> todos;
  @override
  @HiveField(4)
  int createdAt;
  @override
  @JsonKey()
  @HiveField(5)
  String description;
  @override
  @JsonKey()
  @HiveField(6)
  int finishedAt;
  @override
  @JsonKey()
  @HiveField(7)
  TaskStatus status;
  @override
  @JsonKey()
  @HiveField(8)
  int progress;
  @override
  @JsonKey()
  @HiveField(9)
  int reminders;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Task(id: $id, title: $title, tags: $tags, todos: $todos, createdAt: $createdAt, description: $description, finishedAt: $finishedAt, status: $status, progress: $progress, reminders: $reminders)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Task'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('todos', todos))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('finishedAt', finishedAt))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('progress', progress))
      ..add(DiagnosticsProperty('reminders', reminders));
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TaskCopyWith<_$_Task> get copyWith =>
      __$$_TaskCopyWithImpl<_$_Task>(this, _$identity);
}

abstract class _Task implements Task {
  factory _Task(
      {@HiveField(0) required int id,
      @HiveField(1) required String title,
      @HiveField(2) required List<String> tags,
      @HiveField(3) required List<Todo> todos,
      @HiveField(4) required int createdAt,
      @HiveField(5) String description,
      @HiveField(6) int finishedAt,
      @HiveField(7) TaskStatus status,
      @HiveField(8) int progress,
      @HiveField(9) int reminders}) = _$_Task;

  @override
  @HiveField(0)
  int get id;
  @HiveField(0)
  set id(int value);
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
  List<Todo> get todos;
  @HiveField(3)
  set todos(List<Todo> value);
  @override
  @HiveField(4)
  int get createdAt;
  @HiveField(4)
  set createdAt(int value);
  @override
  @HiveField(5)
  String get description;
  @HiveField(5)
  set description(String value);
  @override
  @HiveField(6)
  int get finishedAt;
  @HiveField(6)
  set finishedAt(int value);
  @override
  @HiveField(7)
  TaskStatus get status;
  @HiveField(7)
  set status(TaskStatus value);
  @override
  @HiveField(8)
  int get progress;
  @HiveField(8)
  set progress(int value);
  @override
  @HiveField(9)
  int get reminders;
  @HiveField(9)
  set reminders(int value);
  @override
  @JsonKey(ignore: true)
  _$$_TaskCopyWith<_$_Task> get copyWith => throw _privateConstructorUsedError;
}
