import 'package:get/get.dart';
import 'package:todo_cat/locales/lang/en_us.dart';
import 'package:todo_cat/locales/lang/zh_cn.dart';

class Locales extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': EN_US, 'zh_CN': ZH_CN};
}
