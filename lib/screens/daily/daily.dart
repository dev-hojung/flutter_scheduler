import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/task_controller.dart';

class DailyPage extends StatelessWidget {
  final String title;
  final Color color;
  final bool isToday;

  DailyPage({
    super.key,
    required this.title,
    required this.color,
    required this.isToday,
  });

  final TaskController taskController = Get.find<TaskController>();

  List<Map<String, dynamic>> getTask() {
    return isToday ? taskController.todayTasks : taskController.tomorrowTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 달성률 표시
          Obx(() {
            final allTasks = getTask();
            final completedTasks =
                allTasks.where((task) => task["completed"]).length;
            final totalTasks = allTasks.length;
            final achievementRate = totalTasks > 0
                ? (completedTasks / totalTasks * 100).round()
                : 0;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? "오늘의 달성률" : "내일의 달성률",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$completedTasks / $totalTasks 완료",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: achievementRate == 100 ? Colors.green : color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$achievementRate%",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              final tasks =
                  getTask().where((task) => task["completed"]).toList();
              return _buildTaskList(
                title: "완료한 일",
                tasks: tasks,
                color: Colors.green,
              );
            }),
          ),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: Obx(() {
              final tasks =
                  getTask().where((task) => !task["completed"]).toList();
              return _buildTaskList(
                title: "해야 할 일",
                tasks: tasks,
                color: color,
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: color,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList({
    required String title,
    required List<Map<String, dynamic>> tasks,
    required Color color,
  }) {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text(
                        '항목이 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskItem(task, color);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Dismissible(
        key: ValueKey(task),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        onDismissed: (direction) {
          final section = isToday ? "today" : "tomorrow";
          final taskList = getTask();
          final taskIndex = taskList.indexOf(task);
          taskController.deleteTask(section, taskIndex);
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text('"${task["title"]}"가 삭제되었습니다.'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        },
        child: ListTile(
          dense: true,
          leading: Checkbox(
            value: task["completed"],
            onChanged: (bool? value) {
              final section = isToday ? "today" : "tomorrow";
              taskController.updateTaskCompletion(
                section,
                getTask().indexOf(task),
                value ?? false,
              );
            },
            activeColor: color,
          ),
          title: Text(
            "${task["title"]} ${task["time"] != null ? '(${task["time"]})' : ''}",
            style: TextStyle(
              fontSize: 16,
              color: task["completed"] ? Colors.grey : Colors.black87,
              decoration: task["completed"] ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskTextController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("새 할 일 추가"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskTextController,
                    decoration: const InputDecoration(
                      hintText: "할 일을 입력하세요",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedTime != null
                              ? "선택된 시간: ${selectedTime?.format(context)}"
                              : "시간을 선택하세요",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            initialEntryMode: TimePickerEntryMode.input,
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("취소"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (taskTextController.text.isEmpty ||
                        selectedTime == null) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            taskTextController.text.isEmpty
                                ? "할 일을 입력하세요."
                                : "시간을 선택하세요.",
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final section = isToday ? "today" : "tomorrow";
                    taskController.addTask(section, {
                      "title": taskTextController.text,
                      "completed": false,
                      "time": selectedTime?.format(context),
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("추가"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
