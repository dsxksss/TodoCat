import 'package:get/get.dart';

const int minTimestampLength = 1000000000000;

String timestampToDate(int timestamp) {
  if (timestamp.isLowerThan(minTimestampLength)) {
    return "unknownDate".tr;
  }

  // 将时间戳转换为 DateTime 对象
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // 将 DateTime 对象格式化为特定日期格式
  String formattedDate =
      "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";

  return formattedDate;
}
