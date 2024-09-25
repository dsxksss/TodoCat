import 'dart:math'; // 导入 Dart 数学库，用于生成随机数。
import 'package:flutter_animate/flutter_animate.dart'; // 导入 Flutter 动画包。
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart'; // 导入 Flutter 智能对话框包。
import 'package:get/get.dart'; // 导入 GetX 包，用于状态管理。
import 'package:flutter/material.dart'; // 导入 Flutter 材料设计包。
import 'package:todo_cat/config/default_data.dart'; // 导入默认数据配置。
import 'package:todo_cat/data/schemas/local_notice.dart'; // 导入本地通知模式。
import 'package:todo_cat/data/schemas/task.dart'; // 导入任务模式。
import 'package:todo_cat/data/schemas/todo.dart'; // 导入待办事项模式。
import 'package:todo_cat/data/services/repositorys/task.dart'; // 导入任务仓库。
import 'package:todo_cat/data/test/todo.dart'; // 导入测试待办事项数据。
import 'package:todo_cat/pages/app_ctr.dart'; // 导入应用控制器。
import 'package:todo_cat/utils/date_time.dart'; // 导入日期时间工具。
import 'package:todo_cat/utils/dialog_keys.dart'; // 导入对话框键。
import 'package:todo_cat/widgets/show_toast.dart'; // 导入显示提示的组件。

// HomeController 类用于管理主页状态。
class HomeController extends GetxController {
  late TaskRepository taskRepository; // 任务仓库实例。

  final tasks = RxList<Task>(); // 可观察的任务列表。
  final currentTask = Rx<Task?>(null); // 可观察的当前任务。
  final listAnimatInterval = 200.ms.obs; // 可观察的动画间隔。
  final ScrollController scrollController = ScrollController(); // 滚动控制器。
  double currentScrollOffset = 0.0; // 当前滚动偏移量。
  final AppController appCtrl = Get.find(); // 应用控制器实例。

  // 初始化方法。
  @override
  void onInit() async {
    super.onInit();
    taskRepository = await TaskRepository.getInstance(); // 获取任务仓库实例。
    final localTasks = await taskRepository.readAll(); // 从仓库中读取所有任务。

    if (localTasks.isEmpty) {
      await _showEmptyTaskToast(); // 如果没有任务，显示提示。
    } else {
      tasks.assignAll(localTasks); // 将任务分配给可观察列表。
    }

    if (appCtrl.appConfig.value.isDebugMode) {
      _addDebugTasks(); // 如果是调试模式，添加调试任务。
    }

    scrollController.addListener(_scrollListener); // 添加滚动监听器。
    sort(reverse: true); // 逆序排序任务。

    // 每当任务列表变化时，更新仓库中的任务。
    ever(tasks, (_) => taskRepository.updateMany(tasks, (task) => task.id));
  }

  // 显示空任务提示。
  Future<void> _showEmptyTaskToast() async {
    await Future.delayed(2000.ms);
    showToast(
      "当前任务为空, 是否需要添加任务示例模板?", // 显示的信息。
      alwaysShow: true,
      confirmMode: true,
      onYesCallback: () => tasks.assignAll(defaultTasks), // 确认后添加默认任务。
    );
  }

  // 添加调试任务。
  void _addDebugTasks() {
    for (var task in defaultTasks) {
      selectTask(task); // 选择任务。
      for (var i = 0; i < Random().nextInt(5); i++) {
        int rnum = Random().nextInt(3);
        if (!task.todos.contains(todoTestList[rnum])) {
          addTodo(todoTestList[rnum]); // 添加随机待办事项。
        }
      }
      deselectTask(); // 取消选择任务。
    }
  }

  // 滚动监听器方法。
  void _scrollListener() {
    if (_isScrolledToTop() || _isScrolledToBottom()) {
      return;
    }

    if (scrollController.offset != currentScrollOffset &&
        !scrollController.position.outOfRange) {
      SmartDialog.dismiss(tag: dropDownMenuBtnTag); // 滚动时关闭对话框。
    }

    currentScrollOffset = scrollController.offset; // 更新当前滚动偏移量。
  }

  // 检查是否滚动到顶部。
  bool _isScrolledToTop() {
    return scrollController.offset <=
            scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange;
  }

  // 检查是否滚动到底部。
  bool _isScrolledToBottom() {
    return scrollController.offset >=
            scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange;
  }

