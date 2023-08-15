import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/data/services/strorage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskRepository extends Strorage<Task> {
  late Box<Task> _box;
  final taskKey = 'tasksxxxaw';
  final Task _task1 = Task(
    id: 1,
    title: "todo".tr,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    tags: [],
    todos: [],
  );
  final Task _task2 = Task(
    id: 2,
    title: "inProgress".tr,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    tags: [],
    todos: [],
  );
  final Task _task3 = Task(
    id: 3,
    title: "done".tr,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    tags: [],
    todos: [],
  );
  final Task _task4 = Task(
    id: 4,
    title: "another".tr,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    tags: [],
    todos: [],
  );

  Future<TaskRepository> init() async {
    // 注册Hive数据模板
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(TodoStatusAdapter());

    // 开启数据盒
    await Hive.openBox<Task>(taskKey);
    _box = Hive.box(taskKey);
    await _box.clear();

    writeMany([_task1, _task2, _task3, _task4]);
    return this;
  }

  @override
  Task? read(String key) {
    return _box.get(key);
  }

  @override
  void write(String key, Task value) async {
    if (!_box.containsKey(key)) {
      await _box.put(key, value);
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
