import 'package:todo_cat/data/schemas/app_config.dart';

import '../strorage.dart';

class AppConfigRepository extends Storage<AppConfig> {
  static AppConfigRepository? _instance;

  AppConfigRepository._();

  static Future<AppConfigRepository> getInstance() async {
    _instance ??= AppConfigRepository._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    await init('appConfigx');
  }
}
