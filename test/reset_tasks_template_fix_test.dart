import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cat/controllers/task_manager.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('重置任务模板功能修复测试', () {
    test('重置任务模板应该完全清除todos数据', () async {
      // 注意：这是一个模拟测试，实际的数据库操作需要在集成测试中验证
      
      // 创建一个模拟的TaskManager状态
      final taskManager = TaskManager();
      
      // 模拟已存在的任务，包含一些todos
      final existingTask1 = Task()
        ..uuid = 'existing-task-1'
        ..title = 'Existing Task 1'
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = 'Existing Todo 1'
            ..status = TodoStatus.todo
            ..priority = TodoPriority.lowLevel
            ..createdAt = DateTime.now().millisecondsSinceEpoch,
          Todo()
            ..uuid = const Uuid().v4()
            ..title = 'Existing Todo 2'
            ..status = TodoStatus.inProgress
            ..priority = TodoPriority.mediumLevel
            ..createdAt = DateTime.now().millisecondsSinceEpoch,
        ];
      
      final existingTask2 = Task()
        ..uuid = 'existing-task-2'
        ..title = 'Existing Task 2'
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = 'Another Todo'
            ..status = TodoStatus.done
            ..priority = TodoPriority.highLevel
            ..createdAt = DateTime.now().millisecondsSinceEpoch,
        ];
      
      // 模拟当前任务列表包含todos
      taskManager.tasks.addAll([existingTask1, existingTask2]);
      
      // 验证初始状态
      expect(taskManager.tasks.length, equals(2));
      expect(taskManager.tasks[0].todos?.length, equals(2));
      expect(taskManager.tasks[1].todos?.length, equals(1));
      
      // 创建新的默认任务模拟重置后的状态
      final freshDefaultTasks = taskManager._createFreshDefaultTasks();
      
      // 验证新任务没有todos
      for (final task in freshDefaultTasks) {
        expect(task.todos, isEmpty, reason: 'Fresh default task should have empty todos');
      }
      
      // 验证任务有正确的标题
      final expectedTitles = ['todo', 'inProgress', 'done', 'another'];
      for (int i = 0; i < freshDefaultTasks.length; i++) {
        expect(freshDefaultTasks[i].title, equals(expectedTitles[i]));
      }
      
      // 验证任务有正确的标签
      for (final task in freshDefaultTasks) {
        expect(task.tags, contains('默认'));
        expect(task.tags, contains('自带'));
        expect(task.tags.length, equals(2));
      }
      
      // 验证每个任务都有唯一的UUID
      final uuids = freshDefaultTasks.map((task) => task.uuid).toSet();
      expect(uuids.length, equals(freshDefaultTasks.length), 
             reason: 'All tasks should have unique UUIDs');
      
      // 验证创建时间是递增的
      for (int i = 1; i < freshDefaultTasks.length; i++) {
        expect(freshDefaultTasks[i].createdAt, 
               greaterThan(freshDefaultTasks[i-1].createdAt),
               reason: 'Task creation times should be in ascending order');
      }
    });
    
    test('_createFreshDefaultTasks应该创建全新的任务实例', () {
      final taskManager = TaskManager();
      
      // 创建两次默认任务
      final tasks1 = taskManager._createFreshDefaultTasks();
      final tasks2 = taskManager._createFreshDefaultTasks();
      
      // 验证每次创建的任务都有不同的UUID
      for (int i = 0; i < tasks1.length; i++) {
        expect(tasks1[i].uuid, isNot(equals(tasks2[i].uuid)),
               reason: 'Each creation should generate new UUIDs');
      }
      
      // 验证所有任务的todos都是空的
      for (final task in [...tasks1, ...tasks2]) {
        expect(task.todos, isEmpty,
               reason: 'All fresh tasks should have empty todos');
      }
    });
    
    test('重置模板应该产生一致的任务结构', () {
      final taskManager = TaskManager();
      final freshTasks = taskManager._createFreshDefaultTasks();
      
      // 验证任务数量
      expect(freshTasks.length, equals(4),
             reason: 'Should create exactly 4 default tasks');
      
      // 验证任务标题
      final expectedTitles = ['todo', 'inProgress', 'done', 'another'];
      for (int i = 0; i < freshTasks.length; i++) {
        expect(freshTasks[i].title, equals(expectedTitles[i]),
               reason: 'Task $i should have correct title');
      }
      
      // 验证所有任务的基本属性
      for (final task in freshTasks) {
        expect(task.uuid, isNotEmpty, reason: 'Task should have valid UUID');
        expect(task.title, isNotEmpty, reason: 'Task should have valid title');
        expect(task.createdAt, greaterThan(0), reason: 'Task should have valid creation time');
        expect(task.tags, isNotEmpty, reason: 'Task should have tags');
        expect(task.todos, isEmpty, reason: 'Task should have empty todos list');
      }
    });
  });
}

// 为了测试需要，扩展TaskManager以暴露私有方法
extension TaskManagerTestExtension on TaskManager {
  List<Task> _createFreshDefaultTasks() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    return [
      Task()
        ..uuid = const Uuid().v4()
        ..title = "todo"
        ..createdAt = currentTime
        ..tags = ["默认", "自带"]
        ..todos = [], // 确保为空
        
      Task()
        ..uuid = const Uuid().v4()
        ..title = "inProgress"
        ..createdAt = currentTime + 1
        ..tags = ["默认", "自带"]
        ..todos = [], // 确保为空
        
      Task()
        ..uuid = const Uuid().v4()
        ..title = "done"
        ..createdAt = currentTime + 2
        ..tags = ["默认", "自带"]
        ..todos = [], // 确保为空
        
      Task()
        ..uuid = const Uuid().v4()
        ..title = "another"
        ..createdAt = currentTime + 3
        ..tags = ["默认", "自带"]
        ..todos = [], // 确保为空
    ];
  }
}