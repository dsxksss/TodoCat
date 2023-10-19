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

class LocalNotificationManager {
  late final LocalNoticeRepository localNoticeRepository;
  final Map<String, Timer> timerPool = {};

  LocalNotificationManager._();

  static LocalNotificationManager? _instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<LocalNotificationManager> getInstance() async {
    _instance ??= LocalNotificationManager._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    // winodws平台本地通知插件初始化
    await localNotifier.setup(appName: 'TodoCat');

    // 其他平台本地通知插件初始化

    // AndroidInitializationSettings是一个用于设置Android上的本地通知初始化的类
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // DarwinInitializationSettings是一个用于设置IOS以及MacOS上的本地通知初始化的类
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    // LinuxInitializationSettings是一个用于设置Linux上的本地通知初始化的类
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
          // 安卓的通知
          // 'your channel id'：用于指定通知通道的ID。
          // 'your channel name'：用于指定通知通道的名称。
          // 'your channel description'：用于指定通知通道的描述。
          // Importance.max：用于指定通知的重要性，设置为最高级别。
          // Priority.high：用于指定通知的优先级，设置为高优先级。
          // 'ticker'：用于指定通知的提示文本，即通知出现在通知中心的文本内容。
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

          // ios的通知
          const DarwinNotificationDetails iosNotificationDetails =
              DarwinNotificationDetails(categoryIdentifier: groupKey);

          // 创建跨平台通知
          NotificationDetails platformChannelSpecifics = NotificationDetails(
              android: androidNotificationDetails, iOS: iosNotificationDetails);

          // 发起一个通知
          _notificationsPlugin.show(
            notice.id.hashCode,
            notice.title,
            notice.description,
            platformChannelSpecifics,
          );
        }

        await Future.delayed(
          2000.ms,
          () => {
            // 销毁通知数据
            destroy(timerKey: notice.id),
          },
        );
      });
      timerPool[notice.id] = timer;
    }
  }

  void saveNotification(
      {required String key,
      required LocalNotice notice,
      bool emailReminderEnabled = false}) async {
    // email notification
    Dio dio = Dio();

    // 设置代理为空
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'DIRECT';
        };
        return client;
      },
    );

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
            throw Exception();
          }
        });
      }
    } catch (_) {
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

  Future<void> checkAllLocalNotification() async {
    final localNotices = await localNoticeRepository.readAll();
    for (final notice in localNotices) {
      registerNotification(
        DateTime.fromMillisecondsSinceEpoch(notice.remindersAt),
        notice,
      );
    }
  }

  void destroy({required String timerKey, bool sendDeleteReq = false}) async {
    // email notification
    Dio dio = Dio();

    // 设置代理为空
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'DIRECT';
        };
        return client;
      },
    );
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
    } catch (_) {
    } finally {
      final timer = timerPool.remove(timerKey);
      timer?.cancel();
    }
  }

  void destroyLocalNotification() {
    for (var timerKey in timerPool.keys) {
      destroy(timerKey: timerKey, sendDeleteReq: true);
    }

    timerPool.clear();
  }
}
