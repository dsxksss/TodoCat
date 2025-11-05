/// LocalNotice 数据模型
/// 注意：已迁移到 Drift，不再使用 Isar 注解
class LocalNotice {
  int? id;
  late String noticeId;

  late String title;
  late String description;
  late int createdAt;
  late int remindersAt;
  late String email;

  LocalNotice({
    required this.noticeId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.remindersAt,
    required this.email,
  });
}
