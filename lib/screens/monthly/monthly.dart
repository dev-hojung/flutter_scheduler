import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthlyPage extends StatefulWidget {
  final String title; // 제목
  final List<Map<String, dynamic>> tasks; // 할 일 목록
  final Function(List<Map<String, dynamic>>) onUpdateTasks; // 상태 업데이트 콜백

  const MonthlyPage({
    super.key,
    required this.title,
    required this.tasks,
    required this.onUpdateTasks,
  });

  @override
  State<MonthlyPage> createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
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
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                final taskDate = DateTime.parse(task["date"]);
                if (!isSameDay(taskDate, _selectedDay)) return const SizedBox.shrink();
                return ListTile(
                  leading: Checkbox(
                    value: task["completed"],
                    onChanged: (bool? value) {
                      setState(() {
                        task["completed"] = value ?? false;
                      });
                      widget.onUpdateTasks(widget.tasks);
                    },
                  ),
                  title: Text(task["title"]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}