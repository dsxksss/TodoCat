import 'package:get/get.dart';
import 'package:todo_cat/app/data/schemas/task.dart';
import 'package:todo_cat/app/data/schemas/todo.dart';
import 'package:todo_cat/app/data/services/strorage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskRepository extends Strorage<Task> {
  late Box<Task> _box;
  final taskKey = 'tasksxxxaw';
  final debugMode = false;

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
    Hive.registerAdapter(TodoPriorityAdapter());

    // 开启数据盒
    await Hive.openBox<Task>(taskKey);
    _box = Hive.box(taskKey);

    if (debugMode) {
      await _box.clear();
      writeMany([_task1, _task2, _task3, _task4]);
    }

    return this;
  }

  @override
  void onClose() {
    _box.close();
    super.onClose();
  }

  @override
  Task? read(String key) {
    return _box.get(key);
  }

  @override
  void write(String key, Task value) async {
    if (!has(key)) {
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

  @override
  void update(String key, Task value) async {
    await _box.put(key, value);
  }

  @override
  void updateMant(List<Task> values) {
    for (var element in values) {
      update(element.title, element);
    }
  }
}
