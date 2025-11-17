import 'package:drift/drift.dart';

// Workspaces 表
class Workspaces extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 255).unique()();
  TextColumn get name => text().withLength(min: 1)();
  IntColumn get createdAt => integer()();
  IntColumn get order => integer().withDefault(const Constant(0))();
  IntColumn get deletedAt => integer().withDefault(const Constant(0))();
}

// Tasks 表
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 1, max: 255).unique()();
  TextColumn get workspaceId => text().withLength(min: 1, max: 255).withDefault(const Constant('default'))(); // 关联到 Workspace
  IntColumn get order => integer().withDefault(const Constant(0))();
  TextColumn get title => text().withLength(min: 1)();
  IntColumn get createdAt => integer()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get finishedAt => integer().withDefault(const Constant(0))();
  IntColumn get status => integer().withDefault(const Constant(0))(); // 0: todo, 1: inProgress, 2: done
  IntColumn get progress => integer().withDefault(const Constant(0))();
  IntColumn get reminders => integer().withDefault(const Constant(0))();
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // JSON array
  TextColumn get tagsWithColorJsonString => text().withDefault(const Constant('[]'))();
  IntColumn get deletedAt => integer().withDefault(const Constant(0))();
}

// Todos 表（关联到 Task）
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskUuid => text().withLength(min: 1, max: 255)(); // 外键关联到 Task
  TextColumn get uuid => text().withLength(min: 1, max: 255)();
  TextColumn get title => text().withLength(min: 1)();
  IntColumn get createdAt => integer()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get priority => integer().withDefault(const Constant(0))(); // 0: lowLevel, 1: mediumLevel, 2: highLevel
  IntColumn get finishedAt => integer().withDefault(const Constant(0))();
  IntColumn get dueDate => integer().withDefault(const Constant(0))();
  IntColumn get status => integer().withDefault(const Constant(0))(); // 0: todo, 1: inProgress, 2: done
  IntColumn get reminders => integer().withDefault(const Constant(0))();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  TextColumn get images => text().withDefault(const Constant('[]'))(); // JSON array
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // JSON array
  TextColumn get tagsWithColorJsonString => text().withDefault(const Constant('[]'))();
  IntColumn get deletedAt => integer().withDefault(const Constant(0))();
}

// AppConfigs 表
class AppConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get configName => text().withLength(min: 1).unique()();
  BoolColumn get isDarkMode => boolean().withDefault(const Constant(false))();
  TextColumn get languageCode => text().withLength(min: 2, max: 10)();
  TextColumn get countryCode => text().withLength(min: 0, max: 10).withDefault(const Constant(''))();
  BoolColumn get emailReminderEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get isDebugMode => boolean().withDefault(const Constant(false))();
  TextColumn get backgroundImagePath => text().nullable()();
  IntColumn get primaryColorValue => integer().nullable()();
  RealColumn get backgroundImageOpacity => real().withDefault(const Constant(0.15))();
  RealColumn get backgroundImageBlur => real().withDefault(const Constant(0.0))();
  BoolColumn get backgroundAffectsNavBar => boolean().withDefault(const Constant(false))();
  BoolColumn get showTodoImage => boolean().withDefault(const Constant(true))();
}

// LocalNotices 表
class LocalNotices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get noticeId => text().withLength(min: 1).unique()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get description => text().withLength(min: 1)();
  IntColumn get createdAt => integer()();
  IntColumn get remindersAt => integer()();
  TextColumn get email => text().withLength(min: 1)();
}

// NotificationHistorys 表
class NotificationHistorys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get notificationId => text().withLength(min: 1).unique()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get message => text().withLength(min: 1)();
  IntColumn get level => integer().withDefault(const Constant(0))(); // 0: success, 1: info, 2: warning, 3: error
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

// CustomTemplates 表
class CustomTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1)();
  TextColumn get description => text().nullable()();
  IntColumn get createdAt => integer()();
  TextColumn get tasksJson => text().withLength(min: 2)(); // JSON array of tasks
  TextColumn get icon => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
}

