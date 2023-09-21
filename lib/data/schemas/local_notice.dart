import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part "local_notice.g.dart";
part 'local_notice.freezed.dart';

@HiveType(typeId: 5)
@unfreezed
class LocalNotice with _$LocalNotice {
  factory LocalNotice({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required int createdAt,
    @HiveField(4) required int remindersAt,
    @HiveField(5) required String email,
  }) = _LocalNotice;
}
