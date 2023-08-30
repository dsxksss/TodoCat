import 'dart:async';

import 'package:local_notifier/local_notifier.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/services/repositorys/local_notice.dart';

class LocalNotificationManager {
  late final LocalNoticeRepository localNoticeRepository;
  late final Map<String, Timer> timerPool;

  LocalNotificationManager._();

  static LocalNotificationManager? _instance;

  static Future<LocalNotificationManager> getInstance() async {
    if (_instance == null) {
      _instance = LocalNotificationManager._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    localNoticeRepository = await LocalNoticeRepository.getInstance();
    timerPool = {};
  }

  void registerNotification(DateTime specifiedTime, LocalNotice notice) {
    DateTime currentTime = DateTime.now();

    if (currentTime.isBefore(specifiedTime)) {
      final timer = Timer(
        specifiedTime.difference(currentTime),
        () {
          LocalNotification notification = LocalNotification(
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

  void checkAllLocalNotification() async {
    List<LocalNotice> localNotices = await localNoticeRepository.readAll();
    for (LocalNotice notice in localNotices) {
      registerNotification(
        DateTime.fromMillisecondsSinceEpoch(notice.remindersAt),
        notice,
      );
    }
  }

  void destroy(String timerKey) {
    final timer = timerPool[timerKey];
    if (timer != null) {
      timer.cancel();
    }
    timerPool.remove(timerKey);
  }

  void destroyLocalNotification() {
    timerPool.forEach((key, value) {
      value.cancel();
    });

    timerPool.clear();
  }
}