  // 滚动到底部。
  Future<void> scrollMaxDown() async {
    await Future.delayed(100.ms, () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: 1000.ms,
        curve: Curves.easeOutCubic,
      );
    });
  }

  // 滚动到顶部。
  Future<void> scrollMaxTop() async {
    await Future.delayed(100.ms, () {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: 1000.ms,
        curve: Curves.easeOutCubic,
      );
    });
  }

  // 清理方法。
  @override
  void onClose() {
    scrollController.removeListener(_scrollListener); // 移除滚动监听器。
    scrollController.dispose(); // 释放滚动控制器。
    super.onClose();
  }

  // 添加任务。
  bool addTask(Task task) {
    if (taskRepository.has(task.id)) {
      return false; // 如果任务已存在，返回 false。
    }

    tasks.add(task); // 将任务添加到列表中。
    return true;
  }

  // 删除任务。
  bool deleteTask(String taskId) {
    if (taskRepository.hasNot(taskId)) {
      return false; // 如果任务不存在，返回 false。
    }

    Task task = tasks.singleWhere((task) => task.id == taskId); // 根据 ID 查找任务。
    for (var todo in task.todos) {
      appCtrl.localNotificationManager.destroy(
        timerKey: todo.id,
        sendDeleteReq: true,
      ); // 销毁待办事项的本地通知。
    }

    tasks.remove(task); // 从列表中移除任务。
    taskRepository.delete(taskId); // 从仓库中删除任务。
    return true;
  }

  // 更新任务。
  bool updateTask(String taskId, Task task) {
    if (!taskRepository.has(taskId)) {
      return false; // 如果任务不存在，返回 false。
    }

    taskRepository.update(taskId, task); // 更新仓库中的任务。
    return true;
  }

  // 选择任务。
  void selectTask(Task? task) {
    currentTask.value = task;
  }

  // 取消选择当前任务。
  void deselectTask() {
    currentTask.value = null;
  }

  // 向当前任务添加待办事项。
  bool addTodo(Todo todo) {
    if (currentTask.value == null ||
        taskRepository.hasNot(currentTask.value!.id)) {
      return false; // 如果没有当前任务或任务不存在，返回 false。
    }

    int taskIndex = tasks.indexOf(currentTask.value);
    if (taskIndex == -1) {
      return false; // 如果任务索引不存在，返回 false。
    }

    tasks[taskIndex].todos.add(todo); // 向任务添加待办事项。
    _handleTodoReminder(todo); // 处理待办事项提醒。

    // 按优先级排序待办事项。
    tasks[taskIndex]
        .todos
        .sort((a, b) => b.priority.index.compareTo(a.priority.index));
    tasks.refresh(); // 刷新任务列表。
    return true;
  }

  // 处理待办事项提醒。
  void _handleTodoReminder(Todo todo) {
    if (todo.reminders != 0) {
      final LocalNotice notice = LocalNotice(
        id: todo.id,
        title: "${"todoCat".tr} ${"taskReminder".tr}",
        description:
            "${todo.title} ${"createTime".tr}:${timestampToDate(todo.createdAt)} ${getTimeString(DateTime.fromMillisecondsSinceEpoch(todo.createdAt))}",
        createdAt: todo.createdAt,
        remindersAt: todo.reminders,
        email: "2546650292@qq.com",
      );
      appCtrl.localNotificationManager.saveNotification(
        key: notice.id,
        notice: notice,
        emailReminderEnabled: appCtrl.appConfig.value.emailReminderEnabled,
      ); // 保存本地通知。
    }
  }

  // 从任务中删除待办事项。
  bool deleteTodo(String taskId, String todoId) {
    if (taskRepository.hasNot(taskId)) {
      return false; // 如果任务不存在，返回 false。
    }

    Task task = tasks.singleWhere((task) => task.id == taskId); // 根据 ID 查找任务。
    int taskIndex = tasks.indexOf(task);
    if (taskIndex == -1) {
      return false; // 如果任务索引不存在，返回 false。
    }

    Todo todo =
        task.todos.singleWhere((todo) => todo.id == todoId); // 根据 ID 查找待办事项。
    appCtrl.localNotificationManager.destroy(
      timerKey: todoId,
      sendDeleteReq: true,
    ); // 销毁待办事项的本地通知。
    task.todos.remove(todo); // 从任务中移除待办事项。
    tasks.refresh(); // 刷新任务列表。
    return true;
  }

  // 按创建日期排序任务。
  void sort({bool reverse = false}) {
    tasks.sort((a, b) => reverse
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    tasks.refresh(); // 刷新任务列表。
  }
}

// 添加待办事项对话框的控制器。
class AddTodoDialogController extends GetxController {
  final formKey = GlobalKey<FormState>(); // 用于验证的表单键。
  final selectedTags = RxList<String>(); // 可观察的选中标签列表。
  final selectedPriority =
      Rx<TodoPriority>(TodoPriority.lowLevel); // 可观察的选中优先级。
  final titleFormCtrl = TextEditingController(); // 标题输入控制器。
  final descriptionFormCtrl = TextEditingController(); // 描述输入控制器。
  final tagController = TextEditingController(); // 标签输入控制器。
  final remindersText = RxString("${"enter".tr}${"time".tr}"); // 可观察的提醒文本。
  final remindersValue = RxInt(0); // 可观察的提醒值。

