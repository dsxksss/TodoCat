import 'package:drift/drift.dart';
import 'package:todo_cat/data/schemas/task.dart' as task_models;
import 'package:todo_cat/data/schemas/todo.dart' as todo_models;
import 'package:todo_cat/data/schemas/app_config.dart' as app_config_models;
import 'package:todo_cat/data/schemas/local_notice.dart' as local_notice_models;
import 'package:todo_cat/data/schemas/notification_history.dart'
    as notification_models;
import 'package:todo_cat/data/schemas/custom_template.dart' as template_models;
import 'package:todo_cat/data/schemas/workspace.dart' as workspace_models;
import 'package:todo_cat/data/database/database.dart';
import 'package:todo_cat/data/database/database.dart' as db;
import 'dart:convert';

/// 数据转换辅助类
/// 用于在 Drift 行和模型类之间转换
class DbConverters {
  // Workspace 转换
  static workspace_models.Workspace workspaceFromRow(db.Workspace row) {
    final workspace = workspace_models.Workspace()
      ..id = row.id
      ..uuid = row.uuid
      ..name = row.name
      ..createdAt = row.createdAt
      ..order = row.order
      ..deletedAt = row.deletedAt;
    return workspace;
  }

  static WorkspacesCompanion workspaceToCompanion(
      workspace_models.Workspace workspace,
      {bool isUpdate = false}) {
    final companion = WorkspacesCompanion(
      uuid: Value(workspace.uuid),
      name: Value(workspace.name),
      createdAt: Value(workspace.createdAt),
      order: Value(workspace.order),
      deletedAt: Value(workspace.deletedAt),
    );

    if (isUpdate && workspace.id != null) {
      return companion.copyWith(id: Value(workspace.id!));
    }
    return companion;
  }

  // Task 转换
  static task_models.Task taskFromRow(
      db.Task row, List<todo_models.Todo> todos) {
    final task = task_models.Task()
      ..id = row.id
      ..uuid = row.uuid
      ..workspaceId = row.workspaceId
      ..order = row.order
      ..title = row.title
      ..createdAt = row.createdAt
      ..description = row.description
      ..finishedAt = row.finishedAt
      ..status = task_models.TaskStatus.values[row.status]
      ..progress = row.progress
      ..reminders = row.reminders
      ..tags = List<String>.from(jsonDecode(row.tags))
      ..tagsWithColorJsonString = row.tagsWithColorJsonString
      ..todos = todos.isEmpty ? null : todos
      ..deletedAt = row.deletedAt
      ..customColor = row.customColor
      ..customIcon = row.customIcon;
    return task;
  }

  static TasksCompanion taskToCompanion(task_models.Task task,
      {bool isUpdate = false}) {
    final companion = TasksCompanion(
      uuid: Value(task.uuid),
      workspaceId: Value(task.workspaceId),
      order: Value(task.order),
      title: Value(task.title),
      createdAt: Value(task.createdAt),
      description: Value(task.description),
      finishedAt: Value(task.finishedAt),
      status: Value(task.status.index),
      progress: Value(task.progress),
      reminders: Value(task.reminders),
      tags: Value(jsonEncode(task.tags)),
      tagsWithColorJsonString: Value(task.tagsWithColorJsonString),
      deletedAt: Value(task.deletedAt),
      customColor: Value(task.customColor),
      customIcon: Value(task.customIcon),
    );

    if (isUpdate && task.id != null) {
      return companion.copyWith(id: Value(task.id!));
    }
    return companion;
  }

  // Todo 转换
  static todo_models.Todo todoFromRow(db.Todo row) {
    return todo_models.Todo()
      ..uuid = row.uuid
      ..title = row.title
      ..tags = List<String>.from(jsonDecode(row.tags))
      ..tagsWithColorJsonString = row.tagsWithColorJsonString
      ..createdAt = row.createdAt
      ..description = row.description
      ..priority = todo_models.TodoPriority.values[row.priority]
      ..finishedAt = row.finishedAt
      ..dueDate = row.dueDate
      ..status = todo_models.TodoStatus.values[row.status]
      ..reminders = row.reminders
      ..progress = row.progress
      ..images = List<String>.from(jsonDecode(row.images))
      ..deletedAt = row.deletedAt;
  }

  static TodosCompanion todoToCompanion(
      todo_models.Todo todo, String taskUuid) {
    return TodosCompanion(
      taskUuid: Value(taskUuid),
      uuid: Value(todo.uuid),
      title: Value(todo.title),
      createdAt: Value(todo.createdAt),
      description: Value(todo.description),
      priority: Value(todo.priority.index),
      finishedAt: Value(todo.finishedAt),
      dueDate: Value(todo.dueDate),
      status: Value(todo.status.index),
      reminders: Value(todo.reminders),
      progress: Value(todo.progress),
      images: Value(jsonEncode(todo.images)),
      tags: Value(jsonEncode(todo.tags)),
      tagsWithColorJsonString: Value(todo.tagsWithColorJsonString),
      deletedAt: Value(todo.deletedAt),
    );
  }

