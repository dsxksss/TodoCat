import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/controllers/home_ctr.dart';
import 'package:todo_cat/keys/dialog_keys.dart';
import 'package:todo_cat/widgets/dpd_menu_btn.dart';
import 'package:todo_cat/pages/home/components/todo/add_todo_card_btn.dart';
import 'package:todo_cat/pages/home/components/todo/todo_card.dart';
import 'package:todo_cat/widgets/show_toast.dart';
import 'package:todo_cat/controllers/task_dialog_ctr.dart';
import 'package:todo_cat/widgets/task_dialog.dart';
import 'package:todo_cat/services/dialog_service.dart';

class TaskCard extends StatefulWidget {
  TaskCard({
    super.key, 
    required Task task,
    ScrollController? parentScrollController, // 保留但不使用，避免破坏调用
  }) : _task = task;
  final Task _task;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final HomeController _homeCtrl = Get.find();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<dynamic> _getColorAndIcon() {
    switch (widget._task.title) {
      case 'todo':
        return [Colors.grey, FontAwesomeIcons.clipboard];
      case 'inProgress':
        return [Colors.orangeAccent, FontAwesomeIcons.pencil];
      case 'done':
        return [
          const Color.fromRGBO(46, 204, 147, 1),
          FontAwesomeIcons.circleCheck
        ];
      default:
        return [Colors.lightBlue, FontAwesomeIcons.listOl];
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosLength = widget._task.todos?.length ?? 0;
    final colorAndIcon = _getColorAndIcon();

    return Container(
      width: context.isPhone ? 0.9.sw : 260,
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.4, color: context.theme.dividerColor),
        boxShadow: context.isDarkMode
            ? <BoxShadow>[
                BoxShadow(
                  color: context.theme.dividerColor,
                  blurRadius: 0.2,
                ),
              ]
            : null, // 亮色主题下不使用阴影
      ),
                  child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (details) {
          return details.data['fromTaskId'] != widget._task.uuid;
        },
        onAcceptWithDetails: (details) {
          try {
            final data = details.data;
            _homeCtrl.moveTodoToTask(
              data['fromTaskId']!,
              widget._task.uuid,
              data['todoId']!,
            );
          } catch (e) {
            print('DragTarget accept error: $e');
            // 发生错误时结束拖动状态
            _homeCtrl.endDragging();
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isTargeted = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isTargeted
                  ? context.theme.highlightColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                          ),
                          Container(
                            width: 5,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colorAndIcon[0],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Icon(
                            colorAndIcon[1],
                            size: colorAndIcon[1] == FontAwesomeIcons.pencil
                                ? 18
                                : 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Tooltip(
                              message: widget._task.title.tr,
                              preferBelow: false,
                              child: Text(
                                widget._task.title.tr,
                                style: GoogleFonts.getFont(
                                  'Ubuntu',
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (todosLength > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  width: 24,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color.fromRGBO(225, 224, 240, 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      todosLength.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(17, 10, 76, 1),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: DPDMenuBtn(
                        tag: dropDownMenuBtnTag,
                        menuItems: [
                          MenuItem(
                            title: 'edit',
                            iconData: FontAwesomeIcons.penToSquare,
                            callback: () async {
                              final taskDialogController =
                                  Get.put(TaskDialogController());
                              taskDialogController.initForEditing(widget._task);

                              DialogService.showFormDialog(
                                tag: addTaskDialogTag,
                                dialog: const TaskDialog(),
                              );
                            },
                          ),
                          MenuItem(
                            title: 'delete',
                            iconData: FontAwesomeIcons.trashCan,
                            callback: () => {
                              showToast(
                                "sureDeleteTask".tr,
                                alwaysShow: true,
                                confirmMode: true,
                                toastStyleType: TodoCatToastStyleType.error,
                                onYesCallback: () async {
                                  final bool isDeleted =
                                      await _homeCtrl.deleteTask(widget._task.uuid);
                                  0.5.delay(() {
                                    if (isDeleted) {
                                      showSuccessNotification(
                                        "${"task".tr} '${widget._task.title.tr}' ${"deletedSuccessfully".tr}",
                                      );
                                    } else {
                                      showErrorNotification(
                                        "${"task".tr} '${widget._task.title.tr}' ${"deletionFailed".tr}",
                                      );
                                    }
                                  });
                                },
                              )
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                AddTodoCardBtn(
                  task: widget._task,
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: Listener(
                    // 拦截滚动事件，在 todos 区域内纵向滚动，不影响外层横向滚动
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        final scrollDelta = pointerSignal.scrollDelta.dy;
                        if (_scrollController.hasClients && scrollDelta != 0) {
                          // 手动处理纵向滚动
                          final newOffset = _scrollController.offset + scrollDelta;
                          _scrollController.animateTo(
                            newOffset.clamp(
                              0.0,
                              _scrollController.position.maxScrollExtent,
                            ),
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                        }
                        // 不传递事件到父组件，阻止外层横向滚动
                      }
                    },
                    child: Obx(
                      () {
                        // 安全地获取最新的任务状态
                        final currentTask = _homeCtrl.allTasks.firstWhere(
                          (task) => task.uuid == widget._task.uuid,
                          orElse: () => widget._task,
                        );
                        final todos = currentTask.todos ?? [];
                        // 使用官方 ReorderableListView
                        return ReorderableListView(
                          shrinkWrap: true,
                          buildDefaultDragHandles: false, // 移除默认拖拽手柄
                          scrollController: _scrollController,
                          onReorder: (oldIndex, newIndex) {
                            try {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              _homeCtrl.reorderTodo(widget._task.uuid, oldIndex, newIndex);
                            } catch (e) {
                              print('Reorder error: $e');
                            }
                          },
                          onReorderStart: (index) {
                            try {
                              _homeCtrl.startDragging();
                            } catch (e) {
                              print('ReorderStarted error: $e');
                            }
                          },
                          onReorderEnd: (index) {
                            try {
                              _homeCtrl.endDragging();
                            } catch (e) {
                              print('ReorderEnd error: $e');
                            }
                          },
                          proxyDecorator: (child, index, animation) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                return Material(
                                  elevation: 0, // 移除阴影
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Opacity(
                                    opacity: 0.8, // 轻微半透明
                                    child: child,
                                  ),
                                );
                              },
                              child: child,
                            );
                          },
                          children: todos.asMap().entries.map<Widget>((entry) {
                            final index = entry.key;
                            final todo = entry.value;
                            // 使用 ReorderableDelayedDragStartListener 支持直接拖动
                            return ReorderableDelayedDragStartListener(
                              key: ValueKey(todo.uuid),
                              index: index,
                              child: TodoCard(
                                taskId: widget._task.uuid,
                                todo: todo,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
