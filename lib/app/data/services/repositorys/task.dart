import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/services/strorage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskRepository extends Strorage<Task> {
  late Box<Task> _box;
  final taskKey = 'task';
  final Task _task1 =
      Task(title: "todo".tr, icon: 1, color: '#000000', todos: []);
  final Task _task2 =
      Task(title: "inProgress".tr, icon: 1, color: '#000000', todos: []);
  final Task _task3 =
      Task(title: "done".tr, icon: 1, color: '#000000', todos: []);

  Future<TaskRepository> init() async {
    // 注册Hive数据模板
    Hive.registerAdapter(TaskAdapter());
    // 开启数据盒
    await Hive.openBox<Task>(taskKey);
    _box = Hive.box(taskKey);
    write(_task1.title, _task1);
    write(_task2.title, _task2);
    write(_task3.title, _task3);
    return this;
  }

  @override
  Task? read(String key) {
    return _box.get(key);
  }

  @override
  void write(String key, Task value) {
    if (!_box.containsKey(key)) {
      _box.put(key, value);
    }
  }

  @override
  void delete(String key) {
    _box.delete(key);
  }

  @override
  Future<List<Task>> readAll() async {
    return _box.values.toList();
  }

  @override
  void writeMany(List<Task> values) {
    for (var element in values) {
      write(element.title, element);
    }
  }

  @override
  bool has(String key) {
    return _box.containsKey(key);
  }
}
