import 'package:flutter/material.dart';

class DailyPage extends StatefulWidget {
  final String title; // 제목
  final List<Map<String, dynamic>> tasks; // 할 일 목록 (참조로 전달)
  final Function(List<Map<String, dynamic>>) onUpdateTasks; // 상태 업데이트 콜백

  const DailyPage({
    super.key,
    required this.title,
    required this.tasks,
    required this.onUpdateTasks,
  });

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  late List<Map<String, dynamic>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = widget.tasks; // 원본 데이터를 참조하도록 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task["completed"],
              onChanged: (bool? value) {
                setState(() {
                  task["completed"] = value ?? false; // 상태 변경
                });
                widget.onUpdateTasks(tasks); // 변경된 상태를 전달
              },
            ),
            title: Text(
              task["title"],
              style: TextStyle(
                decoration: task["completed"] ? TextDecoration.lineThrough : null,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onUpdateTasks(tasks); // 변경된 상태를 전달
          Navigator.pop(context); // 페이지 종료
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}