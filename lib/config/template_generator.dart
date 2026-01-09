import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/schemas/tag_with_color.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

/// 模板生成器 - 根据当前语言生成相应的任务模板
class TemplateGenerator {
  // 预定义的颜色列表
  static final List<Color> _tagColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  // 辅助函数：创建带颜色的标签
  static List<TagWithColor> _createTagsWithColors(List<String> tagNames) {
    return tagNames.map((tagName) {
      final colorIndex = tagName.hashCode.abs() % _tagColors.length;
      final color = _tagColors[colorIndex];
      return TagWithColor(name: tagName, color: color);
    }).toList();
  }

  /// 获取标准空模板（4个空任务）
  static List<Task> getEmptyTemplate() {
    return [
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'todo'.tr
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tagsWithColor = _createTagsWithColors(['default'.tr])
        ..status = TaskStatus.todo
        ..customColor = Colors.grey.value
        ..customIcon = FontAwesomeIcons.list.codePoint
        ..todos = [],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'inProgress'.tr
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
        ..tagsWithColor = _createTagsWithColors(['default'.tr])
        ..status = TaskStatus.inProgress
        ..customColor = Colors.orange.value
        ..customIcon = FontAwesomeIcons.listCheck.codePoint
        ..todos = [],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'done'.tr
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 2
        ..tagsWithColor = _createTagsWithColors(['default'.tr])
        ..status = TaskStatus.done
        ..customColor = const Color.fromRGBO(46, 204, 147, 1).value
        ..customIcon = FontAwesomeIcons.circleCheck.codePoint
        ..todos = [],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'another'.tr
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 3
        ..tagsWithColor = _createTagsWithColors(['default'.tr])
        ..status = TaskStatus.todo
        ..customColor = Colors.blue.value
        ..customIcon = FontAwesomeIcons.clipboard.codePoint
        ..todos = [],
    ];
  }

