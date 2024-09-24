import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:todo_cat/config/default_data.dart';
import 'package:todo_cat/data/schemas/local_notice.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/data/schemas/todo.dart';
import 'package:todo_cat/data/services/repositorys/task.dart';
import 'package:todo_cat/data/test/todo.dart';
import 'package:todo_cat/pages/controller.dart';
import 'package:todo_cat/utils/date_time.dart';
import 'package:todo_cat/utils/dialog_keys.dart';
import 'package:todo_cat/widgets/show_toast.dart';

class HomeController extends GetxController {
  late TaskRepository taskRepository;

  final tasks = RxList<Task>();
  final currentTask = Rx<Task?>(null);
  final listAnimatInterval = 200.ms.obs;
  final ScrollController scrollController = ScrollController();
  double currentScrollOffset = 0.0;
  final AppController appCtrl = Get.find();

  @override
  void onInit() async {
    super.onInit();
    taskRepository = await TaskRepository.getInstance();
    final localTasks = await taskRepository.readAll();
    tasks.assignAll(localTasks);

    if (appCtrl.appConfig.value.isDebugMode) {
      for (var task in defaultTasks) {
        selectTask(task);
        for (var i = 0; i < Random().nextInt(5); i++) {
          int rnum = Random().nextInt(3);
          if (!task.todos.contains(todoTestList[rnum])) {
            addTodo(todoTestList[rnum]);
          }
        }
        deselectTask();
      }
    }

    // 监听页面滚动时
    scrollController.addListener(scrollListener);

    // 按创建序号排序渲染
    sort(reverse: true);

    // 后续数据发生改变则运行更新操作
    ever(tasks, (_) => taskRepository.updateMany(tasks));
  }

  void scrollListener() {
    // 当滚动到顶部时
    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {}

    // 当滚动到底部时
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {}

    // 当滚动时
    if (scrollController.offset != currentScrollOffset &&
        !scrollController.position.outOfRange) {
      SmartDialog.dismiss(tag: dropDownMenuBtnTag);
    }

    currentScrollOffset = scrollController.offset;
  }

  void scrollMaxDown() async {
    await Future.delayed(100.ms, () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: 1000.ms,
        curve: Curves.easeOutCubic,
      );
    });
  }

  void scrollMaxTop() async {
    await Future.delayed(100.ms, () {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: 1000.ms,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void onClose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  bool addTask(Task task) {
    if (taskRepository.has(task.id)) {
      return false;
    }

    tasks.add(task);
    return true;
  }

  bool deleteTask(String taskId) {
    if (taskRepository.hasNot(taskId)) {
      return false;
    }
    Task task = tasks.singleWhere((task) => task.id == taskId);
    for (var todo in task.todos) {
      appCtrl.localNotificationManager.destroy(
        timerKey: todo.id,
        sendDeleteReq: true,
      );
    }

    tasks.remove(task);
    taskRepository.delete(taskId);
    return true;
  }

  bool updateTask(String taskId, Task task) {
    if (!taskRepository.hasNot(taskId)) {
      return false;
    }

    taskRepository.update(taskId, task);
    return true;
  }

  void selectTask(Task? task) {
    currentTask.value = task;
  }

  void deselectTask() {
    currentTask.value = null;
  }

  bool addTodo(Todo todo) {
    if (currentTask.value == null) {
      return false;
    }

    if (taskRepository.hasNot(currentTask.value!.id)) {
      return false;
    }

    int taskIndex = tasks.indexOf(currentTask.value);
    if (taskIndex == -1) {
      return false;
    }

    tasks[taskIndex].todos.add(todo);

    if (todo.reminders != 0) {
      final LocalNotice notice = LocalNotice(
        id: todo.id,
        title: "${"todoCat".tr} ${"taskReminder".tr}",
        description:
            "${todo.title} ${"createTime".tr}:${timestampToDate(todo.createdAt)} ${getTimeString(
          DateTime.fromMillisecondsSinceEpoch(
            todo.createdAt,
          ),
        )}",
        createdAt: todo.createdAt,
        remindersAt: todo.reminders,
        email: "2546650292@qq.com",
      );
      appCtrl.localNotificationManager.saveNotification(
        key: notice.id,
        notice: notice,
        emailReminderEnabled: appCtrl.appConfig.value.emailReminderEnabled,
      );
    }

    // 按照完成优先级排序
    tasks[taskIndex]
        .todos
        .sort((a, b) => b.priority.index.compareTo(a.priority.index));

    tasks.refresh();
    return true;
  }

  bool deleteTodo(String taskId, String todoId) {
    if (taskRepository.hasNot(taskId)) {
      return false;
    }

    Task task = tasks.singleWhere((task) => task.id == taskId);
    int taskIndex = tasks.indexOf(task);
    if (taskIndex == -1) {
      return false;
    }

    Todo todo = task.todos.singleWhere((todo) => todo.id == todoId);
    appCtrl.localNotificationManager.destroy(
      timerKey: todoId,
      sendDeleteReq: true,
    );
    task.todos.remove(todo);
    tasks.refresh();
    return true;
  }

  void sort({bool reverse = false}) {
    tasks.sort(reverse
        ? (a, b) => a.createdAt.compareTo(b.createdAt)
        : (a, b) => b.createdAt.compareTo(a.createdAt));
    tasks.refresh();
  }
}

