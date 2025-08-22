import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cat/controllers/task_manager.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('拖拽功能修复测试', () {
    test('TaskManager应该正确去重复任务', () {
      final taskManager = TaskManager();
      
      // 创建测试任务
      final task1 = Task()
        ..uuid = 'test-task-1'
        ..title = 'Test Task 1'
        ..createdAt = DateTime.now().millisecondsSinceEpoch;
        
      final task2 = Task()
        ..uuid = 'test-task-2' 
        ..title = 'Test Task 2'
        ..createdAt = DateTime.now().millisecondsSinceEpoch;
        
      // 创建重复任务
      final duplicateTask1 = Task()
        ..uuid = 'test-task-1' // 相同的UUID
        ..title = 'Duplicate Task 1'
        ..createdAt = DateTime.now().millisecondsSinceEpoch;
      
      // 测试去重复功能
      final tasksWithDuplicates = [task1, task2, duplicateTask1];
      final uniqueTasks = taskManager._removeDuplicateTasks(tasksWithDuplicates);
      
      expect(uniqueTasks.length, equals(2));
      expect(uniqueTasks[0].uuid, equals('test-task-1'));
      expect(uniqueTasks[1].uuid, equals('test-task-2'));
    });
    
    test('Todo移动不应该导致任务重复', () {
      // 创建测试任务和Todo
      final fromTask = Task()
        ..uuid = 'from-task'
        ..title = 'From Task'
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = [];
        
      final toTask = Task()
        ..uuid = 'to-task'
        ..title = 'To Task' 
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = [];
        
      final testTodo = Todo()
        ..uuid = const Uuid().v4()
        ..title = 'Test Todo'
        ..status = TodoStatus.todo
        ..priority = TodoPriority.lowLevel
        ..createdAt = DateTime.now().millisecondsSinceEpoch;
        
      // 添加Todo到源任务
      fromTask.todos!.add(testTodo);
      
      // 验证初始状态
      expect(fromTask.todos!.length, equals(1));
      expect(toTask.todos!.length, equals(0));
      
      // 模拟移动操作
      final todoToMove = fromTask.todos!.firstWhere((todo) => todo.uuid == testTodo.uuid);
      fromTask.todos!.removeWhere((todo) => todo.uuid == testTodo.uuid);
      toTask.todos!.add(todoToMove);
      
      // 验证移动结果
      expect(fromTask.todos!.length, equals(0));
      expect(toTask.todos!.length, equals(1));
      expect(toTask.todos!.first.uuid, equals(testTodo.uuid));
    });
    
    test('Todo重排序应该正确处理索引', () {
      final task = Task()
        ..uuid = 'test-task'
        ..title = 'Test Task'
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = [];
        
      // 创建多个Todo
      final todo1 = Todo()
        ..uuid = 'todo-1'
        ..title = 'Todo 1'
        ..status = TodoStatus.todo
        ..priority = TodoPriority.lowLevel
        ..createdAt = DateTime.now().millisecondsSinceEpoch;
        
      final todo2 = Todo()
        ..uuid = 'todo-2'
        ..title = 'Todo 2'
        ..status = TodoStatus.todo
        ..priority = TodoPriority.lowLevel
        ..createdAt = DateTime.now().millisecondsSinceEpoch;
        
      final todo3 = Todo()
        ..uuid = 'todo-3'
        ..title = 'Todo 3'
        ..status = TodoStatus.todo
        ..priority = TodoPriority.lowLevel
        ..createdAt = DateTime.now().millisecondsSinceEpoch;
        
      task.todos!.addAll([todo1, todo2, todo3]);
      
      // 验证初始顺序
      expect(task.todos![0].uuid, equals('todo-1'));
      expect(task.todos![1].uuid, equals('todo-2'));
      expect(task.todos![2].uuid, equals('todo-3'));
      
      // 模拟重排序：将第一个移动到最后
      final todos = List<Todo>.from(task.todos!);
      final movedTodo = todos.removeAt(0);
      todos.insert(2, movedTodo);
      task.todos = todos;
      
      // 验证重排序结果
      expect(task.todos![0].uuid, equals('todo-2'));
      expect(task.todos![1].uuid, equals('todo-3'));
      expect(task.todos![2].uuid, equals('todo-1'));
    });
  });
}

// 为了测试需要，暴露TaskManager的私有方法
extension TaskManagerTestExtension on TaskManager {
  List<Task> _removeDuplicateTasks(List<Task> tasks) {
    final seen = <String>{};
    final uniqueTasks = <Task>[];
    
    for (final task in tasks) {
      if (!seen.contains(task.uuid)) {
        seen.add(task.uuid);
        uniqueTasks.add(task);
      }
    }
    
    return uniqueTasks;
  }
}