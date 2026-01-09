// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, Workspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, uuid, name, createdAt, order, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(Insertable<Workspace> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workspace(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class Workspace extends DataClass implements Insertable<Workspace> {
  final int id;
  final String uuid;
  final String name;
  final int createdAt;
  final int order;
  final int deletedAt;
  const Workspace(
      {required this.id,
      required this.uuid,
      required this.name,
      required this.createdAt,
      required this.order,
      required this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['order'] = Variable<int>(order);
    map['deleted_at'] = Variable<int>(deletedAt);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      createdAt: Value(createdAt),
      order: Value(order),
      deletedAt: Value(deletedAt),
    );
  }

  factory Workspace.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workspace(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      order: serializer.fromJson<int>(json['order']),
      deletedAt: serializer.fromJson<int>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'order': serializer.toJson<int>(order),
      'deletedAt': serializer.toJson<int>(deletedAt),
    };
  }

  Workspace copyWith(
          {int? id,
          String? uuid,
          String? name,
          int? createdAt,
          int? order,
          int? deletedAt}) =>
      Workspace(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        order: order ?? this.order,
        deletedAt: deletedAt ?? this.deletedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Workspace(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('order: $order, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, name, createdAt, order, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workspace &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.order == this.order &&
          other.deletedAt == this.deletedAt);
}

class WorkspacesCompanion extends UpdateCompanion<Workspace> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> order;
  final Value<int> deletedAt;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.order = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required int createdAt,
    this.order = const Value.absent(),
    this.deletedAt = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Workspace> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? order,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (order != null) 'order': order,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  WorkspacesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<int>? createdAt,
      Value<int>? order,
      Value<int>? deletedAt}) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('order: $order, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _workspaceIdMeta =
      const VerificationMeta('workspaceId');
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
      'workspace_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default'));
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title =
      GeneratedColumn<String>('title', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<int> finishedAt = GeneratedColumn<int>(
      'finished_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
      'progress', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _remindersMeta =
      const VerificationMeta('reminders');
  @override
  late final GeneratedColumn<int> reminders = GeneratedColumn<int>(
      'reminders', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _tagsWithColorJsonStringMeta =
      const VerificationMeta('tagsWithColorJsonString');
  @override
  late final GeneratedColumn<String> tagsWithColorJsonString =
      GeneratedColumn<String>('tags_with_color_json_string', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _customColorMeta =
      const VerificationMeta('customColor');
  @override
  late final GeneratedColumn<int> customColor = GeneratedColumn<int>(
      'custom_color', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _customIconMeta =
      const VerificationMeta('customIcon');
  @override
  late final GeneratedColumn<int> customIcon = GeneratedColumn<int>(
      'custom_icon', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        workspaceId,
        order,
        title,
        createdAt,
        description,
        finishedAt,
        status,
        progress,
        reminders,
        tags,
        tagsWithColorJsonString,
        deletedAt,
        customColor,
        customIcon
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
          _workspaceIdMeta,
          workspaceId.isAcceptableOrUnknown(
              data['workspace_id']!, _workspaceIdMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('reminders')) {
      context.handle(_remindersMeta,
          reminders.isAcceptableOrUnknown(data['reminders']!, _remindersMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('tags_with_color_json_string')) {
      context.handle(
          _tagsWithColorJsonStringMeta,
          tagsWithColorJsonString.isAcceptableOrUnknown(
              data['tags_with_color_json_string']!,
              _tagsWithColorJsonStringMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('custom_color')) {
      context.handle(
          _customColorMeta,
          customColor.isAcceptableOrUnknown(
              data['custom_color']!, _customColorMeta));
    }
    if (data.containsKey('custom_icon')) {
      context.handle(
          _customIconMeta,
          customIcon.isAcceptableOrUnknown(
              data['custom_icon']!, _customIconMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      workspaceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workspace_id'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}finished_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress'])!,
      reminders: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminders'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      tagsWithColorJsonString: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags_with_color_json_string'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])!,
      customColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}custom_color']),
      customIcon: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}custom_icon']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String uuid;
  final String workspaceId;
  final int order;
  final String title;
  final int createdAt;
  final String description;
  final int finishedAt;
  final int status;
  final int progress;
  final int reminders;
  final String tags;
  final String tagsWithColorJsonString;
  final int deletedAt;
  final int? customColor;
  final int? customIcon;
  const Task(
      {required this.id,
      required this.uuid,
      required this.workspaceId,
      required this.order,
      required this.title,
      required this.createdAt,
      required this.description,
      required this.finishedAt,
      required this.status,
      required this.progress,
      required this.reminders,
      required this.tags,
      required this.tagsWithColorJsonString,
      required this.deletedAt,
      this.customColor,
      this.customIcon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['order'] = Variable<int>(order);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<int>(createdAt);
    map['description'] = Variable<String>(description);
    map['finished_at'] = Variable<int>(finishedAt);
    map['status'] = Variable<int>(status);
    map['progress'] = Variable<int>(progress);
    map['reminders'] = Variable<int>(reminders);
    map['tags'] = Variable<String>(tags);
    map['tags_with_color_json_string'] =
        Variable<String>(tagsWithColorJsonString);
    map['deleted_at'] = Variable<int>(deletedAt);
    if (!nullToAbsent || customColor != null) {
      map['custom_color'] = Variable<int>(customColor);
    }
    if (!nullToAbsent || customIcon != null) {
      map['custom_icon'] = Variable<int>(customIcon);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      uuid: Value(uuid),
      workspaceId: Value(workspaceId),
      order: Value(order),
      title: Value(title),
      createdAt: Value(createdAt),
      description: Value(description),
      finishedAt: Value(finishedAt),
      status: Value(status),
      progress: Value(progress),
      reminders: Value(reminders),
      tags: Value(tags),
      tagsWithColorJsonString: Value(tagsWithColorJsonString),
      deletedAt: Value(deletedAt),
      customColor: customColor == null && nullToAbsent
          ? const Value.absent()
          : Value(customColor),
      customIcon: customIcon == null && nullToAbsent
          ? const Value.absent()
          : Value(customIcon),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      order: serializer.fromJson<int>(json['order']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      description: serializer.fromJson<String>(json['description']),
      finishedAt: serializer.fromJson<int>(json['finishedAt']),
      status: serializer.fromJson<int>(json['status']),
      progress: serializer.fromJson<int>(json['progress']),
      reminders: serializer.fromJson<int>(json['reminders']),
      tags: serializer.fromJson<String>(json['tags']),
      tagsWithColorJsonString:
          serializer.fromJson<String>(json['tagsWithColorJsonString']),
      deletedAt: serializer.fromJson<int>(json['deletedAt']),
      customColor: serializer.fromJson<int?>(json['customColor']),
      customIcon: serializer.fromJson<int?>(json['customIcon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'order': serializer.toJson<int>(order),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<int>(createdAt),
      'description': serializer.toJson<String>(description),
      'finishedAt': serializer.toJson<int>(finishedAt),
      'status': serializer.toJson<int>(status),
      'progress': serializer.toJson<int>(progress),
      'reminders': serializer.toJson<int>(reminders),
      'tags': serializer.toJson<String>(tags),
      'tagsWithColorJsonString':
          serializer.toJson<String>(tagsWithColorJsonString),
      'deletedAt': serializer.toJson<int>(deletedAt),
      'customColor': serializer.toJson<int?>(customColor),
      'customIcon': serializer.toJson<int?>(customIcon),
    };
  }

  Task copyWith(
          {int? id,
          String? uuid,
          String? workspaceId,
          int? order,
          String? title,
          int? createdAt,
          String? description,
          int? finishedAt,
          int? status,
          int? progress,
          int? reminders,
          String? tags,
          String? tagsWithColorJsonString,
          int? deletedAt,
          Value<int?> customColor = const Value.absent(),
          Value<int?> customIcon = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        workspaceId: workspaceId ?? this.workspaceId,
        order: order ?? this.order,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        description: description ?? this.description,
        finishedAt: finishedAt ?? this.finishedAt,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        reminders: reminders ?? this.reminders,
        tags: tags ?? this.tags,
        tagsWithColorJsonString:
            tagsWithColorJsonString ?? this.tagsWithColorJsonString,
        deletedAt: deletedAt ?? this.deletedAt,
        customColor: customColor.present ? customColor.value : this.customColor,
        customIcon: customIcon.present ? customIcon.value : this.customIcon,
      );
  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('order: $order, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('reminders: $reminders, ')
          ..write('tags: $tags, ')
          ..write('tagsWithColorJsonString: $tagsWithColorJsonString, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customColor: $customColor, ')
          ..write('customIcon: $customIcon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      workspaceId,
      order,
      title,
      createdAt,
      description,
      finishedAt,
      status,
      progress,
      reminders,
      tags,
      tagsWithColorJsonString,
      deletedAt,
      customColor,
      customIcon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.workspaceId == this.workspaceId &&
          other.order == this.order &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.description == this.description &&
          other.finishedAt == this.finishedAt &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.reminders == this.reminders &&
          other.tags == this.tags &&
          other.tagsWithColorJsonString == this.tagsWithColorJsonString &&
          other.deletedAt == this.deletedAt &&
          other.customColor == this.customColor &&
          other.customIcon == this.customIcon);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> workspaceId;
  final Value<int> order;
  final Value<String> title;
  final Value<int> createdAt;
  final Value<String> description;
  final Value<int> finishedAt;
  final Value<int> status;
  final Value<int> progress;
  final Value<int> reminders;
  final Value<String> tags;
  final Value<String> tagsWithColorJsonString;
  final Value<int> deletedAt;
  final Value<int?> customColor;
  final Value<int?> customIcon;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.order = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.reminders = const Value.absent(),
    this.tags = const Value.absent(),
    this.tagsWithColorJsonString = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customColor = const Value.absent(),
    this.customIcon = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.workspaceId = const Value.absent(),
    this.order = const Value.absent(),
    required String title,
    required int createdAt,
    this.description = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.reminders = const Value.absent(),
    this.tags = const Value.absent(),
    this.tagsWithColorJsonString = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customColor = const Value.absent(),
    this.customIcon = const Value.absent(),
  })  : uuid = Value(uuid),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? workspaceId,
    Expression<int>? order,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<String>? description,
    Expression<int>? finishedAt,
    Expression<int>? status,
    Expression<int>? progress,
    Expression<int>? reminders,
    Expression<String>? tags,
    Expression<String>? tagsWithColorJsonString,
    Expression<int>? deletedAt,
    Expression<int>? customColor,
    Expression<int>? customIcon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (order != null) 'order': order,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (description != null) 'description': description,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (reminders != null) 'reminders': reminders,
      if (tags != null) 'tags': tags,
      if (tagsWithColorJsonString != null)
        'tags_with_color_json_string': tagsWithColorJsonString,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customColor != null) 'custom_color': customColor,
      if (customIcon != null) 'custom_icon': customIcon,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? workspaceId,
      Value<int>? order,
      Value<String>? title,
      Value<int>? createdAt,
      Value<String>? description,
      Value<int>? finishedAt,
      Value<int>? status,
      Value<int>? progress,
      Value<int>? reminders,
      Value<String>? tags,
      Value<String>? tagsWithColorJsonString,
      Value<int>? deletedAt,
      Value<int?>? customColor,
      Value<int?>? customIcon}) {
    return TasksCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      workspaceId: workspaceId ?? this.workspaceId,
      order: order ?? this.order,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      finishedAt: finishedAt ?? this.finishedAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      reminders: reminders ?? this.reminders,
      tags: tags ?? this.tags,
      tagsWithColorJsonString:
          tagsWithColorJsonString ?? this.tagsWithColorJsonString,
      deletedAt: deletedAt ?? this.deletedAt,
      customColor: customColor ?? this.customColor,
      customIcon: customIcon ?? this.customIcon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (reminders.present) {
      map['reminders'] = Variable<int>(reminders.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (tagsWithColorJsonString.present) {
      map['tags_with_color_json_string'] =
          Variable<String>(tagsWithColorJsonString.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (customColor.present) {
      map['custom_color'] = Variable<int>(customColor.value);
    }
    if (customIcon.present) {
      map['custom_icon'] = Variable<int>(customIcon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('order: $order, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('reminders: $reminders, ')
          ..write('tags: $tags, ')
          ..write('tagsWithColorJsonString: $tagsWithColorJsonString, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customColor: $customColor, ')
          ..write('customIcon: $customIcon')
          ..write(')'))
        .toString();
  }
}

class $TodosTable extends Todos with TableInfo<$TodosTable, Todo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskUuidMeta =
      const VerificationMeta('taskUuid');
  @override
  late final GeneratedColumn<String> taskUuid = GeneratedColumn<String>(
      'task_uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title =
      GeneratedColumn<String>('title', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<int> finishedAt = GeneratedColumn<int>(
      'finished_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<int> dueDate = GeneratedColumn<int>(
      'due_date', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _remindersMeta =
      const VerificationMeta('reminders');
  @override
  late final GeneratedColumn<int> reminders = GeneratedColumn<int>(
      'reminders', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
      'progress', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
      'images', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _tagsWithColorJsonStringMeta =
      const VerificationMeta('tagsWithColorJsonString');
  @override
  late final GeneratedColumn<String> tagsWithColorJsonString =
      GeneratedColumn<String>('tags_with_color_json_string', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taskUuid,
        uuid,
        title,
        createdAt,
        description,
        priority,
        finishedAt,
        dueDate,
        status,
        reminders,
        progress,
        images,
        tags,
        tagsWithColorJsonString,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(Insertable<Todo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_uuid')) {
      context.handle(_taskUuidMeta,
          taskUuid.isAcceptableOrUnknown(data['task_uuid']!, _taskUuidMeta));
    } else if (isInserting) {
      context.missing(_taskUuidMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('reminders')) {
      context.handle(_remindersMeta,
          reminders.isAcceptableOrUnknown(data['reminders']!, _remindersMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('images')) {
      context.handle(_imagesMeta,
          images.isAcceptableOrUnknown(data['images']!, _imagesMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('tags_with_color_json_string')) {
      context.handle(
          _tagsWithColorJsonStringMeta,
          tagsWithColorJsonString.isAcceptableOrUnknown(
              data['tags_with_color_json_string']!,
              _tagsWithColorJsonStringMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Todo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Todo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_uuid'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}finished_at'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      reminders: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminders'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress'])!,
      images: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      tagsWithColorJsonString: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags_with_color_json_string'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])!,
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class Todo extends DataClass implements Insertable<Todo> {
  final int id;
  final String taskUuid;
  final String uuid;
  final String title;
  final int createdAt;
  final String description;
  final int priority;
  final int finishedAt;
  final int dueDate;
  final int status;
  final int reminders;
  final int progress;
  final String images;
  final String tags;
  final String tagsWithColorJsonString;
  final int deletedAt;
  const Todo(
      {required this.id,
      required this.taskUuid,
      required this.uuid,
      required this.title,
      required this.createdAt,
      required this.description,
      required this.priority,
      required this.finishedAt,
      required this.dueDate,
      required this.status,
      required this.reminders,
      required this.progress,
      required this.images,
      required this.tags,
      required this.tagsWithColorJsonString,
      required this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_uuid'] = Variable<String>(taskUuid);
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<int>(createdAt);
    map['description'] = Variable<String>(description);
    map['priority'] = Variable<int>(priority);
    map['finished_at'] = Variable<int>(finishedAt);
    map['due_date'] = Variable<int>(dueDate);
    map['status'] = Variable<int>(status);
    map['reminders'] = Variable<int>(reminders);
    map['progress'] = Variable<int>(progress);
    map['images'] = Variable<String>(images);
    map['tags'] = Variable<String>(tags);
    map['tags_with_color_json_string'] =
        Variable<String>(tagsWithColorJsonString);
    map['deleted_at'] = Variable<int>(deletedAt);
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      taskUuid: Value(taskUuid),
      uuid: Value(uuid),
      title: Value(title),
      createdAt: Value(createdAt),
      description: Value(description),
      priority: Value(priority),
      finishedAt: Value(finishedAt),
      dueDate: Value(dueDate),
      status: Value(status),
      reminders: Value(reminders),
      progress: Value(progress),
      images: Value(images),
      tags: Value(tags),
      tagsWithColorJsonString: Value(tagsWithColorJsonString),
      deletedAt: Value(deletedAt),
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Todo(
      id: serializer.fromJson<int>(json['id']),
      taskUuid: serializer.fromJson<String>(json['taskUuid']),
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      description: serializer.fromJson<String>(json['description']),
      priority: serializer.fromJson<int>(json['priority']),
      finishedAt: serializer.fromJson<int>(json['finishedAt']),
      dueDate: serializer.fromJson<int>(json['dueDate']),
      status: serializer.fromJson<int>(json['status']),
      reminders: serializer.fromJson<int>(json['reminders']),
      progress: serializer.fromJson<int>(json['progress']),
      images: serializer.fromJson<String>(json['images']),
      tags: serializer.fromJson<String>(json['tags']),
      tagsWithColorJsonString:
          serializer.fromJson<String>(json['tagsWithColorJsonString']),
      deletedAt: serializer.fromJson<int>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskUuid': serializer.toJson<String>(taskUuid),
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<int>(createdAt),
      'description': serializer.toJson<String>(description),
      'priority': serializer.toJson<int>(priority),
      'finishedAt': serializer.toJson<int>(finishedAt),
      'dueDate': serializer.toJson<int>(dueDate),
      'status': serializer.toJson<int>(status),
      'reminders': serializer.toJson<int>(reminders),
      'progress': serializer.toJson<int>(progress),
      'images': serializer.toJson<String>(images),
      'tags': serializer.toJson<String>(tags),
      'tagsWithColorJsonString':
          serializer.toJson<String>(tagsWithColorJsonString),
      'deletedAt': serializer.toJson<int>(deletedAt),
    };
  }

  Todo copyWith(
          {int? id,
          String? taskUuid,
          String? uuid,
          String? title,
          int? createdAt,
          String? description,
          int? priority,
          int? finishedAt,
          int? dueDate,
          int? status,
          int? reminders,
          int? progress,
          String? images,
          String? tags,
          String? tagsWithColorJsonString,
          int? deletedAt}) =>
      Todo(
        id: id ?? this.id,
        taskUuid: taskUuid ?? this.taskUuid,
        uuid: uuid ?? this.uuid,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        finishedAt: finishedAt ?? this.finishedAt,
        dueDate: dueDate ?? this.dueDate,
        status: status ?? this.status,
        reminders: reminders ?? this.reminders,
        progress: progress ?? this.progress,
        images: images ?? this.images,
        tags: tags ?? this.tags,
        tagsWithColorJsonString:
            tagsWithColorJsonString ?? this.tagsWithColorJsonString,
        deletedAt: deletedAt ?? this.deletedAt,
      );
  @override
  String toString() {
    return (StringBuffer('Todo(')
          ..write('id: $id, ')
          ..write('taskUuid: $taskUuid, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('reminders: $reminders, ')
          ..write('progress: $progress, ')
          ..write('images: $images, ')
          ..write('tags: $tags, ')
          ..write('tagsWithColorJsonString: $tagsWithColorJsonString, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      taskUuid,
      uuid,
      title,
      createdAt,
      description,
      priority,
      finishedAt,
      dueDate,
      status,
      reminders,
      progress,
      images,
      tags,
      tagsWithColorJsonString,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Todo &&
          other.id == this.id &&
          other.taskUuid == this.taskUuid &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.finishedAt == this.finishedAt &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.reminders == this.reminders &&
          other.progress == this.progress &&
          other.images == this.images &&
          other.tags == this.tags &&
          other.tagsWithColorJsonString == this.tagsWithColorJsonString &&
          other.deletedAt == this.deletedAt);
}

class TodosCompanion extends UpdateCompanion<Todo> {
  final Value<int> id;
  final Value<String> taskUuid;
  final Value<String> uuid;
  final Value<String> title;
  final Value<int> createdAt;
  final Value<String> description;
  final Value<int> priority;
  final Value<int> finishedAt;
  final Value<int> dueDate;
  final Value<int> status;
  final Value<int> reminders;
  final Value<int> progress;
  final Value<String> images;
  final Value<String> tags;
  final Value<String> tagsWithColorJsonString;
  final Value<int> deletedAt;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.taskUuid = const Value.absent(),
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.reminders = const Value.absent(),
    this.progress = const Value.absent(),
    this.images = const Value.absent(),
    this.tags = const Value.absent(),
    this.tagsWithColorJsonString = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TodosCompanion.insert({
    this.id = const Value.absent(),
    required String taskUuid,
    required String uuid,
    required String title,
    required int createdAt,
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.reminders = const Value.absent(),
    this.progress = const Value.absent(),
    this.images = const Value.absent(),
    this.tags = const Value.absent(),
    this.tagsWithColorJsonString = const Value.absent(),
    this.deletedAt = const Value.absent(),
  })  : taskUuid = Value(taskUuid),
        uuid = Value(uuid),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<Todo> custom({
    Expression<int>? id,
    Expression<String>? taskUuid,
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<String>? description,
    Expression<int>? priority,
    Expression<int>? finishedAt,
    Expression<int>? dueDate,
    Expression<int>? status,
    Expression<int>? reminders,
    Expression<int>? progress,
    Expression<String>? images,
    Expression<String>? tags,
    Expression<String>? tagsWithColorJsonString,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskUuid != null) 'task_uuid': taskUuid,
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (reminders != null) 'reminders': reminders,
      if (progress != null) 'progress': progress,
      if (images != null) 'images': images,
      if (tags != null) 'tags': tags,
      if (tagsWithColorJsonString != null)
        'tags_with_color_json_string': tagsWithColorJsonString,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  TodosCompanion copyWith(
      {Value<int>? id,
      Value<String>? taskUuid,
      Value<String>? uuid,
      Value<String>? title,
      Value<int>? createdAt,
      Value<String>? description,
      Value<int>? priority,
      Value<int>? finishedAt,
      Value<int>? dueDate,
      Value<int>? status,
      Value<int>? reminders,
      Value<int>? progress,
      Value<String>? images,
      Value<String>? tags,
      Value<String>? tagsWithColorJsonString,
      Value<int>? deletedAt}) {
    return TodosCompanion(
      id: id ?? this.id,
      taskUuid: taskUuid ?? this.taskUuid,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      finishedAt: finishedAt ?? this.finishedAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      progress: progress ?? this.progress,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      tagsWithColorJsonString:
          tagsWithColorJsonString ?? this.tagsWithColorJsonString,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskUuid.present) {
      map['task_uuid'] = Variable<String>(taskUuid.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<int>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (reminders.present) {
      map['reminders'] = Variable<int>(reminders.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (tagsWithColorJsonString.present) {
      map['tags_with_color_json_string'] =
          Variable<String>(tagsWithColorJsonString.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('taskUuid: $taskUuid, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('reminders: $reminders, ')
          ..write('progress: $progress, ')
          ..write('images: $images, ')
          ..write('tags: $tags, ')
          ..write('tagsWithColorJsonString: $tagsWithColorJsonString, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $AppConfigsTable extends AppConfigs
    with TableInfo<$AppConfigsTable, AppConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _configNameMeta =
      const VerificationMeta('configName');
  @override
  late final GeneratedColumn<String> configName =
      GeneratedColumn<String>('config_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _isDarkModeMeta =
      const VerificationMeta('isDarkMode');
  @override
  late final GeneratedColumn<bool> isDarkMode = GeneratedColumn<bool>(
      'is_dark_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_dark_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _languageCodeMeta =
      const VerificationMeta('languageCode');
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
      'language_code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _countryCodeMeta =
      const VerificationMeta('countryCode');
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
      'country_code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _emailReminderEnabledMeta =
      const VerificationMeta('emailReminderEnabled');
  @override
  late final GeneratedColumn<bool> emailReminderEnabled = GeneratedColumn<bool>(
      'email_reminder_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("email_reminder_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDebugModeMeta =
      const VerificationMeta('isDebugMode');
  @override
  late final GeneratedColumn<bool> isDebugMode = GeneratedColumn<bool>(
      'is_debug_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_debug_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _backgroundImagePathMeta =
      const VerificationMeta('backgroundImagePath');
  @override
  late final GeneratedColumn<String> backgroundImagePath =
      GeneratedColumn<String>('background_image_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _primaryColorValueMeta =
      const VerificationMeta('primaryColorValue');
  @override
  late final GeneratedColumn<int> primaryColorValue = GeneratedColumn<int>(
      'primary_color_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _backgroundImageOpacityMeta =
      const VerificationMeta('backgroundImageOpacity');
  @override
  late final GeneratedColumn<double> backgroundImageOpacity =
      GeneratedColumn<double>('background_image_opacity', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.15));
  static const VerificationMeta _backgroundImageBlurMeta =
      const VerificationMeta('backgroundImageBlur');
  @override
  late final GeneratedColumn<double> backgroundImageBlur =
      GeneratedColumn<double>('background_image_blur', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _backgroundAffectsNavBarMeta =
      const VerificationMeta('backgroundAffectsNavBar');
  @override
  late final GeneratedColumn<bool> backgroundAffectsNavBar =
      GeneratedColumn<bool>('background_affects_nav_bar', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("background_affects_nav_bar" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _showTodoImageMeta =
      const VerificationMeta('showTodoImage');
  @override
  late final GeneratedColumn<bool> showTodoImage = GeneratedColumn<bool>(
      'show_todo_image', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_todo_image" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        configName,
        isDarkMode,
        languageCode,
        countryCode,
        emailReminderEnabled,
        isDebugMode,
        backgroundImagePath,
        primaryColorValue,
        backgroundImageOpacity,
        backgroundImageBlur,
        backgroundAffectsNavBar,
        showTodoImage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_configs';
  @override
  VerificationContext validateIntegrity(Insertable<AppConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('config_name')) {
      context.handle(
          _configNameMeta,
          configName.isAcceptableOrUnknown(
              data['config_name']!, _configNameMeta));
    } else if (isInserting) {
      context.missing(_configNameMeta);
    }
    if (data.containsKey('is_dark_mode')) {
      context.handle(
          _isDarkModeMeta,
          isDarkMode.isAcceptableOrUnknown(
              data['is_dark_mode']!, _isDarkModeMeta));
    }
    if (data.containsKey('language_code')) {
      context.handle(
          _languageCodeMeta,
          languageCode.isAcceptableOrUnknown(
              data['language_code']!, _languageCodeMeta));
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
          _countryCodeMeta,
          countryCode.isAcceptableOrUnknown(
              data['country_code']!, _countryCodeMeta));
    }
    if (data.containsKey('email_reminder_enabled')) {
      context.handle(
          _emailReminderEnabledMeta,
          emailReminderEnabled.isAcceptableOrUnknown(
              data['email_reminder_enabled']!, _emailReminderEnabledMeta));
    }
    if (data.containsKey('is_debug_mode')) {
      context.handle(
          _isDebugModeMeta,
          isDebugMode.isAcceptableOrUnknown(
              data['is_debug_mode']!, _isDebugModeMeta));
    }
    if (data.containsKey('background_image_path')) {
      context.handle(
          _backgroundImagePathMeta,
          backgroundImagePath.isAcceptableOrUnknown(
              data['background_image_path']!, _backgroundImagePathMeta));
    }
    if (data.containsKey('primary_color_value')) {
      context.handle(
          _primaryColorValueMeta,
          primaryColorValue.isAcceptableOrUnknown(
              data['primary_color_value']!, _primaryColorValueMeta));
    }
    if (data.containsKey('background_image_opacity')) {
      context.handle(
          _backgroundImageOpacityMeta,
          backgroundImageOpacity.isAcceptableOrUnknown(
              data['background_image_opacity']!, _backgroundImageOpacityMeta));
    }
    if (data.containsKey('background_image_blur')) {
      context.handle(
          _backgroundImageBlurMeta,
          backgroundImageBlur.isAcceptableOrUnknown(
              data['background_image_blur']!, _backgroundImageBlurMeta));
    }
    if (data.containsKey('background_affects_nav_bar')) {
      context.handle(
          _backgroundAffectsNavBarMeta,
          backgroundAffectsNavBar.isAcceptableOrUnknown(
              data['background_affects_nav_bar']!,
              _backgroundAffectsNavBarMeta));
    }
    if (data.containsKey('show_todo_image')) {
      context.handle(
          _showTodoImageMeta,
          showTodoImage.isAcceptableOrUnknown(
              data['show_todo_image']!, _showTodoImageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppConfig(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      configName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}config_name'])!,
      isDarkMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dark_mode'])!,
      languageCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language_code'])!,
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code'])!,
      emailReminderEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}email_reminder_enabled'])!,
      isDebugMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_debug_mode'])!,
      backgroundImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}background_image_path']),
      primaryColorValue: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}primary_color_value']),
      backgroundImageOpacity: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}background_image_opacity'])!,
      backgroundImageBlur: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}background_image_blur'])!,
      backgroundAffectsNavBar: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}background_affects_nav_bar'])!,
      showTodoImage: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_todo_image'])!,
    );
  }

  @override
  $AppConfigsTable createAlias(String alias) {
    return $AppConfigsTable(attachedDatabase, alias);
  }
}

class AppConfig extends DataClass implements Insertable<AppConfig> {
  final int id;
  final String configName;
  final bool isDarkMode;
  final String languageCode;
  final String countryCode;
  final bool emailReminderEnabled;
  final bool isDebugMode;
  final String? backgroundImagePath;
  final int? primaryColorValue;
  final double backgroundImageOpacity;
  final double backgroundImageBlur;
  final bool backgroundAffectsNavBar;
  final bool showTodoImage;
  const AppConfig(
      {required this.id,
      required this.configName,
      required this.isDarkMode,
      required this.languageCode,
      required this.countryCode,
      required this.emailReminderEnabled,
      required this.isDebugMode,
      this.backgroundImagePath,
      this.primaryColorValue,
      required this.backgroundImageOpacity,
      required this.backgroundImageBlur,
      required this.backgroundAffectsNavBar,
      required this.showTodoImage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['config_name'] = Variable<String>(configName);
    map['is_dark_mode'] = Variable<bool>(isDarkMode);
    map['language_code'] = Variable<String>(languageCode);
    map['country_code'] = Variable<String>(countryCode);
    map['email_reminder_enabled'] = Variable<bool>(emailReminderEnabled);
    map['is_debug_mode'] = Variable<bool>(isDebugMode);
    if (!nullToAbsent || backgroundImagePath != null) {
      map['background_image_path'] = Variable<String>(backgroundImagePath);
    }
    if (!nullToAbsent || primaryColorValue != null) {
      map['primary_color_value'] = Variable<int>(primaryColorValue);
    }
    map['background_image_opacity'] = Variable<double>(backgroundImageOpacity);
    map['background_image_blur'] = Variable<double>(backgroundImageBlur);
    map['background_affects_nav_bar'] = Variable<bool>(backgroundAffectsNavBar);
    map['show_todo_image'] = Variable<bool>(showTodoImage);
    return map;
  }

  AppConfigsCompanion toCompanion(bool nullToAbsent) {
    return AppConfigsCompanion(
      id: Value(id),
      configName: Value(configName),
      isDarkMode: Value(isDarkMode),
      languageCode: Value(languageCode),
      countryCode: Value(countryCode),
      emailReminderEnabled: Value(emailReminderEnabled),
      isDebugMode: Value(isDebugMode),
      backgroundImagePath: backgroundImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(backgroundImagePath),
      primaryColorValue: primaryColorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryColorValue),
      backgroundImageOpacity: Value(backgroundImageOpacity),
      backgroundImageBlur: Value(backgroundImageBlur),
      backgroundAffectsNavBar: Value(backgroundAffectsNavBar),
      showTodoImage: Value(showTodoImage),
    );
  }

  factory AppConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppConfig(
      id: serializer.fromJson<int>(json['id']),
      configName: serializer.fromJson<String>(json['configName']),
      isDarkMode: serializer.fromJson<bool>(json['isDarkMode']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      emailReminderEnabled:
          serializer.fromJson<bool>(json['emailReminderEnabled']),
      isDebugMode: serializer.fromJson<bool>(json['isDebugMode']),
      backgroundImagePath:
          serializer.fromJson<String?>(json['backgroundImagePath']),
      primaryColorValue: serializer.fromJson<int?>(json['primaryColorValue']),
      backgroundImageOpacity:
          serializer.fromJson<double>(json['backgroundImageOpacity']),
      backgroundImageBlur:
          serializer.fromJson<double>(json['backgroundImageBlur']),
      backgroundAffectsNavBar:
          serializer.fromJson<bool>(json['backgroundAffectsNavBar']),
      showTodoImage: serializer.fromJson<bool>(json['showTodoImage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'configName': serializer.toJson<String>(configName),
      'isDarkMode': serializer.toJson<bool>(isDarkMode),
      'languageCode': serializer.toJson<String>(languageCode),
      'countryCode': serializer.toJson<String>(countryCode),
      'emailReminderEnabled': serializer.toJson<bool>(emailReminderEnabled),
      'isDebugMode': serializer.toJson<bool>(isDebugMode),
      'backgroundImagePath': serializer.toJson<String?>(backgroundImagePath),
      'primaryColorValue': serializer.toJson<int?>(primaryColorValue),
      'backgroundImageOpacity':
          serializer.toJson<double>(backgroundImageOpacity),
      'backgroundImageBlur': serializer.toJson<double>(backgroundImageBlur),
      'backgroundAffectsNavBar':
          serializer.toJson<bool>(backgroundAffectsNavBar),
      'showTodoImage': serializer.toJson<bool>(showTodoImage),
    };
  }

  AppConfig copyWith(
          {int? id,
          String? configName,
          bool? isDarkMode,
          String? languageCode,
          String? countryCode,
          bool? emailReminderEnabled,
          bool? isDebugMode,
          Value<String?> backgroundImagePath = const Value.absent(),
          Value<int?> primaryColorValue = const Value.absent(),
          double? backgroundImageOpacity,
          double? backgroundImageBlur,
          bool? backgroundAffectsNavBar,
          bool? showTodoImage}) =>
      AppConfig(
        id: id ?? this.id,
        configName: configName ?? this.configName,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        languageCode: languageCode ?? this.languageCode,
        countryCode: countryCode ?? this.countryCode,
        emailReminderEnabled: emailReminderEnabled ?? this.emailReminderEnabled,
        isDebugMode: isDebugMode ?? this.isDebugMode,
        backgroundImagePath: backgroundImagePath.present
            ? backgroundImagePath.value
            : this.backgroundImagePath,
        primaryColorValue: primaryColorValue.present
            ? primaryColorValue.value
            : this.primaryColorValue,
        backgroundImageOpacity:
            backgroundImageOpacity ?? this.backgroundImageOpacity,
        backgroundImageBlur: backgroundImageBlur ?? this.backgroundImageBlur,
        backgroundAffectsNavBar:
            backgroundAffectsNavBar ?? this.backgroundAffectsNavBar,
        showTodoImage: showTodoImage ?? this.showTodoImage,
      );
  @override
  String toString() {
    return (StringBuffer('AppConfig(')
          ..write('id: $id, ')
          ..write('configName: $configName, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('languageCode: $languageCode, ')
          ..write('countryCode: $countryCode, ')
          ..write('emailReminderEnabled: $emailReminderEnabled, ')
          ..write('isDebugMode: $isDebugMode, ')
          ..write('backgroundImagePath: $backgroundImagePath, ')
          ..write('primaryColorValue: $primaryColorValue, ')
          ..write('backgroundImageOpacity: $backgroundImageOpacity, ')
          ..write('backgroundImageBlur: $backgroundImageBlur, ')
          ..write('backgroundAffectsNavBar: $backgroundAffectsNavBar, ')
          ..write('showTodoImage: $showTodoImage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      configName,
      isDarkMode,
      languageCode,
      countryCode,
      emailReminderEnabled,
      isDebugMode,
      backgroundImagePath,
      primaryColorValue,
      backgroundImageOpacity,
      backgroundImageBlur,
      backgroundAffectsNavBar,
      showTodoImage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppConfig &&
          other.id == this.id &&
          other.configName == this.configName &&
          other.isDarkMode == this.isDarkMode &&
          other.languageCode == this.languageCode &&
          other.countryCode == this.countryCode &&
          other.emailReminderEnabled == this.emailReminderEnabled &&
          other.isDebugMode == this.isDebugMode &&
          other.backgroundImagePath == this.backgroundImagePath &&
          other.primaryColorValue == this.primaryColorValue &&
          other.backgroundImageOpacity == this.backgroundImageOpacity &&
          other.backgroundImageBlur == this.backgroundImageBlur &&
          other.backgroundAffectsNavBar == this.backgroundAffectsNavBar &&
          other.showTodoImage == this.showTodoImage);
}

class AppConfigsCompanion extends UpdateCompanion<AppConfig> {
  final Value<int> id;
  final Value<String> configName;
  final Value<bool> isDarkMode;
  final Value<String> languageCode;
  final Value<String> countryCode;
  final Value<bool> emailReminderEnabled;
  final Value<bool> isDebugMode;
  final Value<String?> backgroundImagePath;
  final Value<int?> primaryColorValue;
  final Value<double> backgroundImageOpacity;
  final Value<double> backgroundImageBlur;
  final Value<bool> backgroundAffectsNavBar;
  final Value<bool> showTodoImage;
  const AppConfigsCompanion({
    this.id = const Value.absent(),
    this.configName = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.emailReminderEnabled = const Value.absent(),
    this.isDebugMode = const Value.absent(),
    this.backgroundImagePath = const Value.absent(),
    this.primaryColorValue = const Value.absent(),
    this.backgroundImageOpacity = const Value.absent(),
    this.backgroundImageBlur = const Value.absent(),
    this.backgroundAffectsNavBar = const Value.absent(),
    this.showTodoImage = const Value.absent(),
  });
  AppConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String configName,
    this.isDarkMode = const Value.absent(),
    required String languageCode,
    this.countryCode = const Value.absent(),
    this.emailReminderEnabled = const Value.absent(),
    this.isDebugMode = const Value.absent(),
    this.backgroundImagePath = const Value.absent(),
    this.primaryColorValue = const Value.absent(),
    this.backgroundImageOpacity = const Value.absent(),
    this.backgroundImageBlur = const Value.absent(),
    this.backgroundAffectsNavBar = const Value.absent(),
    this.showTodoImage = const Value.absent(),
  })  : configName = Value(configName),
        languageCode = Value(languageCode);
  static Insertable<AppConfig> custom({
    Expression<int>? id,
    Expression<String>? configName,
    Expression<bool>? isDarkMode,
    Expression<String>? languageCode,
    Expression<String>? countryCode,
    Expression<bool>? emailReminderEnabled,
    Expression<bool>? isDebugMode,
    Expression<String>? backgroundImagePath,
    Expression<int>? primaryColorValue,
    Expression<double>? backgroundImageOpacity,
    Expression<double>? backgroundImageBlur,
    Expression<bool>? backgroundAffectsNavBar,
    Expression<bool>? showTodoImage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (configName != null) 'config_name': configName,
      if (isDarkMode != null) 'is_dark_mode': isDarkMode,
      if (languageCode != null) 'language_code': languageCode,
      if (countryCode != null) 'country_code': countryCode,
      if (emailReminderEnabled != null)
        'email_reminder_enabled': emailReminderEnabled,
      if (isDebugMode != null) 'is_debug_mode': isDebugMode,
      if (backgroundImagePath != null)
        'background_image_path': backgroundImagePath,
      if (primaryColorValue != null) 'primary_color_value': primaryColorValue,
      if (backgroundImageOpacity != null)
        'background_image_opacity': backgroundImageOpacity,
      if (backgroundImageBlur != null)
        'background_image_blur': backgroundImageBlur,
      if (backgroundAffectsNavBar != null)
        'background_affects_nav_bar': backgroundAffectsNavBar,
      if (showTodoImage != null) 'show_todo_image': showTodoImage,
    });
  }

  AppConfigsCompanion copyWith(
      {Value<int>? id,
      Value<String>? configName,
      Value<bool>? isDarkMode,
      Value<String>? languageCode,
      Value<String>? countryCode,
      Value<bool>? emailReminderEnabled,
      Value<bool>? isDebugMode,
      Value<String?>? backgroundImagePath,
      Value<int?>? primaryColorValue,
      Value<double>? backgroundImageOpacity,
      Value<double>? backgroundImageBlur,
      Value<bool>? backgroundAffectsNavBar,
      Value<bool>? showTodoImage}) {
    return AppConfigsCompanion(
      id: id ?? this.id,
      configName: configName ?? this.configName,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      emailReminderEnabled: emailReminderEnabled ?? this.emailReminderEnabled,
      isDebugMode: isDebugMode ?? this.isDebugMode,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      backgroundImageOpacity:
          backgroundImageOpacity ?? this.backgroundImageOpacity,
      backgroundImageBlur: backgroundImageBlur ?? this.backgroundImageBlur,
      backgroundAffectsNavBar:
          backgroundAffectsNavBar ?? this.backgroundAffectsNavBar,
      showTodoImage: showTodoImage ?? this.showTodoImage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (configName.present) {
      map['config_name'] = Variable<String>(configName.value);
    }
    if (isDarkMode.present) {
      map['is_dark_mode'] = Variable<bool>(isDarkMode.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (emailReminderEnabled.present) {
      map['email_reminder_enabled'] =
          Variable<bool>(emailReminderEnabled.value);
    }
    if (isDebugMode.present) {
      map['is_debug_mode'] = Variable<bool>(isDebugMode.value);
    }
    if (backgroundImagePath.present) {
      map['background_image_path'] =
          Variable<String>(backgroundImagePath.value);
    }
    if (primaryColorValue.present) {
      map['primary_color_value'] = Variable<int>(primaryColorValue.value);
    }
    if (backgroundImageOpacity.present) {
      map['background_image_opacity'] =
          Variable<double>(backgroundImageOpacity.value);
    }
    if (backgroundImageBlur.present) {
      map['background_image_blur'] =
          Variable<double>(backgroundImageBlur.value);
    }
    if (backgroundAffectsNavBar.present) {
      map['background_affects_nav_bar'] =
          Variable<bool>(backgroundAffectsNavBar.value);
    }
    if (showTodoImage.present) {
      map['show_todo_image'] = Variable<bool>(showTodoImage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppConfigsCompanion(')
          ..write('id: $id, ')
          ..write('configName: $configName, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('languageCode: $languageCode, ')
          ..write('countryCode: $countryCode, ')
          ..write('emailReminderEnabled: $emailReminderEnabled, ')
          ..write('isDebugMode: $isDebugMode, ')
          ..write('backgroundImagePath: $backgroundImagePath, ')
          ..write('primaryColorValue: $primaryColorValue, ')
          ..write('backgroundImageOpacity: $backgroundImageOpacity, ')
          ..write('backgroundImageBlur: $backgroundImageBlur, ')
          ..write('backgroundAffectsNavBar: $backgroundAffectsNavBar, ')
          ..write('showTodoImage: $showTodoImage')
          ..write(')'))
        .toString();
  }
}

class $LocalNoticesTable extends LocalNotices
    with TableInfo<$LocalNoticesTable, LocalNotice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalNoticesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _noticeIdMeta =
      const VerificationMeta('noticeId');
  @override
  late final GeneratedColumn<String> noticeId =
      GeneratedColumn<String>('notice_id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title =
      GeneratedColumn<String>('title', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description =
      GeneratedColumn<String>('description', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _remindersAtMeta =
      const VerificationMeta('remindersAt');
  @override
  late final GeneratedColumn<int> remindersAt = GeneratedColumn<int>(
      'reminders_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email =
      GeneratedColumn<String>('email', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, noticeId, title, description, createdAt, remindersAt, email];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notices';
  @override
  VerificationContext validateIntegrity(Insertable<LocalNotice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notice_id')) {
      context.handle(_noticeIdMeta,
          noticeId.isAcceptableOrUnknown(data['notice_id']!, _noticeIdMeta));
    } else if (isInserting) {
      context.missing(_noticeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('reminders_at')) {
      context.handle(
          _remindersAtMeta,
          remindersAt.isAcceptableOrUnknown(
              data['reminders_at']!, _remindersAtMeta));
    } else if (isInserting) {
      context.missing(_remindersAtMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalNotice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNotice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      noticeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notice_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      remindersAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminders_at'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
    );
  }

  @override
  $LocalNoticesTable createAlias(String alias) {
    return $LocalNoticesTable(attachedDatabase, alias);
  }
}

class LocalNotice extends DataClass implements Insertable<LocalNotice> {
  final int id;
  final String noticeId;
  final String title;
  final String description;
  final int createdAt;
  final int remindersAt;
  final String email;
  const LocalNotice(
      {required this.id,
      required this.noticeId,
      required this.title,
      required this.description,
      required this.createdAt,
      required this.remindersAt,
      required this.email});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['notice_id'] = Variable<String>(noticeId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<int>(createdAt);
    map['reminders_at'] = Variable<int>(remindersAt);
    map['email'] = Variable<String>(email);
    return map;
  }

  LocalNoticesCompanion toCompanion(bool nullToAbsent) {
    return LocalNoticesCompanion(
      id: Value(id),
      noticeId: Value(noticeId),
      title: Value(title),
      description: Value(description),
      createdAt: Value(createdAt),
      remindersAt: Value(remindersAt),
      email: Value(email),
    );
  }

  factory LocalNotice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNotice(
      id: serializer.fromJson<int>(json['id']),
      noticeId: serializer.fromJson<String>(json['noticeId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      remindersAt: serializer.fromJson<int>(json['remindersAt']),
      email: serializer.fromJson<String>(json['email']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noticeId': serializer.toJson<String>(noticeId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<int>(createdAt),
      'remindersAt': serializer.toJson<int>(remindersAt),
      'email': serializer.toJson<String>(email),
    };
  }

  LocalNotice copyWith(
          {int? id,
          String? noticeId,
          String? title,
          String? description,
          int? createdAt,
          int? remindersAt,
          String? email}) =>
      LocalNotice(
        id: id ?? this.id,
        noticeId: noticeId ?? this.noticeId,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        remindersAt: remindersAt ?? this.remindersAt,
        email: email ?? this.email,
      );
  @override
  String toString() {
    return (StringBuffer('LocalNotice(')
          ..write('id: $id, ')
          ..write('noticeId: $noticeId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('remindersAt: $remindersAt, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, noticeId, title, description, createdAt, remindersAt, email);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNotice &&
          other.id == this.id &&
          other.noticeId == this.noticeId &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.remindersAt == this.remindersAt &&
          other.email == this.email);
}

class LocalNoticesCompanion extends UpdateCompanion<LocalNotice> {
  final Value<int> id;
  final Value<String> noticeId;
  final Value<String> title;
  final Value<String> description;
  final Value<int> createdAt;
  final Value<int> remindersAt;
  final Value<String> email;
  const LocalNoticesCompanion({
    this.id = const Value.absent(),
    this.noticeId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.remindersAt = const Value.absent(),
    this.email = const Value.absent(),
  });
  LocalNoticesCompanion.insert({
    this.id = const Value.absent(),
    required String noticeId,
    required String title,
    required String description,
    required int createdAt,
    required int remindersAt,
    required String email,
  })  : noticeId = Value(noticeId),
        title = Value(title),
        description = Value(description),
        createdAt = Value(createdAt),
        remindersAt = Value(remindersAt),
        email = Value(email);
  static Insertable<LocalNotice> custom({
    Expression<int>? id,
    Expression<String>? noticeId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? createdAt,
    Expression<int>? remindersAt,
    Expression<String>? email,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noticeId != null) 'notice_id': noticeId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (remindersAt != null) 'reminders_at': remindersAt,
      if (email != null) 'email': email,
    });
  }

  LocalNoticesCompanion copyWith(
      {Value<int>? id,
      Value<String>? noticeId,
      Value<String>? title,
      Value<String>? description,
      Value<int>? createdAt,
      Value<int>? remindersAt,
      Value<String>? email}) {
    return LocalNoticesCompanion(
      id: id ?? this.id,
      noticeId: noticeId ?? this.noticeId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      remindersAt: remindersAt ?? this.remindersAt,
      email: email ?? this.email,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noticeId.present) {
      map['notice_id'] = Variable<String>(noticeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (remindersAt.present) {
      map['reminders_at'] = Variable<int>(remindersAt.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalNoticesCompanion(')
          ..write('id: $id, ')
          ..write('noticeId: $noticeId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('remindersAt: $remindersAt, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }
}

class $NotificationHistorysTable extends NotificationHistorys
    with TableInfo<$NotificationHistorysTable, NotificationHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationHistorysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _notificationIdMeta =
      const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<String> notificationId =
      GeneratedColumn<String>('notification_id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title =
      GeneratedColumn<String>('title', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message =
      GeneratedColumn<String>('message', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, notificationId, title, message, level, timestamp, isRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_historys';
  @override
  VerificationContext validateIntegrity(
      Insertable<NotificationHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notification_id')) {
      context.handle(
          _notificationIdMeta,
          notificationId.isAcceptableOrUnknown(
              data['notification_id']!, _notificationIdMeta));
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationHistory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      notificationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}notification_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
    );
  }

  @override
  $NotificationHistorysTable createAlias(String alias) {
    return $NotificationHistorysTable(attachedDatabase, alias);
  }
}

class NotificationHistory extends DataClass
    implements Insertable<NotificationHistory> {
  final int id;
  final String notificationId;
  final String title;
  final String message;
  final int level;
  final DateTime timestamp;
  final bool isRead;
  const NotificationHistory(
      {required this.id,
      required this.notificationId,
      required this.title,
      required this.message,
      required this.level,
      required this.timestamp,
      required this.isRead});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['notification_id'] = Variable<String>(notificationId);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['level'] = Variable<int>(level);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  NotificationHistorysCompanion toCompanion(bool nullToAbsent) {
    return NotificationHistorysCompanion(
      id: Value(id),
      notificationId: Value(notificationId),
      title: Value(title),
      message: Value(message),
      level: Value(level),
      timestamp: Value(timestamp),
      isRead: Value(isRead),
    );
  }

  factory NotificationHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationHistory(
      id: serializer.fromJson<int>(json['id']),
      notificationId: serializer.fromJson<String>(json['notificationId']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      level: serializer.fromJson<int>(json['level']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'notificationId': serializer.toJson<String>(notificationId),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'level': serializer.toJson<int>(level),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  NotificationHistory copyWith(
          {int? id,
          String? notificationId,
          String? title,
          String? message,
          int? level,
          DateTime? timestamp,
          bool? isRead}) =>
      NotificationHistory(
        id: id ?? this.id,
        notificationId: notificationId ?? this.notificationId,
        title: title ?? this.title,
        message: message ?? this.message,
        level: level ?? this.level,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
      );
  @override
  String toString() {
    return (StringBuffer('NotificationHistory(')
          ..write('id: $id, ')
          ..write('notificationId: $notificationId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('level: $level, ')
          ..write('timestamp: $timestamp, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, notificationId, title, message, level, timestamp, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationHistory &&
          other.id == this.id &&
          other.notificationId == this.notificationId &&
          other.title == this.title &&
          other.message == this.message &&
          other.level == this.level &&
          other.timestamp == this.timestamp &&
          other.isRead == this.isRead);
}

class NotificationHistorysCompanion
    extends UpdateCompanion<NotificationHistory> {
  final Value<int> id;
  final Value<String> notificationId;
  final Value<String> title;
  final Value<String> message;
  final Value<int> level;
  final Value<DateTime> timestamp;
  final Value<bool> isRead;
  const NotificationHistorysCompanion({
    this.id = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.level = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isRead = const Value.absent(),
  });
  NotificationHistorysCompanion.insert({
    this.id = const Value.absent(),
    required String notificationId,
    required String title,
    required String message,
    this.level = const Value.absent(),
    required DateTime timestamp,
    this.isRead = const Value.absent(),
  })  : notificationId = Value(notificationId),
        title = Value(title),
        message = Value(message),
        timestamp = Value(timestamp);
  static Insertable<NotificationHistory> custom({
    Expression<int>? id,
    Expression<String>? notificationId,
    Expression<String>? title,
    Expression<String>? message,
    Expression<int>? level,
    Expression<DateTime>? timestamp,
    Expression<bool>? isRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notificationId != null) 'notification_id': notificationId,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (level != null) 'level': level,
      if (timestamp != null) 'timestamp': timestamp,
      if (isRead != null) 'is_read': isRead,
    });
  }

  NotificationHistorysCompanion copyWith(
      {Value<int>? id,
      Value<String>? notificationId,
      Value<String>? title,
      Value<String>? message,
      Value<int>? level,
      Value<DateTime>? timestamp,
      Value<bool>? isRead}) {
    return NotificationHistorysCompanion(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<String>(notificationId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationHistorysCompanion(')
          ..write('id: $id, ')
          ..write('notificationId: $notificationId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('level: $level, ')
          ..write('timestamp: $timestamp, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }
}

class $CustomTemplatesTable extends CustomTemplates
    with TableInfo<$CustomTemplatesTable, CustomTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tasksJsonMeta =
      const VerificationMeta('tasksJson');
  @override
  late final GeneratedColumn<String> tasksJson =
      GeneratedColumn<String>('tasks_json', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 2,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSystemMeta =
      const VerificationMeta('isSystem');
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
      'is_system', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_system" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, createdAt, tasksJson, icon, isSystem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_templates';
  @override
  VerificationContext validateIntegrity(Insertable<CustomTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('tasks_json')) {
      context.handle(_tasksJsonMeta,
          tasksJson.isAcceptableOrUnknown(data['tasks_json']!, _tasksJsonMeta));
    } else if (isInserting) {
      context.missing(_tasksJsonMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('is_system')) {
      context.handle(_isSystemMeta,
          isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      tasksJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tasks_json'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      isSystem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_system'])!,
    );
  }

  @override
  $CustomTemplatesTable createAlias(String alias) {
    return $CustomTemplatesTable(attachedDatabase, alias);
  }
}

class CustomTemplate extends DataClass implements Insertable<CustomTemplate> {
  final int id;
  final String name;
  final String? description;
  final int createdAt;
  final String tasksJson;
  final String? icon;
  final bool isSystem;
  const CustomTemplate(
      {required this.id,
      required this.name,
      this.description,
      required this.createdAt,
      required this.tasksJson,
      this.icon,
      required this.isSystem});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['tasks_json'] = Variable<String>(tasksJson);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['is_system'] = Variable<bool>(isSystem);
    return map;
  }

  CustomTemplatesCompanion toCompanion(bool nullToAbsent) {
    return CustomTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      tasksJson: Value(tasksJson),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      isSystem: Value(isSystem),
    );
  }

  factory CustomTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomTemplate(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      tasksJson: serializer.fromJson<String>(json['tasksJson']),
      icon: serializer.fromJson<String?>(json['icon']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<int>(createdAt),
      'tasksJson': serializer.toJson<String>(tasksJson),
      'icon': serializer.toJson<String?>(icon),
      'isSystem': serializer.toJson<bool>(isSystem),
    };
  }

  CustomTemplate copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          int? createdAt,
          String? tasksJson,
          Value<String?> icon = const Value.absent(),
          bool? isSystem}) =>
      CustomTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        tasksJson: tasksJson ?? this.tasksJson,
        icon: icon.present ? icon.value : this.icon,
        isSystem: isSystem ?? this.isSystem,
      );
  @override
  String toString() {
    return (StringBuffer('CustomTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('tasksJson: $tasksJson, ')
          ..write('icon: $icon, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, createdAt, tasksJson, icon, isSystem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.tasksJson == this.tasksJson &&
          other.icon == this.icon &&
          other.isSystem == this.isSystem);
}

class CustomTemplatesCompanion extends UpdateCompanion<CustomTemplate> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> createdAt;
  final Value<String> tasksJson;
  final Value<String?> icon;
  final Value<bool> isSystem;
  const CustomTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.tasksJson = const Value.absent(),
    this.icon = const Value.absent(),
    this.isSystem = const Value.absent(),
  });
  CustomTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required int createdAt,
    required String tasksJson,
    this.icon = const Value.absent(),
    this.isSystem = const Value.absent(),
  })  : name = Value(name),
        createdAt = Value(createdAt),
        tasksJson = Value(tasksJson);
  static Insertable<CustomTemplate> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? createdAt,
    Expression<String>? tasksJson,
    Expression<String>? icon,
    Expression<bool>? isSystem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (tasksJson != null) 'tasks_json': tasksJson,
      if (icon != null) 'icon': icon,
      if (isSystem != null) 'is_system': isSystem,
    });
  }

  CustomTemplatesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? createdAt,
      Value<String>? tasksJson,
      Value<String?>? icon,
      Value<bool>? isSystem}) {
    return CustomTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      tasksJson: tasksJson ?? this.tasksJson,
      icon: icon ?? this.icon,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (tasksJson.present) {
      map['tasks_json'] = Variable<String>(tasksJson.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('tasksJson: $tasksJson, ')
          ..write('icon: $icon, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TodosTable todos = $TodosTable(this);
  late final $AppConfigsTable appConfigs = $AppConfigsTable(this);
  late final $LocalNoticesTable localNotices = $LocalNoticesTable(this);
  late final $NotificationHistorysTable notificationHistorys =
      $NotificationHistorysTable(this);
  late final $CustomTemplatesTable customTemplates =
      $CustomTemplatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        workspaces,
        tasks,
        todos,
        appConfigs,
        localNotices,
        notificationHistorys,
        customTemplates
      ];
}
