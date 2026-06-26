import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @todoCat.
  ///
  /// In en, this message translates to:
  /// **'TodoCat'**
  String get todoCat;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My tasks'**
  String get myTasks;

  /// No description provided for @todo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get todo;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @another.
  ///
  /// In en, this message translates to:
  /// **'Another'**
  String get another;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @addTodo.
  ///
  /// In en, this message translates to:
  /// **'Add Todo'**
  String get addTodo;

  /// No description provided for @editTodo.
  ///
  /// In en, this message translates to:
  /// **'Edit Todo'**
  String get editTodo;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @highLevel.
  ///
  /// In en, this message translates to:
  /// **'High level'**
  String get highLevel;

  /// No description provided for @mediumLevel.
  ///
  /// In en, this message translates to:
  /// **'Medium level'**
  String get mediumLevel;

  /// No description provided for @lowLevel.
  ///
  /// In en, this message translates to:
  /// **'Low level'**
  String get lowLevel;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @pleaseCompleteItProperly.
  ///
  /// In en, this message translates to:
  /// **'Please fill in correctly'**
  String get pleaseCompleteItProperly;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @deletionFailed.
  ///
  /// In en, this message translates to:
  /// **'deletion failed'**
  String get deletionFailed;

  /// No description provided for @taskReminder.
  ///
  /// In en, this message translates to:
  /// **'Task reminder'**
  String get taskReminder;

  /// No description provided for @createTime.
  ///
  /// In en, this message translates to:
  /// **'Create time'**
  String get createTime;

  /// No description provided for @tagsUpperLimit.
  ///
  /// In en, this message translates to:
  /// **'Tags upper limit'**
  String get tagsUpperLimit;

  /// No description provided for @saveEditing.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save edits'**
  String get saveEditing;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @sureDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Would you like to delete the task ?'**
  String get sureDeleteTask;

  /// No description provided for @sureDeleteTodo.
  ///
  /// In en, this message translates to:
  /// **'Would you like to delete the todo ?'**
  String get sureDeleteTodo;

  /// No description provided for @sureDeleteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete workspace?'**
  String get sureDeleteWorkspace;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @launchAtStartup.
  ///
  /// In en, this message translates to:
  /// **'Launch at startup'**
  String get launchAtStartup;

  /// No description provided for @launchAtStartupDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically run TodoCat after system startup/login (desktop only)'**
  String get launchAtStartupDescription;

  /// No description provided for @showTodoImage.
  ///
  /// In en, this message translates to:
  /// **'Show Todo Image Cover'**
  String get showTodoImage;

  /// No description provided for @showTodoImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Display the first image of todo items as a cover in the todo card on the home page (between title and tags)'**
  String get showTodoImageDescription;

  /// No description provided for @emailReminder.
  ///
  /// In en, this message translates to:
  /// **'Email reminder'**
  String get emailReminder;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @common.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get common;

  /// No description provided for @emailReminderSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email reminder sent successfully'**
  String get emailReminderSentSuccessfully;

  /// No description provided for @emailReminderSendingFailed.
  ///
  /// In en, this message translates to:
  /// **'Email reminder sent failed'**
  String get emailReminderSendingFailed;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get resetSettings;

  /// No description provided for @confirmResetSettings.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset settings?'**
  String get confirmResetSettings;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings reset successfully'**
  String get settingsResetSuccess;

  /// No description provided for @enbleDebugMode.
  ///
  /// In en, this message translates to:
  /// **'Enable debug mode'**
  String get enbleDebugMode;

  /// No description provided for @taskColor.
  ///
  /// In en, this message translates to:
  /// **'Task Color'**
  String get taskColor;

  /// No description provided for @taskIcon.
  ///
  /// In en, this message translates to:
  /// **'Task Icon'**
  String get taskIcon;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Task Description'**
  String get taskDescription;

  /// No description provided for @taskAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task added successfully'**
  String get taskAddedSuccessfully;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @tagEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tag cannot be empty'**
  String get tagEmpty;

  /// No description provided for @tagDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Tag already exists'**
  String get tagDuplicate;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @noDateTime.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get noDateTime;

  /// No description provided for @isResetTasksTemplate.
  ///
  /// In en, this message translates to:
  /// **'The task is empty, do you want to add a task example template?'**
  String get isResetTasksTemplate;

  /// No description provided for @areYouSureResetTasksTemplate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the tasks template?'**
  String get areYouSureResetTasksTemplate;

  /// No description provided for @tasksTemplateResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tasks template reset successfully'**
  String get tasksTemplateResetSuccess;

  /// No description provided for @tasksTemplate.
  ///
  /// In en, this message translates to:
  /// **'Task Template'**
  String get tasksTemplate;

  /// No description provided for @todoDetail.
  ///
  /// In en, this message translates to:
  /// **'Todo Detail'**
  String get todoDetail;

  /// No description provided for @timeInfo.
  ///
  /// In en, this message translates to:
  /// **'Time Information'**
  String get timeInfo;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low priority'**
  String get lowPriority;

  /// No description provided for @mediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium priority'**
  String get mediumPriority;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get highPriority;

  /// No description provided for @noReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get noReminder;

  /// No description provided for @reminder5Minutes.
  ///
  /// In en, this message translates to:
  /// **'5 Minutes Ago'**
  String get reminder5Minutes;

  /// No description provided for @reminder15Minutes.
  ///
  /// In en, this message translates to:
  /// **'15 Minutes Ago'**
  String get reminder15Minutes;

  /// No description provided for @reminder30Minutes.
  ///
  /// In en, this message translates to:
  /// **'30 Minutes Ago'**
  String get reminder30Minutes;

  /// No description provided for @reminder1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 Hour Ago'**
  String get reminder1Hour;

  /// No description provided for @reminder2Hours.
  ///
  /// In en, this message translates to:
  /// **'2 Hours Ago'**
  String get reminder2Hours;

  /// No description provided for @reminder1Day.
  ///
  /// In en, this message translates to:
  /// **'1 Day Ago'**
  String get reminder1Day;

  /// No description provided for @selectTaskFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a task first'**
  String get selectTaskFirst;

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// No description provided for @addTodoFailed.
  ///
  /// In en, this message translates to:
  /// **'Adding todo failed'**
  String get addTodoFailed;

  /// No description provided for @setDueDate.
  ///
  /// In en, this message translates to:
  /// **'Set Due Date'**
  String get setDueDate;

  /// No description provided for @quickSelect.
  ///
  /// In en, this message translates to:
  /// **'Quick Select'**
  String get quickSelect;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @threeDays.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get threeDays;

  /// No description provided for @oneWeek.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get oneWeek;

  /// No description provided for @oneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get oneMonth;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No description provided for @statusTodo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get statusTodo;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'added successfully'**
  String get addedSuccessfully;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @dataImportExport.
  ///
  /// In en, this message translates to:
  /// **'Data Import/Export'**
  String get dataImportExport;

  /// No description provided for @dataImportExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Import or export tasks and settings data'**
  String get dataImportExportDescription;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Export all tasks and settings to JSON file'**
  String get exportDataDescription;

  /// No description provided for @importDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Import tasks and settings from JSON file'**
  String get importDataDescription;

  /// No description provided for @resetSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reset application settings to default values'**
  String get resetSettingsDescription;

  /// No description provided for @notificationCenter.
  ///
  /// In en, this message translates to:
  /// **'Notification Center'**
  String get notificationCenter;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your notifications will appear here'**
  String get noNotificationsDesc;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @unreadMessages.
  ///
  /// In en, this message translates to:
  /// **'unread messages'**
  String get unreadMessages;

  /// No description provided for @allMessagesRead.
  ///
  /// In en, this message translates to:
  /// **'All messages read'**
  String get allMessagesRead;

  /// No description provided for @confirmClearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Confirm Clear All Notifications'**
  String get confirmClearAllNotifications;

  /// No description provided for @clickDescriptionInputToOpenBrowseWindow.
  ///
  /// In en, this message translates to:
  /// **'Click description input to open browse window'**
  String get clickDescriptionInputToOpenBrowseWindow;

  /// No description provided for @confirmClearAllNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications? This action cannot be undone.'**
  String get confirmClearAllNotificationsDesc;

  /// No description provided for @notificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get notificationsCleared;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// No description provided for @importConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Conflict Handling'**
  String get importConflictTitle;

  /// No description provided for @conflictTasksDetected.
  ///
  /// In en, this message translates to:
  /// **'The following tasks already exist (including system default tasks):'**
  String get conflictTasksDetected;

  /// No description provided for @selectHandlingMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select handling method:'**
  String get selectHandlingMethod;

  /// No description provided for @skipDuplicateTasks.
  ///
  /// In en, this message translates to:
  /// **'Skip Duplicate Tasks'**
  String get skipDuplicateTasks;

  /// No description provided for @skipDuplicateTasksDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep existing tasks, import only new tasks'**
  String get skipDuplicateTasksDesc;

  /// No description provided for @replaceExistingTasks.
  ///
  /// In en, this message translates to:
  /// **'Replace Existing Tasks'**
  String get replaceExistingTasks;

  /// No description provided for @replaceExistingTasksDesc.
  ///
  /// In en, this message translates to:
  /// **'Replace existing tasks with imported tasks of the same name'**
  String get replaceExistingTasksDesc;

  /// No description provided for @confirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get confirmImport;

  /// No description provided for @importDataWill.
  ///
  /// In en, this message translates to:
  /// **'Importing data will:'**
  String get importDataWill;

  /// No description provided for @addNewTasksAndTodos.
  ///
  /// In en, this message translates to:
  /// **'Add new tasks and todos'**
  String get addNewTasksAndTodos;

  /// No description provided for @replaceAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Replace app configuration settings'**
  String get replaceAppSettings;

  /// No description provided for @keepExistingData.
  ///
  /// In en, this message translates to:
  /// **'Keep existing data without deletion'**
  String get keepExistingData;

  /// No description provided for @importWarning.
  ///
  /// In en, this message translates to:
  /// **'Note: If imported data contains tasks with the same UUID, existing tasks will be overwritten.'**
  String get importWarning;

  /// No description provided for @userCancelledImport.
  ///
  /// In en, this message translates to:
  /// **'User cancelled import operation'**
  String get userCancelledImport;

  /// No description provided for @userCancelledOperation.
  ///
  /// In en, this message translates to:
  /// **'User cancelled operation'**
  String get userCancelledOperation;

  /// No description provided for @invalidFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format, please select a valid TodoCat data file'**
  String get invalidFileFormat;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @noNewDataToImport.
  ///
  /// In en, this message translates to:
  /// **'No new data to import'**
  String get noNewDataToImport;

  /// No description provided for @importedNewTasks.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get importedNewTasks;

  /// No description provided for @replacedTasks.
  ///
  /// In en, this message translates to:
  /// **'Replaced'**
  String get replacedTasks;

  /// No description provided for @skippedTasks.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skippedTasks;

  /// No description provided for @updatedAppConfig.
  ///
  /// In en, this message translates to:
  /// **'Updated app configuration'**
  String get updatedAppConfig;

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get exportCancelled;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @startingImport.
  ///
  /// In en, this message translates to:
  /// **'Starting data import...'**
  String get startingImport;

  /// No description provided for @importingData.
  ///
  /// In en, this message translates to:
  /// **'Importing data, please wait...'**
  String get importingData;

  /// No description provided for @importingDataPlease.
  ///
  /// In en, this message translates to:
  /// **'Importing data, please wait...'**
  String get importingDataPlease;

  /// No description provided for @selectDataFileToImport.
  ///
  /// In en, this message translates to:
  /// **'Select data file to import'**
  String get selectDataFileToImport;

  /// No description provided for @selectSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Select save location'**
  String get selectSaveLocation;

  /// No description provided for @confirmExport.
  ///
  /// In en, this message translates to:
  /// **'Confirm Export'**
  String get confirmExport;

  /// No description provided for @exportDataPreview.
  ///
  /// In en, this message translates to:
  /// **'The following data will be exported:'**
  String get exportDataPreview;

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'Tasks Count'**
  String get tasksCount;

  /// No description provided for @todosCount.
  ///
  /// In en, this message translates to:
  /// **'Todos Count'**
  String get todosCount;

  /// No description provided for @appConfig.
  ///
  /// In en, this message translates to:
  /// **'App Configuration'**
  String get appConfig;

  /// No description provided for @estimatedSize.
  ///
  /// In en, this message translates to:
  /// **'Estimated Size'**
  String get estimatedSize;

  /// No description provided for @exportDataNotice.
  ///
  /// In en, this message translates to:
  /// **'The exported file contains all your data. Please keep it safe.'**
  String get exportDataNotice;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete all tasks, config and notification data'**
  String get clearAllDataDescription;

  /// No description provided for @confirmClearAllData.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data? This cannot be undone!'**
  String get confirmClearAllData;

  /// No description provided for @clearingData.
  ///
  /// In en, this message translates to:
  /// **'Clearing data...'**
  String get clearingData;

  /// No description provided for @clearAllDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get clearAllDataSuccess;

  /// No description provided for @clearAllDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear data'**
  String get clearAllDataFailed;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @saveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get saveAsTemplate;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// No description provided for @enterTemplateName.
  ///
  /// In en, this message translates to:
  /// **'Enter template name'**
  String get enterTemplateName;

  /// No description provided for @templateNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Template name is required'**
  String get templateNameRequired;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get templateSaved;

  /// No description provided for @templateAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Template name already exists'**
  String get templateAlreadyExists;

  /// No description provided for @customTemplates.
  ///
  /// In en, this message translates to:
  /// **'Custom Templates'**
  String get customTemplates;

  /// No description provided for @noCustomTemplates.
  ///
  /// In en, this message translates to:
  /// **'No custom templates'**
  String get noCustomTemplates;

  /// No description provided for @deleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get deleteTemplate;

  /// No description provided for @confirmDeleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this template?'**
  String get confirmDeleteTemplate;

  /// No description provided for @templateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleted;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating'**
  String get creating;

  /// No description provided for @noTasksToSave.
  ///
  /// In en, this message translates to:
  /// **'No tasks to save'**
  String get noTasksToSave;

  /// No description provided for @saveCurrentAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save Current as Template'**
  String get saveCurrentAsTemplate;

  /// No description provided for @saveCurrentAsTemplateDescription.
  ///
  /// In en, this message translates to:
  /// **'Save all current tasks as a custom template'**
  String get saveCurrentAsTemplateDescription;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development'**
  String get featureInDevelopment;

  /// No description provided for @dailyLifeManagement.
  ///
  /// In en, this message translates to:
  /// **'Daily Life Management'**
  String get dailyLifeManagement;

  /// No description provided for @selectTaskTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select Task Template'**
  String get selectTaskTemplate;

  /// No description provided for @selectTemplateType.
  ///
  /// In en, this message translates to:
  /// **'Please select the task template type to use:'**
  String get selectTemplateType;

  /// No description provided for @emptyTemplate.
  ///
  /// In en, this message translates to:
  /// **'Empty Template'**
  String get emptyTemplate;

  /// No description provided for @emptyTemplateDescription.
  ///
  /// In en, this message translates to:
  /// **'Create empty todo, inProgress, done, another tasks'**
  String get emptyTemplateDescription;

  /// No description provided for @studentScheduleTemplate.
  ///
  /// In en, this message translates to:
  /// **'Student Schedule Template'**
  String get studentScheduleTemplate;

  /// No description provided for @studentScheduleTemplateDescription.
  ///
  /// In en, this message translates to:
  /// **'Contains specific todo items for study, programming, music, and life tasks'**
  String get studentScheduleTemplateDescription;

  /// No description provided for @workManagementTemplate.
  ///
  /// In en, this message translates to:
  /// **'Work Management Template'**
  String get workManagementTemplate;

  /// No description provided for @workManagementTemplateDescription.
  ///
  /// In en, this message translates to:
  /// **'Project management, team collaboration, work progress tracking'**
  String get workManagementTemplateDescription;

  /// No description provided for @fitnessTrainingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Fitness Training Template'**
  String get fitnessTrainingTemplate;

  /// No description provided for @fitnessTrainingTemplateDescription.
  ///
  /// In en, this message translates to:
  /// **'Create fitness plans and track training progress'**
  String get fitnessTrainingTemplateDescription;

  /// No description provided for @travelPlanTemplate.
  ///
  /// In en, this message translates to:
  /// **'Travel Plan Template'**
  String get travelPlanTemplate;

  /// No description provided for @travelPlanTemplateDescription.
  ///
  /// In en, this message translates to:
  /// **'Plan travel itinerary, book hotels and flights'**
  String get travelPlanTemplateDescription;

  /// No description provided for @backgroundSetting.
  ///
  /// In en, this message translates to:
  /// **'Background Setting'**
  String get backgroundSetting;

  /// No description provided for @backgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Background Image'**
  String get backgroundImage;

  /// No description provided for @backgroundVideo.
  ///
  /// In en, this message translates to:
  /// **'Background Video'**
  String get backgroundVideo;

  /// No description provided for @backgroundImageSet.
  ///
  /// In en, this message translates to:
  /// **'Background image set'**
  String get backgroundImageSet;

  /// No description provided for @backgroundImageNotSet.
  ///
  /// In en, this message translates to:
  /// **'No background image'**
  String get backgroundImageNotSet;

  /// No description provided for @selectBackground.
  ///
  /// In en, this message translates to:
  /// **'Select Background'**
  String get selectBackground;

  /// No description provided for @clearBackground.
  ///
  /// In en, this message translates to:
  /// **'Clear Background'**
  String get clearBackground;

  /// No description provided for @currentBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Background image set'**
  String get currentBackgroundImage;

  /// No description provided for @noBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'No background image'**
  String get noBackgroundImage;

  /// No description provided for @opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacity;

  /// No description provided for @blur.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get blur;

  /// No description provided for @affectsNavBar.
  ///
  /// In en, this message translates to:
  /// **'Affect Navigation Bar'**
  String get affectsNavBar;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @defaultBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'Default Background Templates'**
  String get defaultBackgrounds;

  /// No description provided for @defaultBackgroundImages.
  ///
  /// In en, this message translates to:
  /// **'Default Background Images'**
  String get defaultBackgroundImages;

  /// No description provided for @defaultBackgroundVideos.
  ///
  /// In en, this message translates to:
  /// **'Default Background Videos'**
  String get defaultBackgroundVideos;

  /// No description provided for @defaultTemplateApplied.
  ///
  /// In en, this message translates to:
  /// **'Default template applied'**
  String get defaultTemplateApplied;

  /// No description provided for @desktopOnlyFeature.
  ///
  /// In en, this message translates to:
  /// **'This feature is only available on desktop'**
  String get desktopOnlyFeature;

  /// No description provided for @backgroundImageSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Background image set'**
  String get backgroundImageSetSuccess;

  /// No description provided for @backgroundVideoSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Background video set'**
  String get backgroundVideoSetSuccess;

  /// No description provided for @backgroundImageCleared.
  ///
  /// In en, this message translates to:
  /// **'Background image cleared'**
  String get backgroundImageCleared;

  /// No description provided for @backgroundImageClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear background image'**
  String get backgroundImageClearFailed;

  /// No description provided for @backgroundTemplateApplied.
  ///
  /// In en, this message translates to:
  /// **'Background template applied'**
  String get backgroundTemplateApplied;

  /// No description provided for @applyDefaultTemplateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply default background template'**
  String get applyDefaultTemplateFailed;

  /// No description provided for @selectBackgroundImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select background image'**
  String get selectBackgroundImageFailed;

  /// No description provided for @confirmApplyTemplate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to apply template? This will clear all existing tasks.'**
  String get confirmApplyTemplate;

  /// No description provided for @taskTemplateApplied.
  ///
  /// In en, this message translates to:
  /// **'Task template has been applied'**
  String get taskTemplateApplied;

  /// No description provided for @templatePreview.
  ///
  /// In en, this message translates to:
  /// **'Template Preview'**
  String get templatePreview;

  /// No description provided for @moreItems.
  ///
  /// In en, this message translates to:
  /// **'more items'**
  String get moreItems;

  /// No description provided for @selectTagColor.
  ///
  /// In en, this message translates to:
  /// **'Select Tag Color'**
  String get selectTagColor;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTag;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagName;

  /// No description provided for @enterTagName.
  ///
  /// In en, this message translates to:
  /// **'Enter tag name'**
  String get enterTagName;

  /// No description provided for @tagColor.
  ///
  /// In en, this message translates to:
  /// **'Tag Color'**
  String get tagColor;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Check if a new version is available'**
  String get checkForUpdatesDescription;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @noUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get noUpdateAvailable;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Error checking for updates'**
  String get updateError;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version is available'**
  String get newVersionAvailable;

  /// No description provided for @bugFixesAndImprovements.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes and improvements'**
  String get bugFixesAndImprovements;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checkingForUpdates;

  /// No description provided for @downloadingUpdateInfo.
  ///
  /// In en, this message translates to:
  /// **'Downloading update information...'**
  String get downloadingUpdateInfo;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading new version...'**
  String get downloadingUpdate;

  /// No description provided for @installingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Installing update...'**
  String get installingUpdate;

  /// No description provided for @alreadyLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'You are using the latest version'**
  String get alreadyLatestVersion;

  /// No description provided for @updateComplete.
  ///
  /// In en, this message translates to:
  /// **'Update completed successfully'**
  String get updateComplete;

  /// No description provided for @cancelUpdate.
  ///
  /// In en, this message translates to:
  /// **'Cancel Update'**
  String get cancelUpdate;

  /// No description provided for @updateCancelled.
  ///
  /// In en, this message translates to:
  /// **'Update cancelled'**
  String get updateCancelled;

  /// No description provided for @clickToCancelUpdate.
  ///
  /// In en, this message translates to:
  /// **'Click to cancel update'**
  String get clickToCancelUpdate;

  /// No description provided for @selectUpdateMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Update Method'**
  String get selectUpdateMethod;

  /// No description provided for @selectUpdateMethodDesc.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred update method:'**
  String get selectUpdateMethodDesc;

  /// No description provided for @updateViaDownload.
  ///
  /// In en, this message translates to:
  /// **'Download Update'**
  String get updateViaDownload;

  /// No description provided for @updateViaDownloadDesc.
  ///
  /// In en, this message translates to:
  /// **'Download and install the update package locally'**
  String get updateViaDownloadDesc;

  /// No description provided for @updateViaStore.
  ///
  /// In en, this message translates to:
  /// **'Update via Microsoft Store'**
  String get updateViaStore;

  /// No description provided for @updateViaStoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Open Microsoft Store to update'**
  String get updateViaStoreDesc;

  /// No description provided for @openMicrosoftStore.
  ///
  /// In en, this message translates to:
  /// **'Open Microsoft Store'**
  String get openMicrosoftStore;

  /// No description provided for @failedToOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Failed to open Microsoft Store'**
  String get failedToOpenStore;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get emptyTrash;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmpty;

  /// No description provided for @trashEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Deleted tasks and todos will appear here'**
  String get trashEmptyDesc;

  /// No description provided for @deletedAt.
  ///
  /// In en, this message translates to:
  /// **'Deleted at'**
  String get deletedAt;

  /// No description provided for @deletedTodos.
  ///
  /// In en, this message translates to:
  /// **'Deleted todos'**
  String get deletedTodos;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @permanentDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanent Delete'**
  String get permanentDelete;

  /// No description provided for @sureRestoreTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore task?'**
  String get sureRestoreTask;

  /// No description provided for @sureRestoreTodo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore todo?'**
  String get sureRestoreTodo;

  /// No description provided for @surePermanentDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete task? This action cannot be undone!'**
  String get surePermanentDeleteTask;

  /// No description provided for @surePermanentDeleteTodo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete todo? This action cannot be undone!'**
  String get surePermanentDeleteTodo;

  /// No description provided for @sureEmptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to empty the trash? This will permanently delete all deleted items and cannot be undone!'**
  String get sureEmptyTrash;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @todoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Todo deleted'**
  String get todoDeleted;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @taskRestored.
  ///
  /// In en, this message translates to:
  /// **'Task restored'**
  String get taskRestored;

  /// No description provided for @todoRestored.
  ///
  /// In en, this message translates to:
  /// **'Todo restored'**
  String get todoRestored;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// No description provided for @taskPermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task permanently deleted'**
  String get taskPermanentlyDeleted;

  /// No description provided for @todoPermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Todo permanently deleted'**
  String get todoPermanentlyDeleted;

  /// No description provided for @permanentDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Permanent delete failed'**
  String get permanentDeleteFailed;

  /// No description provided for @trashEmptied.
  ///
  /// In en, this message translates to:
  /// **'Trash emptied'**
  String get trashEmptied;

  /// No description provided for @emptyTrashFailed.
  ///
  /// In en, this message translates to:
  /// **'Empty trash failed'**
  String get emptyTrashFailed;

  /// No description provided for @allUpdateSourcesFailed.
  ///
  /// In en, this message translates to:
  /// **'All update sources failed to initialize'**
  String get allUpdateSourcesFailed;

  /// No description provided for @unableToGetCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Unable to get current version'**
  String get unableToGetCurrentVersion;

  /// No description provided for @updateSourceNotSet.
  ///
  /// In en, this message translates to:
  /// **'Update source not set'**
  String get updateSourceNotSet;

  /// No description provided for @noUpdateInformationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No update information available'**
  String get noUpdateInformationAvailable;

  /// No description provided for @downloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled'**
  String get downloadCancelled;

  /// No description provided for @userCancelledDownload.
  ///
  /// In en, this message translates to:
  /// **'User cancelled download'**
  String get userCancelledDownload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @markdownBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get markdownBold;

  /// No description provided for @markdownItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get markdownItalic;

  /// No description provided for @markdownStrikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get markdownStrikethrough;

  /// No description provided for @markdownHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get markdownHeading;

  /// No description provided for @markdownUnorderedList.
  ///
  /// In en, this message translates to:
  /// **'Unordered List'**
  String get markdownUnorderedList;

  /// No description provided for @markdownOrderedList.
  ///
  /// In en, this message translates to:
  /// **'Ordered List'**
  String get markdownOrderedList;

  /// No description provided for @markdownLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get markdownLink;

  /// No description provided for @markdownImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get markdownImage;

  /// No description provided for @markdownCodeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code Block'**
  String get markdownCodeBlock;

  /// No description provided for @markdownQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get markdownQuote;

  /// No description provided for @markdownSeparator.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get markdownSeparator;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @keepInput.
  ///
  /// In en, this message translates to:
  /// **'Keep input?'**
  String get keepInput;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChanges;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @closePreview.
  ///
  /// In en, this message translates to:
  /// **'Close Preview'**
  String get closePreview;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @workspaceName.
  ///
  /// In en, this message translates to:
  /// **'Workspace name'**
  String get workspaceName;

  /// No description provided for @createWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create workspace'**
  String get createWorkspace;

  /// No description provided for @enterWorkspaceName.
  ///
  /// In en, this message translates to:
  /// **'Please enter workspace name'**
  String get enterWorkspaceName;

  /// No description provided for @workspaceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Workspace name cannot be empty'**
  String get workspaceNameRequired;

  /// No description provided for @workspaceCreated.
  ///
  /// In en, this message translates to:
  /// **'Workspace created successfully'**
  String get workspaceCreated;

  /// No description provided for @workspaceCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create workspace'**
  String get workspaceCreateFailed;

  /// No description provided for @defaultWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultWorkspace;

  /// No description provided for @renameWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Rename workspace'**
  String get renameWorkspace;

  /// No description provided for @workspaceRenamed.
  ///
  /// In en, this message translates to:
  /// **'Workspace renamed successfully'**
  String get workspaceRenamed;

  /// No description provided for @workspaceRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename workspace'**
  String get workspaceRenameFailed;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renaming.
  ///
  /// In en, this message translates to:
  /// **'Renaming...'**
  String get renaming;

  /// No description provided for @deleteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Delete workspace'**
  String get deleteWorkspace;

  /// No description provided for @workspaceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workspace deleted'**
  String get workspaceDeleted;

  /// No description provided for @workspaceRestored.
  ///
  /// In en, this message translates to:
  /// **'Workspace restored'**
  String get workspaceRestored;

  /// No description provided for @workspaceRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore workspace'**
  String get workspaceRestoreFailed;

  /// No description provided for @deletedWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Deleted Workspaces'**
  String get deletedWorkspaces;

  /// No description provided for @deletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Deleted Tasks'**
  String get deletedTasks;

  /// No description provided for @sureRestoreWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore workspace?'**
  String get sureRestoreWorkspace;

  /// No description provided for @surePermanentDeleteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete workspace? This action cannot be undone!'**
  String get surePermanentDeleteWorkspace;

  /// No description provided for @workspacePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workspace permanently deleted'**
  String get workspacePermanentlyDeleted;

  /// No description provided for @moveToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Move to workspace'**
  String get moveToWorkspace;

  /// No description provided for @selectTargetWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Select target workspace'**
  String get selectTargetWorkspace;

  /// No description provided for @taskMovedToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Task moved to workspace'**
  String get taskMovedToWorkspace;

  /// No description provided for @taskMoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to move task'**
  String get taskMoveFailed;

  /// No description provided for @noWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'No workspaces available'**
  String get noWorkspaces;

  /// No description provided for @currentWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Current workspace'**
  String get currentWorkspace;

  /// No description provided for @moveTodoToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Move to workspace'**
  String get moveTodoToWorkspace;

  /// No description provided for @selectTargetTask.
  ///
  /// In en, this message translates to:
  /// **'Select target task'**
  String get selectTargetTask;

  /// No description provided for @todoMovedToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Todo moved to workspace'**
  String get todoMovedToWorkspace;

  /// No description provided for @todoMoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to move todo'**
  String get todoMoveFailed;

  /// No description provided for @noTasksInWorkspace.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this workspace'**
  String get noTasksInWorkspace;

  /// No description provided for @currentTask.
  ///
  /// In en, this message translates to:
  /// **'Current task'**
  String get currentTask;

  /// No description provided for @duplicateNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Name Found'**
  String get duplicateNameTitle;

  /// No description provided for @duplicateNameMessage.
  ///
  /// In en, this message translates to:
  /// **'The target workspace \"{target}\" already contains a {itemType} named \"{itemName}\" (from workspace \"{source}\"). Please choose how to handle this:'**
  String duplicateNameMessage(
      String target, String itemType, String itemName, String source);

  /// No description provided for @duplicateNameMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get duplicateNameMerge;

  /// No description provided for @duplicateNameMergeDesc.
  ///
  /// In en, this message translates to:
  /// **'Merge content into existing item and delete source item'**
  String get duplicateNameMergeDesc;

  /// No description provided for @duplicateNameRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get duplicateNameRename;

  /// No description provided for @duplicateNameRenameDesc.
  ///
  /// In en, this message translates to:
  /// **'Rename to \"{itemName} - {source}\"'**
  String duplicateNameRenameDesc(String itemName, String source);

  /// No description provided for @duplicateNameAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow Duplicate'**
  String get duplicateNameAllow;

  /// No description provided for @duplicateNameAllowDesc.
  ///
  /// In en, this message translates to:
  /// **'Move directly, allow multiple items with the same name'**
  String get duplicateNameAllowDesc;

  /// No description provided for @doubleTapToZoom.
  ///
  /// In en, this message translates to:
  /// **'Double tap to zoom in/out'**
  String get doubleTapToZoom;

  /// No description provided for @resetView.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get resetView;

  /// No description provided for @imageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadFailed;

  /// No description provided for @clickToViewImage.
  ///
  /// In en, this message translates to:
  /// **'Click to view image'**
  String get clickToViewImage;

  /// No description provided for @syncConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get syncConfiguration;

  /// No description provided for @syncConfigurationDescription.
  ///
  /// In en, this message translates to:
  /// **'Sync workspaces across devices securely'**
  String get syncConfigurationDescription;

  /// No description provided for @syncKey.
  ///
  /// In en, this message translates to:
  /// **'Sync Key'**
  String get syncKey;

  /// No description provided for @syncKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste Sync Key to import workspace'**
  String get syncKeyHint;

  /// No description provided for @importLabel.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importLabel;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @todoDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Todo duplicated'**
  String get todoDuplicated;

  /// No description provided for @syncActions.
  ///
  /// In en, this message translates to:
  /// **'Sync Actions'**
  String get syncActions;

  /// No description provided for @syncToCloud.
  ///
  /// In en, this message translates to:
  /// **'Upload to Cloud'**
  String get syncToCloud;

  /// No description provided for @restoreFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Download from Cloud'**
  String get restoreFromCloud;

  /// No description provided for @workspaceShare.
  ///
  /// In en, this message translates to:
  /// **'Workspace Share'**
  String get workspaceShare;

  /// No description provided for @copyWorkspaceKey.
  ///
  /// In en, this message translates to:
  /// **'Copy Workspace Key'**
  String get copyWorkspaceKey;

  /// No description provided for @importWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Import Workspace'**
  String get importWorkspace;

  /// No description provided for @enterWorkspaceKey.
  ///
  /// In en, this message translates to:
  /// **'Enter Workspace Key'**
  String get enterWorkspaceKey;

  /// No description provided for @keyCopied.
  ///
  /// In en, this message translates to:
  /// **'Key copied to clipboard'**
  String get keyCopied;

  /// No description provided for @keyImported.
  ///
  /// In en, this message translates to:
  /// **'Key imported successfully'**
  String get keyImported;

  /// No description provided for @invalidKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid Key'**
  String get invalidKey;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync successful'**
  String get syncSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore successful'**
  String get restoreSuccess;

  /// No description provided for @webDavDetails.
  ///
  /// In en, this message translates to:
  /// **'Cloud Service Status'**
  String get webDavDetails;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @syncInfo.
  ///
  /// In en, this message translates to:
  /// **'Sync Information'**
  String get syncInfo;

  /// No description provided for @workspaceId.
  ///
  /// In en, this message translates to:
  /// **'Workspace ID'**
  String get workspaceId;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @notSynced.
  ///
  /// In en, this message translates to:
  /// **'Not Synced'**
  String get notSynced;

  /// No description provided for @lastSyncedAt.
  ///
  /// In en, this message translates to:
  /// **'Last Synced At'**
  String get lastSyncedAt;

  /// No description provided for @shareContentWorkspace.
  ///
  /// In en, this message translates to:
  /// **'TodoCat Workspace'**
  String get shareContentWorkspace;

  /// No description provided for @shareContentId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get shareContentId;

  /// No description provided for @shareContentLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last Synced'**
  String get shareContentLastSynced;

  /// No description provided for @shareContentKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get shareContentKey;

  /// No description provided for @confirmSyncToCloud.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sync to Cloud?'**
  String get confirmSyncToCloud;

  /// No description provided for @confirmSyncToCloudDesc.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite existing data on the cloud. Please confirm you want to upload current local status.'**
  String get confirmSyncToCloudDesc;

  /// No description provided for @confirmDownloadFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Confirm Download from Cloud?'**
  String get confirmDownloadFromCloud;

  /// No description provided for @confirmDownloadFromCloudDesc.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite existing local data. Please confirm you want to restore cloud status.'**
  String get confirmDownloadFromCloudDesc;

  /// No description provided for @remoteUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version detected on cloud, update now?'**
  String get remoteUpdateAvailable;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get syncCompleted;

  /// No description provided for @statusLocalChanges.
  ///
  /// In en, this message translates to:
  /// **'Local changes'**
  String get statusLocalChanges;

  /// No description provided for @statusRemoteUpdate.
  ///
  /// In en, this message translates to:
  /// **'Remote update'**
  String get statusRemoteUpdate;

  /// No description provided for @statusConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get statusConflict;

  /// No description provided for @historyVersions.
  ///
  /// In en, this message translates to:
  /// **'History Versions'**
  String get historyVersions;

  /// No description provided for @confirmRestoreHistory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore to this version?\nThis will overwrite current local data.'**
  String get confirmRestoreHistory;

  /// No description provided for @noHistoryVersions.
  ///
  /// In en, this message translates to:
  /// **'No history versions'**
  String get noHistoryVersions;

  /// No description provided for @aiGenerate.
  ///
  /// In en, this message translates to:
  /// **'AI Generate'**
  String get aiGenerate;

  /// No description provided for @aiGenerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter description, AI will generate a custom task template for you'**
  String get aiGenerateDesc;

  /// No description provided for @aiPlanning.
  ///
  /// In en, this message translates to:
  /// **'AI is planning...'**
  String get aiPlanning;

  /// No description provided for @aiGeneratingTasks.
  ///
  /// In en, this message translates to:
  /// **'Generating tasks and detailed steps'**
  String get aiGeneratingTasks;

  /// No description provided for @aiGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Generation failed, please try again'**
  String get aiGenerateFailed;

  /// No description provided for @aiGenerateFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Generation failed: {error}\nRetry?'**
  String aiGenerateFailedRetry(String error);

  /// No description provided for @aiGenerateTemplate.
  ///
  /// In en, this message translates to:
  /// **'AI Generate Template'**
  String get aiGenerateTemplate;

  /// No description provided for @aiGenerateHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the task list you want, e.g.:\n- \"7-day travel plan to Yunnan\"\n- \"Marathon training plan\"\n- \"New house decoration process\"'**
  String get aiGenerateHint;

  /// No description provided for @aiGenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Now'**
  String get aiGenerateButton;

  /// No description provided for @aiPreview.
  ///
  /// In en, this message translates to:
  /// **'AI Generation Preview'**
  String get aiPreview;

  /// No description provided for @aiConfiguration.
  ///
  /// In en, this message translates to:
  /// **'AI Configuration'**
  String get aiConfiguration;

  /// No description provided for @aiConfigurationDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure your DeepSeek API key to enable AI features'**
  String get aiConfigurationDescription;

  /// No description provided for @aiApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get aiApiKey;

  /// No description provided for @aiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-...'**
  String get aiApiKeyHint;

  /// No description provided for @aiBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'API Base URL'**
  String get aiBaseUrl;

  /// No description provided for @aiModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get aiModel;

  /// No description provided for @aiConfigStoredHint.
  ///
  /// In en, this message translates to:
  /// **'Stored in plain text on this device only. Requests are sent directly to the endpoint above.'**
  String get aiConfigStoredHint;

  /// No description provided for @aiConfigSaved.
  ///
  /// In en, this message translates to:
  /// **'AI configuration saved'**
  String get aiConfigSaved;

  /// No description provided for @aiConfigCleared.
  ///
  /// In en, this message translates to:
  /// **'AI configuration reset to default'**
  String get aiConfigCleared;

  /// No description provided for @aiApiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your API Key'**
  String get aiApiKeyRequired;

  /// No description provided for @aiConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get aiConfigured;

  /// No description provided for @aiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get aiNotConfigured;

  /// No description provided for @aiPolishResult.
  ///
  /// In en, this message translates to:
  /// **'AI Polished Result'**
  String get aiPolishResult;

  /// No description provided for @aiReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get aiReplace;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @taskUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Task update failed'**
  String get taskUpdateFailed;

  /// No description provided for @backgroundVideoSet.
  ///
  /// In en, this message translates to:
  /// **'Background video set'**
  String get backgroundVideoSet;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
