import 'dart:ui';
import 'package:todo_cat/data/schemas/app_config.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:uuid/uuid.dart';

// 学习英语任务
final Task englishLearningTask = Task()
  ..uuid = const Uuid().v4()
  ..title = "todo"
  ..description = "提升英语听说读写能力"
  ..createdAt = DateTime.now().millisecondsSinceEpoch
  ..tags = ["学习", "语言", "日常"]
  ..status = TaskStatus.todo
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "背诵50个新单词"
      ..description = "使用单词卡片或APP学习"
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..tags = ["词汇", "背诵"]
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "听英语播客30分钟"
      ..description = "选择感兴趣的英语播客内容"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
      ..tags = ["听力", "播客"]
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "完成英语作文练习"
      ..description = "写一篇200词的议论文"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 2
      ..tags = ["写作", "练习"]
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "英语口语练习"
      ..description = "与同学或老师进行英语对话"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 3
      ..tags = ["口语", "对话"]
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch,
  ];

// 编程项目任务
final Task programmingTask = Task()
  ..uuid = const Uuid().v4()
  ..title = "inProgress"
  ..description = "完成个人编程项目"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
  ..tags = ["编程", "项目", "技术"]
  ..status = TaskStatus.inProgress
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "设计项目架构"
      ..description = "绘制系统架构图和数据库设计"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
      ..tags = ["设计", "架构"]
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.done
      ..finishedAt = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "实现用户认证功能"
      ..description = "完成登录、注册、密码重置等功能"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 11
      ..tags = ["开发", "认证"]
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.inProgress
      ..progress = 60
      ..dueDate = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "编写单元测试"
      ..description = "为核心功能编写测试用例"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 12
      ..tags = ["测试", "质量"]
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 4)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "部署到云服务器"
      ..description = "配置生产环境并部署应用"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 13
      ..tags = ["部署", "运维"]
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
  ];

// 音乐爱好任务
final Task musicTask = Task()
  ..uuid = const Uuid().v4()
  ..title = "done"
  ..description = "提升音乐技能和表演能力"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
  ..tags = ["音乐", "爱好", "艺术"]
  ..status = TaskStatus.done
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "练习新歌曲"
      ..description = "学习一首新的流行歌曲"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
      ..tags = ["唱歌", "练习"]
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "参加音乐社团活动"
      ..description = "参与学校音乐社团的排练"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 21
      ..tags = ["社团", "活动"]
      ..priority = TodoPriority.lowLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "录制翻唱视频"
      ..description = "录制并发布一首翻唱歌曲"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 22
      ..tags = ["录制", "分享"]
      ..priority = TodoPriority.lowLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 10)).millisecondsSinceEpoch,
  ];

// 日常生活任务
final Task dailyLifeTask = Task()
  ..uuid = const Uuid().v4()
  ..title = "dailyLifeManagement"
  ..description = "管理日常学习和生活事务"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
  ..tags = ["生活", "管理", "日常"]
  ..status = TaskStatus.todo
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "整理学习笔记"
      ..description = "整理本周的学习笔记和资料"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
      ..tags = ["整理", "笔记"]
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "准备下周课程"
      ..description = "预习下周要学习的内容"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 31
      ..tags = ["预习", "课程"]
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "运动锻炼"
      ..description = "进行30分钟的有氧运动"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 32
      ..tags = ["运动", "健康"]
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "与朋友聚餐"
      ..description = "和同学朋友一起聚餐交流"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 33
      ..tags = ["社交", "聚餐"]
      ..priority = TodoPriority.lowLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 6)).millisecondsSinceEpoch,
  ];

// 空模板任务（标准模板）
final Task emptyTask1 = Task()
  ..uuid = const Uuid().v4()
  ..title = "todo"
  ..createdAt = DateTime.now().millisecondsSinceEpoch
  ..tags = ["默认", "自带"]
  ..todos = [];

final Task emptyTask2 = Task()
  ..uuid = const Uuid().v4()
  ..title = "inProgress"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
  ..tags = ["默认", "自带"]
  ..todos = [];

final Task emptyTask3 = Task()
  ..uuid = const Uuid().v4()
  ..title = "done"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 2
  ..tags = ["默认", "自带"]
  ..todos = [];

final Task emptyTask4 = Task()
  ..uuid = const Uuid().v4()
  ..title = "another"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 3
  ..tags = ["默认", "自带"]
  ..todos = [];

// 空模板（标准模板）
final emptyTemplateTasks = [emptyTask1, emptyTask2, emptyTask3, emptyTask4];

// 有具体内容的模板（学生日程模板）
final contentTemplateTasks = [englishLearningTask, programmingTask, musicTask, dailyLifeTask];

// 默认使用内容模板
final defaultTasks = contentTemplateTasks;

final defaultAppConfig = AppConfig.create(
  configName: "defaultConfig",
  isDarkMode: true,
  locale: const Locale("zh", "CN"),
  emailReminderEnabled: false,
  isDebugMode: false,
);
