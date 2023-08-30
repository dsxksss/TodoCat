// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notice.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalNoticeAdapter extends TypeAdapter<LocalNotice> {
  @override
  final int typeId = 5;

  @override
  LocalNotice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalNotice(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as int,
      remindersAt: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LocalNotice obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.remindersAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalNoticeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
