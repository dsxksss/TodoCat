import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/services/strorage.dart';
import 'package:todo_cat/controllers/app_ctr.dart';

class LocalNoticeRepository extends Storage<LocalNotice> {
  final AppController appCtrl = Get.find();
  static LocalNoticeRepository? _instance;

  LocalNoticeRepository._();

  static Future<LocalNoticeRepository> getInstance() async {
    _instance ??= LocalNoticeRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    await init('localNoticesx');
    if (appCtrl.appConfig.value.isDebugMode) {
      await box?.clear();
    }
  }
}
