import 'dart:async';

import 'package:local_notifier/local_notifier.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/services/repositorys/local_notice.dart';

class LocalNotificationManager {
  late final LocalNoticeRepository localNoticeRepository;
  final Map<String, Timer> timerPool = {};

  LocalNotificationManager._();

  static LocalNotificationManager? _instance;

  static Future<LocalNotificationManager> getInstance() async {
    _instance ??= LocalNotificationManager._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    localNoticeRepository = await LocalNoticeRepository.getInstance();
  }

  void registerNotification(DateTime specifiedTime, LocalNotice notice) {
    final currentTime = DateTime.now();

    if (currentTime.isBefore(specifiedTime)) {
      final timer = Timer(
        specifiedTime.difference(currentTime),
        () {
          final notification = LocalNotification(
            identifier: notice.id,
            title: notice.title,
            body: notice.description,
          );
          notification.show();
          destroy(notice.id);
        },
      );
      timerPool[notice.id] = timer;
    }
  }

  void saveNotification(String key, LocalNotice notice) {
    localNoticeRepository.write(key, notice);
    registerNotification(
      DateTime.fromMillisecondsSinceEpoch(notice.remindersAt),
      notice,
    );
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

  void destroy(String timerKey) {
    final timer = timerPool.remove(timerKey);
    timer?.cancel();
  }

  void destroyLocalNotification() {
    for (var timer in timerPool.values) {
      timer.cancel();
    }

    timerPool.clear();
  }
}