  /// 获取学生/学习模板
  static List<Task> getStudentTemplate() {
    final isZh = Get.locale?.languageCode == 'zh';

    return [
      // 学习任务
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'todo'.tr
        ..description = isZh ? '提升语言学习能力' : 'Improve language learning skills'
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tagsWithColor = _createTagsWithColors(
            isZh ? ['学习', '语言', '日常'] : ['Learning', 'Language', 'Daily'])
        ..status = TaskStatus.todo
        ..customIcon = FontAwesomeIcons.book.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '背诵50个新单词' : 'Memorize 50 new words'
            ..description = isZh ? '使用单词卡片或APP学习' : 'Use flashcards or app'
            ..createdAt = DateTime.now().millisecondsSinceEpoch
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['词汇', '背诵'] : ['Vocabulary', 'Memorize'])
            ..priority = TodoPriority.highLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 1))
                .millisecondsSinceEpoch,
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '听播客30分钟' : 'Listen to podcast 30min'
            ..description = isZh ? '选择感兴趣的内容' : 'Choose interesting content'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['听力', '播客'] : ['Listening', 'Podcast'])
            ..priority = TodoPriority.mediumLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 1))
                .millisecondsSinceEpoch,
        ],
      // 项目任务
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'inProgress'.tr
        ..description = isZh ? '完成个人项目' : 'Complete personal project'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['项目', '技术'] : ['Project', 'Tech'])
        ..status = TaskStatus.inProgress
        ..customIcon = FontAwesomeIcons.code.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '设计项目架构' : 'Design project architecture'
            ..description = isZh ? '绘制系统架构图' : 'Draw system architecture'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['设计', '架构'] : ['Design', 'Architecture'])
            ..priority = TodoPriority.highLevel
            ..status = TodoStatus.done
            ..finishedAt = DateTime.now()
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch,
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '编写单元测试' : 'Write unit tests'
            ..description =
                isZh ? '为核心功能编写测试用例' : 'Write tests for core features'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 11
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['测试', '质量'] : ['Testing', 'Quality'])
            ..priority = TodoPriority.mediumLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 4))
                .millisecondsSinceEpoch,
        ],
      // 兴趣爱好
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'done'.tr
        ..description = isZh ? '提升兴趣爱好技能' : 'Improve hobby skills'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['爱好', '艺术'] : ['Hobby', 'Art'])
        ..status = TaskStatus.done
        ..customIcon = FontAwesomeIcons.palette.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '练习新技能' : 'Practice new skill'
            ..description = isZh ? '学习新的技巧' : 'Learn new techniques'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
            ..tagsWithColor =
                _createTagsWithColors(isZh ? ['练习'] : ['Practice'])
            ..priority = TodoPriority.mediumLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 3))
                .millisecondsSinceEpoch,
        ],
      // 日常管理
      Task()
        ..uuid = const Uuid().v4()
        ..title = isZh ? '日常管理' : 'Daily Management'
        ..description = isZh ? '管理日常学习和生活事务' : 'Manage daily life and study'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['生活', '管理'] : ['Life', 'Management'])
        ..status = TaskStatus.todo
        ..customIcon = FontAwesomeIcons.house.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '整理学习笔记' : 'Organize study notes'
            ..description = isZh ? '整理本周的笔记和资料' : 'Organize this week\'s notes'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['整理', '笔记'] : ['Organize', 'Notes'])
            ..priority = TodoPriority.mediumLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 2))
                .millisecondsSinceEpoch,
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '运动锻炼' : 'Exercise'
            ..description = isZh ? '进行30分钟的有氧运动' : '30 minutes of cardio'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 31
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['运动', '健康'] : ['Exercise', 'Health'])
            ..priority = TodoPriority.mediumLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 1))
                .millisecondsSinceEpoch,
        ],
    ];
  }

  /// 获取工作管理模板
  static List<Task> getWorkTemplate() {
    final isZh = Get.locale?.languageCode == 'zh';

    return [
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'todo'.tr
        ..description = isZh ? '管理工作项目和任务' : 'Manage work projects and tasks'
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tagsWithColor = _createTagsWithColors(
            isZh ? ['工作', '项目管理'] : ['Work', 'Project Management'])
        ..status = TaskStatus.todo
        ..customIcon = FontAwesomeIcons.briefcase.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '准备项目提案' : 'Prepare project proposal'
            ..description = isZh
                ? '收集需求并撰写项目建议书'
                : 'Collect requirements and write proposal'
            ..createdAt = DateTime.now().millisecondsSinceEpoch
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['提案', '文档'] : ['Proposal', 'Document'])
            ..priority = TodoPriority.highLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 3))
                .millisecondsSinceEpoch,
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '团队周会' : 'Team weekly meeting'
            ..description =
                isZh ? '讨论项目进度和下周计划' : 'Discuss progress and next week\'s plan'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['会议', '协作'] : ['Meeting', 'Collaboration'])
            ..priority = TodoPriority.mediumLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 5))
                .millisecondsSinceEpoch,
        ],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'inProgress'.tr
        ..description = isZh ? '进行中的开发工作' : 'Development in progress'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
        ..tagsWithColor = _createTagsWithColors(
            isZh ? ['开发', '进行中'] : ['Development', 'In Progress'])
        ..status = TaskStatus.inProgress
        ..customIcon = FontAwesomeIcons.code.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '完成功能开发' : 'Complete feature development'
            ..description = isZh ? '实现核心业务逻辑' : 'Implement core business logic'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['开发', '功能'] : ['Development', 'Feature'])
            ..priority = TodoPriority.highLevel
            ..status = TodoStatus.inProgress
            ..progress = 60
            ..dueDate = DateTime.now()
                .add(const Duration(days: 2))
                .millisecondsSinceEpoch,
        ],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'done'.tr
        ..description = isZh ? '已完成的工作' : 'Completed work'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['完成', '归档'] : ['Done', 'Archived'])
        ..status = TaskStatus.done
        ..customIcon = FontAwesomeIcons.boxArchive.codePoint
        ..todos = [],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'another'.tr
        ..description = isZh ? '其他工作事项' : 'Other work items'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['工作', '待办'] : ['Work', 'Todo'])
        ..status = TaskStatus.todo
        ..todos = [],
    ];
  }

  /// 获取健身训练模板
  static List<Task> getFitnessTemplate() {
    final isZh = Get.locale?.languageCode == 'zh';

    return [
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'todo'.tr
        ..description = isZh ? '制定健身计划' : 'Create fitness plan'
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['健身', '计划'] : ['Fitness', 'Plan'])
        ..status = TaskStatus.todo
        ..customIcon = FontAwesomeIcons.dumbbell.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '制定本周训练计划' : 'Weekly training plan'
            ..description =
                isZh ? '安排有氧和力量训练' : 'Schedule cardio and strength training'
            ..createdAt = DateTime.now().millisecondsSinceEpoch
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['计划', '训练'] : ['Plan', 'Training'])
            ..priority = TodoPriority.mediumLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 1))
                .millisecondsSinceEpoch,
        ],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'inProgress'.tr
        ..description = isZh ? '进行中的训练' : 'Training in progress'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
        ..tagsWithColor = _createTagsWithColors(
            isZh ? ['训练', '进行中'] : ['Training', 'In Progress'])
        ..status = TaskStatus.inProgress
        ..customIcon = FontAwesomeIcons.fire.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '力量训练' : 'Strength training'
            ..description = isZh ? '练习胸肌和背肌' : 'Chest and back exercises'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['力量', '训练'] : ['Strength', 'Training'])
            ..priority = TodoPriority.highLevel
            ..status = TodoStatus.inProgress
            ..progress = 80
            ..dueDate = DateTime.now()
                .add(const Duration(days: 0))
                .millisecondsSinceEpoch,
        ],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'done'.tr
        ..description = isZh ? '完成的训练' : 'Completed training'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['完成', '记录'] : ['Done', 'Record'])
        ..status = TaskStatus.done
        ..customIcon = FontAwesomeIcons.trophy.codePoint
        ..todos = [],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'another'.tr
        ..description = isZh ? '其他健身项目' : 'Other fitness items'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['健身', '其他'] : ['Fitness', 'Other'])
        ..status = TaskStatus.todo
        ..todos = [],
    ];
  }

  /// 获取旅行计划模板
  static List<Task> getTravelTemplate() {
    final isZh = Get.locale?.languageCode == 'zh';

    return [
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'todo'.tr
        ..description = isZh ? '规划旅行行程' : 'Plan travel itinerary'
        ..createdAt = DateTime.now().millisecondsSinceEpoch
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['旅行', '计划'] : ['Travel', 'Plan'])
        ..status = TaskStatus.todo
        ..customIcon = FontAwesomeIcons.mapLocationDot.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '预订酒店' : 'Book hotel'
            ..description =
                isZh ? '选择合适位置和价格的酒店' : 'Choose suitable location and price'
            ..createdAt = DateTime.now().millisecondsSinceEpoch
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['酒店', '预订'] : ['Hotel', 'Booking'])
            ..priority = TodoPriority.highLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 7))
                .millisecondsSinceEpoch,
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '购买机票' : 'Buy flight tickets'
            ..description = isZh ? '比较价格并订购' : 'Compare prices and purchase'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 1
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['机票', '交通'] : ['Flight', 'Transport'])
            ..priority = TodoPriority.highLevel
            ..status = TodoStatus.todo
            ..dueDate = DateTime.now()
                .add(const Duration(days: 10))
                .millisecondsSinceEpoch,
        ],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'inProgress'.tr
        ..description = isZh ? '旅行前的准备' : 'Travel preparation'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
        ..tagsWithColor = _createTagsWithColors(
            isZh ? ['准备', '进行中'] : ['Preparation', 'In Progress'])
        ..status = TaskStatus.inProgress
        ..customIcon = FontAwesomeIcons.suitcaseRolling.codePoint
        ..todos = [
          Todo()
            ..uuid = const Uuid().v4()
            ..title = isZh ? '准备行李' : 'Pack luggage'
            ..description =
                isZh ? '整理衣物和必需品' : 'Organize clothes and essentials'
            ..createdAt = DateTime.now().millisecondsSinceEpoch + 10
            ..tagsWithColor = _createTagsWithColors(
                isZh ? ['行李', '准备'] : ['Luggage', 'Preparation'])
            ..priority = TodoPriority.mediumLevel
            ..status = TodoStatus.inProgress
            ..progress = 50
            ..dueDate = DateTime.now()
                .add(const Duration(days: 3))
                .millisecondsSinceEpoch,
        ],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'done'.tr
        ..description = isZh ? '完成的事项' : 'Completed items'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 20
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['完成', '旅行'] : ['Done', 'Travel'])
        ..status = TaskStatus.done
        ..customIcon = FontAwesomeIcons.camera.codePoint
        ..todos = [],
      Task()
        ..uuid = const Uuid().v4()
        ..title = 'another'.tr
        ..description = isZh ? '其他旅行事项' : 'Other travel items'
        ..createdAt = DateTime.now().millisecondsSinceEpoch + 30
        ..tagsWithColor =
            _createTagsWithColors(isZh ? ['旅行', '其他'] : ['Travel', 'Other'])
        ..status = TaskStatus.todo
        ..todos = [],
    ];
  }
}