class AddTodoDialogController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final selectedTags = RxList<String>();
  final selectedPriority = Rx<TodoPriority>(TodoPriority.lowLevel);
  final titleFormCtrl = TextEditingController();
  final descriptionFormCtrl = TextEditingController();
  final tagController = TextEditingController();
  final remindersText = RxString("${"enter".tr}${"time".tr}");
  final remindersValue = RxInt(0);

  void addTag() {
    if (tagController.text.isNotEmpty) {
      if (selectedTags.length < 3) {
        selectedTags.add(tagController.text);
        tagController.clear();
      } else {
        showToast(
          "tagsUpperLimit".tr,
          toastStyleType: TodoCatToastStyleType.warning,
        );
      }
    }
  }

  bool isDataEmpty() {
    return selectedTags.isEmpty &&
        titleFormCtrl.text.isEmpty &&
        descriptionFormCtrl.text.isEmpty &&
        tagController.text.isEmpty &&
        remindersValue.value == 0;
  }

  bool isDataNotEmpty() {
    return !isDataEmpty();
  }

  void removeTag(int index) {
    selectedTags.removeAt(index);
  }

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

class DatePickerController extends GetxController {
  late final currentDate = DateTime.now().obs;
  late final defaultDate = DateTime.now().obs;
  late final RxList<int> monthDays = <int>[].obs;
  final selectedDay = 0.obs;
  final firstDayOfWeek = 0.obs;
  final daysInMonth = 0.obs;
  final startPadding = RxNum(0);
  final totalDays = RxNum(0);
  final TextEditingController hEditingController = TextEditingController();
  final TextEditingController mEditingController = TextEditingController();

  @override
  void onInit() async {
    monthDays.value = getMonthDays(
      currentDate.value.year,
      currentDate.value.month,
    );

    firstDayOfWeek.value = firstDayWeek(currentDate.value);
    daysInMonth.value = monthDays.length;
    startPadding.value = (firstDayOfWeek - 1) % 7;
    totalDays.value = daysInMonth.value + startPadding.value;

    selectedDay.value = defaultDate.value.day;

    await Future.delayed(200.ms, () {
      hEditingController.text = defaultDate.value.hour.toString();
      mEditingController.text = defaultDate.value.minute.toString();
    });

    ever(selectedDay, (callback) => changeDate(day: selectedDay.value));
    ever(currentDate, (callback) => selectedDay.value = currentDate.value.day);

    super.onInit();
  }

  void resetDate() {
    changeDate(
      year: defaultDate.value.year,
      month: defaultDate.value.month,
      day: defaultDate.value.day,
      hour: 0,
      minute: 0,
    );
    hEditingController.text = 0.toString();
    mEditingController.text = 0.toString();
  }

  void changeDate({int? year, int? month, int? day, int? hour, int? minute}) {
    currentDate.value = DateTime(
      year ?? currentDate.value.year,
      month ?? currentDate.value.month,
      day ?? currentDate.value.day,
      hour ?? currentDate.value.hour,
      minute ?? currentDate.value.minute,
    );
    monthDays.value = getMonthDays(
      currentDate.value.year,
      currentDate.value.month,
    );

    firstDayOfWeek.value = firstDayWeek(currentDate.value);
    daysInMonth.value = monthDays.length;
    startPadding.value = (firstDayOfWeek - 1) % 7;
    totalDays.value = daysInMonth.value + startPadding.value;
  }
}
