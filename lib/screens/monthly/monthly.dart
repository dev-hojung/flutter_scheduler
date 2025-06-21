import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/task_controller.dart';

class MonthlyPage extends StatefulWidget {
  final String title; // 제목

  const MonthlyPage({
    super.key,
    required this.title,
  });

  @override
  State<MonthlyPage> createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  final TaskController taskController = Get.find<TaskController>();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 특정 날짜에 일정이 있는지 확인하는 메서드
  List<Map<String, dynamic>> _getTasksForDay(DateTime day) {
    return taskController.monthlyTasks.where((task) {
      final taskDate = DateTime.parse(task["date"]);
      return isSameDay(taskDate, day);
    }).toList();
  }

  void _showAddTaskDialog(DateTime selectedDate) {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "${selectedDate.month}월 ${selectedDate.day}일 일정 추가",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "일정 내용",
              border: OutlineInputBorder(),
              hintText: "할 일을 입력해주세요",
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  taskController.addTask("monthly", {
                    "title": titleController.text.trim(),
                    "date":
                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                    "completed": false,
                  });
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    final TextEditingController titleController =
        TextEditingController(text: task["title"]);
    final DateTime taskDate = DateTime.parse(task["date"]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "${taskDate.month}월 ${taskDate.day}일 일정 수정",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "일정 내용",
              border: OutlineInputBorder(),
              hintText: "할 일을 입력해주세요",
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                // 삭제 기능
                final taskIndex = taskController.monthlyTasks.indexOf(task);
                taskController.deleteTask("monthly", taskIndex);
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text("삭제", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  final taskIndex = taskController.monthlyTasks.indexOf(task);
                  final updatedTask = Map<String, dynamic>.from(task);
                  updatedTask["title"] = titleController.text.trim();

                  taskController.updateTask("monthly", taskIndex, updatedTask);
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text("수정"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getTasksForDay(day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onDayLongPressed: (selectedDay, focusedDay) {
              _showAddTaskDialog(selectedDay);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return GestureDetector(
                  onDoubleTap: () {
                    _showAddTaskDialog(day);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(),
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return GestureDetector(
                  onDoubleTap: () {
                    _showAddTaskDialog(day);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return GestureDetector(
                  onDoubleTap: () {
                    _showAddTaskDialog(day);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(3).map((event) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color: (event as Map<String, dynamic>)['completed']
                                ? Colors.grey
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return null;
              },
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final filteredTasks = taskController.monthlyTasks.where((task) {
                final taskDate = DateTime.parse(task["date"]);
                return isSameDay(taskDate, _selectedDay);
              }).toList();

              if (filteredTasks.isEmpty) {
                return const Center(
                  child: Text(
                    "선택된 날짜에 할 일이 없습니다.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: GestureDetector(
                      onDoubleTap: () {
                        _showEditTaskDialog(task);
                      },
                      onLongPress: () {
                        _showEditTaskDialog(task);
                      },
                      child: ListTile(
                        dense: true,
                        leading: Checkbox(
                          value: task["completed"],
                          onChanged: (bool? value) {
                            taskController.updateTaskCompletion(
                                "monthly",
                                taskController.monthlyTasks.indexOf(task),
                                value ?? false);
                          },
                          activeColor: Colors.deepPurple,
                        ),
                        title: Text(
                          task["title"],
                          style: TextStyle(
                            fontSize: 16,
                            color: task["completed"]
                                ? Colors.grey
                                : Colors.black87,
                            decoration: task["completed"]
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