  // 向选中标签列表添加标签。
  void addTag() {
    if (tagController.text.isNotEmpty) {
      if (selectedTags.length < 3) {
        selectedTags.add(tagController.text); // 如果标签少于 3 个，添加标签。
        tagController.clear(); // 清空标签输入。
      } else {
        showToast(
          "tagsUpperLimit".tr,
          toastStyleType: TodoCatToastStyleType.warning,
        ); // 如果标签达到上限，显示警告。
      }
    }
  }

  // 检查所有表单数据是否为空。
  bool isDataEmpty() {
    return selectedTags.isEmpty &&
        titleFormCtrl.text.isEmpty &&
        descriptionFormCtrl.text.isEmpty &&
        tagController.text.isEmpty &&
        remindersValue.value == 0;
  }

  // 检查是否有任何表单数据不为空。
  bool isDataNotEmpty() => !isDataEmpty();

  // 从选中标签列表中移除标签。
  void removeTag(int index) {
    selectedTags.removeAt(index);
  }

  // 清空所有表单数据。
  void clearForm() {
    titleFormCtrl.clear();
    descriptionFormCtrl.clear();
    tagController.clear();
    selectedTags.clear();
    selectedPriority.value = TodoPriority.lowLevel;
    remindersText.value = "";
    remindersValue.value = 0;
  }
}

// 日期选择器的控制器。
class DatePickerController extends GetxController {
  late final currentDate = DateTime.now().obs; // 可观察的当前日期。
  late final defaultDate = DateTime.now().obs; // 可观察的默认日期。
  late final RxList<int> monthDays = <int>[].obs; // 可观察的当前月份的天数列表。
  final selectedDay = 0.obs; // 可观察的选中日期。
  final firstDayOfWeek = 0.obs; // 可观察的星期的第一天。
  final daysInMonth = 0.obs; // 可观察的当前月份的天数。
  final startPadding = RxNum(0); // 可观察的月份第一天的填充。
  final totalDays = RxNum(0); // 可观察的总天数。
  final TextEditingController hEditingController =
      TextEditingController(); // 小时输入控制器。
  final TextEditingController mEditingController =
      TextEditingController(); // 分钟输入控制器。

  // 初始化方法。
  @override
  void onInit() async {
    super.onInit();
    _initializeDateData(); // 初始化日期数据。
    await _initializeTimeData(); // 初始化时间数据。

    // 每当当前日期变化时更新选中日期。
    ever(selectedDay, (callback) => changeDate(day: selectedDay.value));
    // 将选中日期更新为当前日期的天数。
    ever(currentDate, (callback) => selectedDay.value = currentDate.value.day);
  }

  // 初始化日期数据。
  void _initializeDateData() {
    monthDays.value = getMonthDays(
        currentDate.value.year, currentDate.value.month); // 获取当前月份的天数。
    firstDayOfWeek.value = firstDayWeek(currentDate.value); // 获取星期的第一天。
    daysInMonth.value = monthDays.length; // 获取月份的天数。
    startPadding.value = (firstDayOfWeek - 1) % 7; // 计算开始填充。
    totalDays.value = daysInMonth.value + startPadding.value; // 计算总天数。
    selectedDay.value = defaultDate.value.day; // 将选中日期设置为默认日期的天数。
  }

  // 初始化时间数据。
  Future<void> _initializeTimeData() async {
    await Future.delayed(200.ms, () {
      hEditingController.text =
          defaultDate.value.hour.toString(); // 将小时输入设置为默认日期的小时。
      mEditingController.text =
          defaultDate.value.minute.toString(); // 将分钟输入设置为默认日期的分钟。
    });
  }

  // 重置日期为默认日期。
  void resetDate() {
    changeDate(
      year: defaultDate.value.year,
      month: defaultDate.value.month,
      day: defaultDate.value.day,
      hour: 0,
      minute: 0,
    );
    hEditingController.text = '0'; // 重置小时输入。
    mEditingController.text = '0'; // 重置分钟输入。
  }

  // 更改当前日期。
  void changeDate({int? year, int? month, int? day, int? hour, int? minute}) {
    currentDate.value = DateTime(
      year ?? currentDate.value.year,
      month ?? currentDate.value.month,
      day ?? currentDate.value.day,
      hour ?? currentDate.value.hour,
      minute ?? currentDate.value.minute,
    );
    _initializeDateData(); // 重新初始化日期数据。
  }
}
