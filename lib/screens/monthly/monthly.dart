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
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
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
                    child: ListTile(
                      dense: true,
                      leading: Checkbox(
                        value: task["completed"],
                        onChanged: (bool? value) {
                          taskController.updateTaskCompletion(
                              "monthly", taskController.monthlyTasks.indexOf(task), value ?? false);
                        },
                        activeColor: Colors.deepPurple,
                      ),
                      title: Text(
                        task["title"],
                        style: TextStyle(
                          fontSize: 16,
                          color: task["completed"] ? Colors.grey : Colors.black87,
                          decoration:
                              task["completed"] ? TextDecoration.lineThrough : null,
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