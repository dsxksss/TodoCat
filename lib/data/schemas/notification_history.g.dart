// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationHistoryAdapter extends TypeAdapter<NotificationHistory> {
  @override
  final int typeId = 7;

  @override
  NotificationHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationHistory()
      ..notificationId = fields[0] as String
      ..title = fields[1] as String
      ..message = fields[2] as String
      ..level = fields[3] as int
      ..timestamp = fields[4] as DateTime
      ..isRead = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, NotificationHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.notificationId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
