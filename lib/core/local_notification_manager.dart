import 'dart:async';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/services/repositorys/local_notice.dart';
import 'package:dio/dio.dart';
import 'package:todo_cat/widgets/show_toast.dart';

const baseUrl = 'https://express-tozj-72009-4-1321092629.sh.run.tcloudbase.com';

/// 本地通知管理器类
class LocalNotificationManager {
  late final LocalNoticeRepository localNoticeRepository;
  final Map<String, Timer> timerPool = {};

  LocalNotificationManager._();

  static LocalNotificationManager? _instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 获取单例实例
  static Future<LocalNotificationManager> getInstance() async {
    _instance ??= LocalNotificationManager._();
    await _instance!._init();
    return _instance!;
  }

  /// 初始化本地通知管理器
  Future<void> _init() async {
    // Windows平台本地通知插件初始化
    await localNotifier.setup(appName: 'TodoCat');

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
    await _notificationsPlugin.initialize(initializationSettings);

    localNoticeRepository = await LocalNoticeRepository.getInstance();
  }

  /// 注册通知
  void registerNotification(DateTime specifiedTime, LocalNotice notice) {
    final currentTime = DateTime.now();

    if (currentTime.isBefore(specifiedTime)) {
      final timer = Timer(specifiedTime.difference(currentTime), () async {
        final anotherPlatform = Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isLinux ||
            Platform.isMacOS;

        if (Platform.isWindows) {
          final notification = LocalNotification(
            identifier: notice.id,
            title: notice.title,
            body: notice.description,
          );
          notification.show();
        } else if (anotherPlatform) {
          const String groupKey = 'todoCatGroupKey';
          final AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails(
            notice.id,
            notice.title,
            channelDescription: notice.description,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            groupKey: groupKey,
          );

          const DarwinNotificationDetails iosNotificationDetails =
              DarwinNotificationDetails(categoryIdentifier: groupKey);

          final NotificationDetails platformChannelSpecifics =
              NotificationDetails(
                  android: androidNotificationDetails,
                  iOS: iosNotificationDetails);

          _notificationsPlugin.show(
            notice.id.hashCode,
            notice.title,
            notice.description,
            platformChannelSpecifics,
          );
        }

        await 2.delay(
          // 销毁通知数据
          () => destroy(timerKey: notice.id),
        );
      });
      timerPool[notice.id] = timer;
    }
  }

  /// 保存通知
  void saveNotification({
    required String key,
    required LocalNotice notice,
    bool emailReminderEnabled = false,
  }) async {
    final Dio dio = _createDio();

    try {
      if (emailReminderEnabled) {
        const String url = "$baseUrl/sendReminders";
        await dio
            .post(url,
                data: {
                  "id": notice.id,
                  "receivingEmail": notice.email,
                  "title": notice.title,
                  "description": notice.description,
                  "remindersAt": notice.remindersAt
                },
                options: Options(
                  sendTimeout: 1500.ms,
                  receiveTimeout: 1500.ms,
                ))
            .then((req) {
          if (req.statusCode == 200) {
            showToast("emailReminderSentSuccessfully".tr,
                toastStyleType: TodoCatToastStyleType.success);
          } else {
            throw Exception('Failed to send email reminder');
          }
        });
      }
    } catch (e) {
      showToast(
        "emailReminderSendingFailed".tr,
        toastStyleType: TodoCatToastStyleType.error,
      );
    } finally {
      localNoticeRepository.write(key, notice);
      registerNotification(
        DateTime.fromMillisecondsSinceEpoch(notice.remindersAt),
        notice,
      );
    }
  }

  /// 检查所有本地通知
  Future<void> checkAllLocalNotification() async {
    final localNotices = await localNoticeRepository.readAll();
    for (final notice in localNotices) {
      registerNotification(
        DateTime.fromMillisecondsSinceEpoch(notice.remindersAt),
        notice,
      );
    }
  }

  /// 销毁通知
  void destroy({required String timerKey, bool sendDeleteReq = false}) async {
    final Dio dio = _createDio();
    try {
      const String url = "$baseUrl/destroyReminders";
      if (sendDeleteReq && timerPool.containsKey(timerKey)) {
        await dio.delete(url,
            data: {"id": timerKey},
            options: Options(
              sendTimeout: 1500.ms,
              receiveTimeout: 1500.ms,
            ));
      }
    } catch (e) {
      // 错误处理
    } finally {
      final timer = timerPool.remove(timerKey);
      timer?.cancel();
    }
  }

  /// 销毁所有本地通知
  void destroyLocalNotification() {
    for (var timerKey in timerPool.keys) {
      destroy(timerKey: timerKey, sendDeleteReq: true);
    }

    timerPool.clear();
  }

  /// 创建 Dio 实例
  Dio _createDio() {
    final dio = Dio();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'DIRECT';
        };
        return client;
      },
    );
    return dio;
  }
}
