import 'package:hive/hive.dart';

part 'local_notice.g.dart';

@HiveType(typeId: 6)
class LocalNotice extends HiveObject {
  @HiveField(0)
  late String noticeId;

  @HiveField(1)
  late String title;
  
  @HiveField(2)
  late String description;
  
  @HiveField(3)
  late int createdAt;
  
  @HiveField(4)
  late int remindersAt;
  
  @HiveField(5)
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
