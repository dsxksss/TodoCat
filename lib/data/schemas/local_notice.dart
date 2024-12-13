import 'package:isar/isar.dart';

part 'local_notice.g.dart';

@collection
class LocalNotice {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
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
