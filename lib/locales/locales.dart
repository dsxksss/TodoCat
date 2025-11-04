import 'package:get/get.dart';
import 'package:TodoCat/locales/lang/en_us.dart';
import 'package:TodoCat/locales/lang/zh_cn.dart';

class Locales extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUS, 'zh_CN': zhCN};
}
