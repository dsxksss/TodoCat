import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/services/strorage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_cat/env.dart';
import 'package:uuid/uuid.dart';

class TaskRepository extends Strorage<Task> {
  late Box<Task> _box;
  final taskKey = 'tasksxxxawxxc';

  final Task _task1 = Task(
    id: const Uuid().v4(),
    title: "todo".tr,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    tags: ["默认", "自带"],
    todos: [],
  );
  final Task _task2 = Task(
    id: const Uuid().v4(),
    title: "inProgress".tr,
    createdAt: DateTime.now().millisecondsSinceEpoch + 1,
    tags: ["默认", "自带"],
    todos: [],
  );
  final Task _task3 = Task(
    id: const Uuid().v4(),
    title: "done".tr,
    createdAt: DateTime.now().millisecondsSinceEpoch + 2,
    tags: ["默认", "自带"],
    todos: [],
  );
  final Task _task4 = Task(
    id: const Uuid().v4(),
    title: "another".tr,
    createdAt: DateTime.now().millisecondsSinceEpoch + 3,
    tags: ["默认", "自带"],
    todos: [],
  );

  // 私有构造函数
  TaskRepository._();

  // 单例实例
  static TaskRepository? _instance;

  static Future<TaskRepository> getInstance() async {
    if (_instance == null) {
      _instance = TaskRepository._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    // 注册Hive数据模板
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(TodoStatusAdapter());
    Hive.registerAdapter(TodoPriorityAdapter());

    // 开启数据盒
    await Hive.openBox<Task>(taskKey);
    _box = Hive.box(taskKey);

    if (isDebugMode) {
      await _box.clear();
      writeMany([_task1, _task2, _task3, _task4]);
    }
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
      write(element.id, element);
    }
  }

  @override
  bool has(String key) {
    return _box.containsKey(key);
  }

  bool hasNot(String key) {
    return !_box.containsKey(key);
  }

  @override
  void update(String key, Task value) async {
    await _box.put(key, value);
  }

  @override
  void updateMany(List<Task> values) {
    for (var element in values) {
      update(element.id, element);
    }
  }
}
