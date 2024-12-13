import 'dart:async';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/services/repositorys/local_notice.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio;
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

const baseUrl = 'https://express-tozj-72009-4-1321092629.sh.run.tcloudbase.com';

/// 本地通知管理器类
class LocalNotificationManager {
  static final _logger = Logger();
  static LocalNotificationManager? _instance;
  late final LocalNoticeRepository _repository;
  final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  LocalNotificationManager._();

  /// 获取单例实例
  static Future<LocalNotificationManager> getInstance() async {
    _instance ??= LocalNotificationManager._();
    await _instance!._init();
    return _instance!;
  }

  /// 初始化本地通知管理器
  Future<void> _init() async {
    _repository = await LocalNoticeRepository.getInstance();
    // 初始化时区数据
    tz.initializeTimeZones();
    await _initializeLocalNotification();
  }

  /// 保存通知
  Future<void> saveNotification({
    required String key,
    required LocalNotice notice,
    required bool emailReminderEnabled,
  }) async {
    try {
      // 保存通知到 Isar
      await _repository.write(key, notice..noticeId = key);

      // 设置本地通知
      await _setLocalNotification(notice);

      // 如果启用了邮件提醒，设置邮件通知
      if (emailReminderEnabled) {
        await _setEmailNotification(notice);
      }
    } catch (e) {
      _logger.e('Error saving notification: $e');
    }
  }

  /// 销毁通知
  Future<void> destroy({
    required String timerKey,
    bool sendDeleteReq = false,
  }) async {
    try {
      // 首先删除本地数据库中的通知
      await _repository.delete(timerKey);

      // 取消本地通知
      await _cancelLocalNotification(timerKey);

      // 如果需要，尝试发送删除请求，但不阻止其他操作
      if (sendDeleteReq) {
        try {
          await _sendDeleteRequest(timerKey);
        } catch (e) {
          _logger.w('Failed to send delete request: $e');
          // 不抛出异常，因为这是非关键操作
        }
      }
    } catch (e) {
      _logger.e('Error destroying notification: $e');
      rethrow;
    }
  }

  /// 检查所有本地通知
  Future<void> checkAllLocalNotification() async {
    try {
      final notices = await _repository.readAll();
      for (var notice in notices) {
        if (notice.remindersAt > DateTime.now().millisecondsSinceEpoch) {
          await _setLocalNotification(notice);
        } else {
          await destroy(timerKey: notice.noticeId);
        }
      }
    } catch (e) {
      _logger.e('Error checking notifications: $e');
    }
  }

  /// 销毁所有本地通知
  Future<void> destroyLocalNotification() async {
    try {
      await _flutterLocalNotifications.cancelAll();
    } catch (e) {
      _logger.e('Error destroying all notifications: $e');
    }
  }

  /// 创建 Dio 实例
  Dio _createDio() {
    final dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) => 'DIRECT';
        // 设置更合理的超时时间
        client.connectionTimeout = const Duration(seconds: 5);
        return client;
      },
    );

    // 添加重试拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionTimeout) {
            _logger.w('Request timeout, retrying...');
            // 可以在这里添加重试逻辑
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// 初始化本地通知
  Future<void> _initializeLocalNotification() async {
    // Windows平台本地通知插件初始化
    if (Platform.isWindows) {
      await localNotifier.setup(appName: 'TodoCat');
    }

    // 其他平台本地通知插件初始化
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    await _flutterLocalNotifications.initialize(initializationSettings);
  }

  /// 设置本地通知
  Future<void> _setLocalNotification(LocalNotice notice) async {
    final notificationTime =
        DateTime.fromMillisecondsSinceEpoch(notice.remindersAt);
    if (notificationTime.isBefore(DateTime.now())) return;

    if (Platform.isWindows) {
      final notification = LocalNotification(
        identifier: notice.noticeId,
        title: notice.title,
        body: notice.description,
      );
      notification.show();
    } else if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isLinux ||
        Platform.isMacOS) {
      const String groupKey = 'todoCatGroupKey';
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        notice.noticeId,
        notice.title,
        channelDescription: notice.description,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        groupKey: groupKey,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(categoryIdentifier: groupKey);

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // 转换为时区时间
      final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

      await _flutterLocalNotifications.zonedSchedule(
        notice.noticeId.hashCode,
        notice.title,
        notice.description,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// 取消本地通知
  Future<void> _cancelLocalNotification(String noticeId) async {
    if (Platform.isWindows) {
      // Windows平台不需要特别处理，通知会自动消失
    } else {
      await _flutterLocalNotifications.cancel(noticeId.hashCode);
    }
  }

  /// 设置邮件通知
  Future<void> _setEmailNotification(LocalNotice notice) async {
    final dio = _createDio();
    try {
      const String url = "$baseUrl/sendReminders";
      final response = await dio
          .post(
        url,
        data: {
          "id": notice.noticeId,
          "receivingEmail": notice.email,
          "title": notice.title,
          "description": notice.description,
          "remindersAt": notice.remindersAt
        },
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      )
          .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          _logger.w('Email request timed out for notice: ${notice.noticeId}');
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        showToast(
          "emailReminderSentSuccessfully".tr,
          toastStyleType: TodoCatToastStyleType.success,
        );
      } else {
        throw Exception('Failed to send email reminder');
      }
    } catch (e) {
      _logger.w('Error sending email notification: $e');
      showToast(
        "emailReminderSendingFailed".tr,
        toastStyleType: TodoCatToastStyleType.error,
      );
      // 不抛出异常，让调用者继续执行
    } finally {
      dio.close();
    }
  }

  /// 发送删除请求
  Future<void> _sendDeleteRequest(String noticeId) async {
    final dioClient = _createDio();
    try {
      const String url = "$baseUrl/destroyReminders";
      await dioClient
          .delete(
        url,
        data: {"id": noticeId},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          _logger.w('Delete request timed out for notice: $noticeId');
          return dio.Response(
            requestOptions: dio.RequestOptions(path: url),
            statusCode: 408,
          );
        },
      );
    } catch (e) {
      _logger.w('Error sending delete request: $e');
      // 不抛出异常，让调用者继续执行
    } finally {
      dioClient.close();
    }
  }
}
