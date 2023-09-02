import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:todo_cat/data/schemas/task.dart';
import 'package:todo_cat/pages/home/controller.dart';
import 'package:todo_cat/pages/home/widgets/add_todo_card_btn.dart';
import 'package:todo_cat/pages/home/widgets/todo_card.dart';
import 'package:todo_cat/widgets/animation_btn.dart';

class TaskCard extends StatelessWidget {
  TaskCard({super.key, required this.task});
  final HomeController ctrl = Get.find();
  final Task task;

  @override
  Widget build(BuildContext context) {
    final todosLength = task.todos.length;
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 245, 247, 1),
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Flex(
        direction: Axis.vertical,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (todosLength > 0)
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
                    )
                ],
              ),
              AnimationBtn(
                onClickScale: 0.8,
                onClickDuration: 100.ms,
                onHoverAnimationEnabled: false,
                padding: const EdgeInsets.only(right: 15),
                onPressed: () => {},
                child: const Center(
                  child: Icon(
                    Icons.more_horiz,
                    color: Color.fromRGBO(129, 127, 158, 1),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          AddTodoCardBtn(
            task: task,
          ),
          const SizedBox(
            height: 15,
          ),
          Obx(
            () => Column(
              children: [
                ...ctrl.tasks[ctrl.tasks.indexOf(task)].todos
                    .map((e) => TodoCard(todo: e))
              ].animate(interval: 100.ms).fadeIn(duration: 150.ms),
            ),
          ),
        ],
      ),
    );
  }
}
