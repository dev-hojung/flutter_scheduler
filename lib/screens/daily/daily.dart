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
          dense: false,
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
            task["title"],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: task["completed"] ? Colors.grey : Colors.black87,
              decoration: task["completed"] ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task["description"] != null &&
                  task["description"].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    task["description"],
                    style: TextStyle(
                      fontSize: 13,
                      color: task["completed"] ? Colors.grey : Colors.grey[600],
                      decoration:
                          task["completed"] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: task["completed"] ? Colors.grey : color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task["time"] ?? "하루종일",
                      style: TextStyle(
                        fontSize: 13,
                        color: task["completed"] ? Colors.grey : color,
                        fontWeight: FontWeight.w500,
                        decoration: task["completed"]
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskTextController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 헤더
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_task,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "새 할 일 추가",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 할 일 입력 필드
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: taskTextController,
                        decoration: InputDecoration(
                          labelText: "할 일 제목",
                          hintText: "무엇을 하실 계획인가요?",
                          prefixIcon: Icon(Icons.edit, color: color),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          labelStyle: TextStyle(color: color),
                        ),
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 상세 내용 입력 필드
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "상세 내용 (선택사항)",
                          hintText: "추가 정보나 메모를 입력하세요",
                          prefixIcon: Icon(Icons.description, color: color),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          labelStyle: TextStyle(color: color),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 시간 선택
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedTime != null
                            ? Colors.grey.shade50
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              selectedTime != null ? color : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color:
                                selectedTime != null ? color : Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedTime != null
                                  ? "선택된 시간: ${selectedTime?.format(context)}"
                                  : "하루 종일 (선택사항)",
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedTime != null
                                    ? color
                                    : Colors.grey[600],
                                fontWeight: selectedTime != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          TextButton(
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
                            child: Text(
                              selectedTime != null ? "변경" : "선택",
                              style: TextStyle(color: color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 버튼들
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Text(
                              "취소",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (taskTextController.text.isEmpty) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.warning,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text("할 일을 입력하세요."),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.red[400],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final section = isToday ? "today" : "tomorrow";
                              final taskData = {
                                "title": taskTextController.text,
                                "completed": false,
                                "time": selectedTime?.format(context),
                              };

                              // 상세 내용이 있으면 추가
                              if (descriptionController.text
                                  .trim()
                                  .isNotEmpty) {
                                taskData["description"] =
                                    descriptionController.text.trim();
                              }

                              taskController.addTask(section, taskData);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.white),
                                      const SizedBox(width: 8),
                                      const Text("할 일이 추가되었습니다!"),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.green[400],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "추가하기",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
