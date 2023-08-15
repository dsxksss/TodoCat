// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 2;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      id: fields[0] as int,
      title: fields[1] as String,
      tags: (fields[3] as List).cast<String>(),
      createdAt: fields[5] as int,
      description: fields[2] as String,
      priority: fields[4] as TodoPriority,
      finishedAt: fields[6] as int,
      status: fields[7] as TodoStatus,
      reminders: fields[8] as int,
      progress: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.finishedAt)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.reminders)
      ..writeByte(9)
      ..write(obj.progress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TodoStatusAdapter extends TypeAdapter<TodoStatus> {
  @override
  final int typeId = 3;

  @override
  TodoStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TodoStatus.todo;
      case 1:
        return TodoStatus.inProgress;
      case 2:
        return TodoStatus.done;
      default:
        return TodoStatus.todo;
    }
  }

  @override
  void write(BinaryWriter writer, TodoStatus obj) {
    switch (obj) {
      case TodoStatus.todo:
        writer.writeByte(0);
        break;
      case TodoStatus.inProgress:
        writer.writeByte(1);
        break;
      case TodoStatus.done:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