  // AppConfig 转换
  static app_config_models.AppConfig appConfigFromRow(db.AppConfig row) {
    return app_config_models.AppConfig()
      ..id = row.id
      ..configName = row.configName
      ..isDarkMode = row.isDarkMode
      ..languageCode = row.languageCode
      ..countryCode = row.countryCode
      ..emailReminderEnabled = row.emailReminderEnabled
      ..isDebugMode = row.isDebugMode
      ..backgroundImagePath = row.backgroundImagePath
      ..primaryColorValue = row.primaryColorValue
      ..backgroundImageOpacity = row.backgroundImageOpacity
      ..backgroundImageBlur = row.backgroundImageBlur
      ..backgroundAffectsNavBar = row.backgroundAffectsNavBar
      ..showTodoImage = row.showTodoImage;
  }

  static AppConfigsCompanion appConfigToCompanion(
      app_config_models.AppConfig config,
      {bool isUpdate = false}) {
    final companion = AppConfigsCompanion(
      configName: Value(config.configName),
      isDarkMode: Value(config.isDarkMode),
      languageCode: Value(config.languageCode),
      countryCode: Value(config.countryCode),
      emailReminderEnabled: Value(config.emailReminderEnabled),
      isDebugMode: Value(config.isDebugMode),
      backgroundImagePath: Value(config.backgroundImagePath),
      primaryColorValue: Value(config.primaryColorValue),
      backgroundImageOpacity: Value(config.backgroundImageOpacity),
      backgroundImageBlur: Value(config.backgroundImageBlur),
      backgroundAffectsNavBar: Value(config.backgroundAffectsNavBar),
      showTodoImage: Value(config.showTodoImage),
    );

    if (isUpdate && config.id != null) {
      return companion.copyWith(id: Value(config.id!));
    }
    return companion;
  }

  // LocalNotice 转换
  static local_notice_models.LocalNotice localNoticeFromRow(
      db.LocalNotice row) {
    return local_notice_models.LocalNotice(
      noticeId: row.noticeId,
      title: row.title,
      description: row.description,
      createdAt: row.createdAt,
      remindersAt: row.remindersAt,
      email: row.email,
    )..id = row.id;
  }

  static LocalNoticesCompanion localNoticeToCompanion(
      local_notice_models.LocalNotice notice) {
    return LocalNoticesCompanion(
      noticeId: Value(notice.noticeId),
      title: Value(notice.title),
      description: Value(notice.description),
      createdAt: Value(notice.createdAt),
      remindersAt: Value(notice.remindersAt),
      email: Value(notice.email),
    );
  }

  // NotificationHistory 转换
  static notification_models.NotificationHistory notificationHistoryFromRow(
      db.NotificationHistory row) {
    final model = notification_models.NotificationHistory()
      ..id = row.id
      ..notificationId = row.notificationId
      ..title = row.title
      ..message = row.message
      ..level = row.level
      ..timestamp = row.timestamp
      ..isRead = row.isRead;
    return model;
  }

  static NotificationHistorysCompanion notificationHistoryToCompanion(
      notification_models.NotificationHistory history) {
    return NotificationHistorysCompanion(
      notificationId: Value(history.notificationId),
      title: Value(history.title),
      message: Value(history.message),
      level: Value(history.level),
      timestamp: Value(history.timestamp),
      isRead: Value(history.isRead),
    );
  }

  // CustomTemplate 转换
  static template_models.CustomTemplate customTemplateFromRow(
      db.CustomTemplate row) {
    return template_models.CustomTemplate()
      ..id = row.id
      ..name = row.name
      ..description = row.description
      ..createdAt = row.createdAt
      ..tasksJson = row.tasksJson
      ..icon = row.icon
      ..isSystem = row.isSystem;
  }

  static CustomTemplatesCompanion customTemplateToCompanion(
      template_models.CustomTemplate template,
      {bool isUpdate = false}) {
    final companion = CustomTemplatesCompanion(
      name: Value(template.name),
      description: Value(template.description),
      createdAt: Value(template.createdAt),
      tasksJson: Value(template.tasksJson),
      icon: Value(template.icon),
      isSystem: Value(template.isSystem),
    );

    if (isUpdate && template.id != null) {
      return companion.copyWith(id: Value(template.id!));
    }
    return companion;
  }
}
