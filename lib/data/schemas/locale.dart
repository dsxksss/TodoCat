import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleAdapter extends TypeAdapter<Locale> {
  @override
  Locale read(BinaryReader reader) {
    final languageCode = reader.readString();
    final countryCode = reader.readString();
    return Locale(languageCode, countryCode);
  }

  @override
  int get typeId => 7;

  @override
  void write(BinaryWriter writer, Locale obj) {
    writer.writeString(obj.languageCode);
    writer.writeString(obj.countryCode ?? '');
  }
}
