import 'package:TodoCat/data/schemas/app_config.dart';
import 'package:TodoCat/data/schemas/task.dart';
import 'package:TodoCat/data/schemas/todo.dart';
import 'package:TodoCat/data/schemas/tag_with_color.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

// 辅助函数：创建带颜色的标签
// 根据tag名称选择颜色，确保相同名称的tag总是得到相同的颜色
List<TagWithColor> _createTagsWithColors(List<String> tagNames, List<Color> colors) {
  return tagNames.map((tagName) {
    // 根据标签名称的hashCode选择颜色
    final colorIndex = tagName.hashCode.abs() % colors.length;
    final color = colors[colorIndex];
    return TagWithColor(name: tagName, color: color);
  }).toList();
}

// 预定义的颜色列表
final List<Color> _tagColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
];

// 学习英语任务
final Task englishLearningTask = Task()
  ..uuid = const Uuid().v4()
  ..title = "todo"
  ..description = "提升英语听说读写能力"
  ..createdAt = DateTime.now().millisecondsSinceEpoch
  ..tagsWithColor = _createTagsWithColors(["学习", "语言", "日常"], _tagColors)
  ..status = TaskStatus.todo
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "背诵50个新单词"
      ..description = "使用单词卡片或APP学习"
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..tagsWithColor = _createTagsWithColors(["词汇", "背诵"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "听英语播客30分钟"
      ..description = "选择感兴趣的英语播客内容"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
      ..tagsWithColor = _createTagsWithColors(["听力", "播客"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "完成英语作文练习"
      ..description = "写一篇200词的议论文"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 2
      ..tagsWithColor = _createTagsWithColors(["写作", "练习"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "英语口语练习"
      ..description = "与同学或老师进行英语对话"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 3
      ..tagsWithColor = _createTagsWithColors(["口语", "对话"], _tagColors)
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
  ..tagsWithColor = _createTagsWithColors(["编程", "项目", "技术"], _tagColors)
  ..status = TaskStatus.inProgress
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "设计项目架构"
      ..description = "绘制系统架构图和数据库设计"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
      ..tagsWithColor = _createTagsWithColors(["设计", "架构"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.done
      ..finishedAt = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "实现用户认证功能"
      ..description = "完成登录、注册、密码重置等功能"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 11
      ..tagsWithColor = _createTagsWithColors(["开发", "认证"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.inProgress
      ..progress = 60
      ..dueDate = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "编写单元测试"
      ..description = "为核心功能编写测试用例"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 12
      ..tagsWithColor = _createTagsWithColors(["测试", "质量"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 4)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "部署到云服务器"
      ..description = "配置生产环境并部署应用"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 13
      ..tagsWithColor = _createTagsWithColors(["部署", "运维"], _tagColors)
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
  ..tagsWithColor = _createTagsWithColors(["音乐", "爱好", "艺术"], _tagColors)
  ..status = TaskStatus.done
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "练习新歌曲"
      ..description = "学习一首新的流行歌曲"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
      ..tagsWithColor = _createTagsWithColors(["唱歌", "练习"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "参加音乐社团活动"
      ..description = "参与学校音乐社团的排练"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 21
      ..tagsWithColor = _createTagsWithColors(["社团", "活动"], _tagColors)
      ..priority = TodoPriority.lowLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "录制翻唱视频"
      ..description = "录制并发布一首翻唱歌曲"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 22
      ..tagsWithColor = _createTagsWithColors(["录制", "分享"], _tagColors)
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
  ..tagsWithColor = _createTagsWithColors(["生活", "管理", "日常"], _tagColors)
  ..status = TaskStatus.todo
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "整理学习笔记"
      ..description = "整理本周的学习笔记和资料"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
      ..tagsWithColor = _createTagsWithColors(["整理", "笔记"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "准备下周课程"
      ..description = "预习下周要学习的内容"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 31
      ..tagsWithColor = _createTagsWithColors(["预习", "课程"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "运动锻炼"
      ..description = "进行30分钟的有氧运动"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 32
      ..tagsWithColor = _createTagsWithColors(["运动", "健康"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "与朋友聚餐"
      ..description = "和同学朋友一起聚餐交流"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 33
      ..tagsWithColor = _createTagsWithColors(["社交", "聚餐"], _tagColors)
      ..priority = TodoPriority.lowLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 6)).millisecondsSinceEpoch,
  ];

// 空模板任务（标准模板）
final Task emptyTask1 = Task()
  ..uuid = const Uuid().v4()
  ..title = "todo"
  ..createdAt = DateTime.now().millisecondsSinceEpoch
  ..tagsWithColor = _createTagsWithColors(["默认", "自带"], _tagColors)
  ..todos = [];

final Task emptyTask2 = Task()
  ..uuid = const Uuid().v4()
  ..title = "inProgress"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
  ..tagsWithColor = _createTagsWithColors(["默认", "自带"], _tagColors)
  ..todos = [];

final Task emptyTask3 = Task()
  ..uuid = const Uuid().v4()
  ..title = "done"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 2
  ..tagsWithColor = _createTagsWithColors(["默认", "自带"], _tagColors)
  ..todos = [];

final Task emptyTask4 = Task()
  ..uuid = const Uuid().v4()
  ..title = "another"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 3
  ..tagsWithColor = _createTagsWithColors(["默认", "自带"], _tagColors)
  ..todos = [];

// 工作管理任务模板
final Task workTask1 = Task()
  ..uuid = const Uuid().v4()
  ..title = "todo"
  ..description = "管理工作项目和任务"
  ..createdAt = DateTime.now().millisecondsSinceEpoch
  ..tagsWithColor = _createTagsWithColors(["工作", "项目管理"], _tagColors)
  ..status = TaskStatus.todo
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "准备项目提案"
      ..description = "收集需求并撰写项目建议书"
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..tagsWithColor = _createTagsWithColors(["提案", "文档"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "团队周会"
      ..description = "讨论项目进度和下周计划"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
      ..tagsWithColor = _createTagsWithColors(["会议", "协作"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch,
  ];

final Task workTask2 = Task()
  ..uuid = const Uuid().v4()
  ..title = "inProgress"
  ..description = "进行中的开发工作"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
  ..tagsWithColor = _createTagsWithColors(["开发", "进行中"], _tagColors)
  ..status = TaskStatus.inProgress
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "完成功能开发"
      ..description = "实现核心业务逻辑"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
      ..tagsWithColor = _createTagsWithColors(["开发", "功能"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.inProgress
      ..progress = 60
      ..dueDate = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
  ];

final Task workTask3 = Task()
  ..uuid = const Uuid().v4()
  ..title = "done"
  ..description = "已完成的工作"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
  ..tagsWithColor = _createTagsWithColors(["完成", "归档"], _tagColors)
  ..status = TaskStatus.done
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "提交代码"
      ..description = "代码审查并合并到主分支"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
      ..tagsWithColor = _createTagsWithColors(["代码", "审查"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.done
      ..finishedAt = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
  ];

final Task workTask4 = Task()
  ..uuid = const Uuid().v4()
  ..title = "another"
  ..description = "其他工作事项"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
  ..tagsWithColor = _createTagsWithColors(["工作", "待办"], _tagColors)
  ..status = TaskStatus.todo
  ..todos = [];

// 健身训练任务模板
final Task fitnessTask1 = Task()
  ..uuid = const Uuid().v4()
  ..title = "todo"
  ..description = "制定健身计划"
  ..createdAt = DateTime.now().millisecondsSinceEpoch
  ..tagsWithColor = _createTagsWithColors(["健身", "计划"], _tagColors)
  ..status = TaskStatus.todo
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "制定本周训练计划"
      ..description = "安排有氧和力量训练"
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..tagsWithColor = _createTagsWithColors(["计划", "训练"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "准备运动装备"
      ..description = "检查运动鞋和运动服"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
      ..tagsWithColor = _createTagsWithColors(["装备", "准备"], _tagColors)
      ..priority = TodoPriority.lowLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
  ];

final Task fitnessTask2 = Task()
  ..uuid = const Uuid().v4()
  ..title = "inProgress"
  ..description = "进行中的训练"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
  ..tagsWithColor = _createTagsWithColors(["训练", "进行中"], _tagColors)
  ..status = TaskStatus.inProgress
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "力量训练"
      ..description = "练习胸肌和背肌"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
      ..tagsWithColor = _createTagsWithColors(["力量", "训练"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.inProgress
      ..progress = 80
      ..dueDate = DateTime.now().add(const Duration(days: 0)).millisecondsSinceEpoch,
  ];

final Task fitnessTask3 = Task()
  ..uuid = const Uuid().v4()
  ..title = "done"
  ..description = "完成的训练"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
  ..tagsWithColor = _createTagsWithColors(["完成", "记录"], _tagColors)
  ..status = TaskStatus.done
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "晨跑5公里"
      ..description = "完成有氧训练"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
      ..tagsWithColor = _createTagsWithColors(["跑步", "有氧"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.done
      ..finishedAt = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
  ];

final Task fitnessTask4 = Task()
  ..uuid = const Uuid().v4()
  ..title = "another"
  ..description = "其他健身项目"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
  ..tagsWithColor = _createTagsWithColors(["健身", "其他"], _tagColors)
  ..status = TaskStatus.todo
  ..todos = [];

// 旅行计划任务模板
final Task travelTask1 = Task()
  ..uuid = const Uuid().v4()
  ..title = "todo"
  ..description = "规划旅行行程"
  ..createdAt = DateTime.now().millisecondsSinceEpoch
  ..tagsWithColor = _createTagsWithColors(["旅行", "计划"], _tagColors)
  ..status = TaskStatus.todo
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "预订酒店"
      ..description = "选择合适位置和价格的酒店"
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..tagsWithColor = _createTagsWithColors(["酒店", "预订"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "购买机票"
      ..description = "比较价格并订购"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
      ..tagsWithColor = _createTagsWithColors(["机票", "交通"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.todo
      ..dueDate = DateTime.now().add(const Duration(days: 10)).millisecondsSinceEpoch,
  ];

final Task travelTask2 = Task()
  ..uuid = const Uuid().v4()
  ..title = "inProgress"
  ..description = "旅行前的准备"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
  ..tagsWithColor = _createTagsWithColors(["准备", "进行中"], _tagColors)
  ..status = TaskStatus.inProgress
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "准备行李"
      ..description = "整理衣物和必需品"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
      ..tagsWithColor = _createTagsWithColors(["行李", "准备"], _tagColors)
      ..priority = TodoPriority.mediumLevel
      ..status = TodoStatus.inProgress
      ..progress = 50
      ..dueDate = DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch,
  ];

final Task travelTask3 = Task()
  ..uuid = const Uuid().v4()
  ..title = "done"
  ..description = "完成的事项"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
  ..tagsWithColor = _createTagsWithColors(["完成", "旅行"], _tagColors)
  ..status = TaskStatus.done
  ..todos = [
    Todo()
      ..uuid = const Uuid().v4()
      ..title = "办理签证"
      ..description = "提交材料并等待审批"
      ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
      ..tagsWithColor = _createTagsWithColors(["签证", "手续"], _tagColors)
      ..priority = TodoPriority.highLevel
      ..status = TodoStatus.done
      ..finishedAt = DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch,
  ];

final Task travelTask4 = Task()
  ..uuid = const Uuid().v4()
  ..title = "another"
  ..description = "其他旅行事项"
  ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
  ..tagsWithColor = _createTagsWithColors(["旅行", "其他"], _tagColors)
  ..status = TaskStatus.todo
  ..todos = [];

// 空模板（标准模板）
final emptyTemplateTasks = [emptyTask1, emptyTask2, emptyTask3, emptyTask4];

// 有具体内容的模板（学生日程模板）
final contentTemplateTasks = [englishLearningTask, programmingTask, musicTask, dailyLifeTask];

// 工作管理模板
final workTemplateTasks = [workTask1, workTask2, workTask3, workTask4];

// 健身训练模板
final fitnessTemplateTasks = [fitnessTask1, fitnessTask2, fitnessTask3, fitnessTask4];

// 旅行计划模板
final travelTemplateTasks = [travelTask1, travelTask2, travelTask3, travelTask4];

// 默认使用内容模板
final defaultTasks = contentTemplateTasks;

final defaultAppConfig = AppConfig.create(
  configName: "defaultConfig",
  isDarkMode: true,
  locale: const Locale("zh", "CN"),
  emailReminderEnabled: false,
  isDebugMode: false,
  backgroundImagePath: 'default_template:background_1',
  backgroundImageOpacity: 1.0,
  backgroundImageBlur: 0.0,
  backgroundAffectsNavBar: true,
  showTodoImage: true, // 默认开启显示待办图片封面
);
