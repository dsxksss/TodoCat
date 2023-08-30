import 'package:get/get.dart';

abstract class Strorage<T> extends GetxService {
  T? read(String key);
  Future<List<dynamic>> readAll();
  void write(String key, T value);
  void writeMany(List<T> values);
  void update(String key, T value);
  void updateMany(List<T> values);
  void delete(String key);
  bool has(String key);
}
