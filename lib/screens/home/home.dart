import 'package:flutter/material.dart';
import '../daily/daily.dart';
import '../monthly/monthly.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> todayTasks = [
    {"title": "Flutter 공부하기", "completed": false},
    {"title": "운동하기", "completed": false},
    {"title": "책 읽기", "completed": true},
  ];

  final List<Map<String, dynamic>> tomorrowTasks = [
    {"title": "프로젝트 계획 세우기", "completed": false},
    {"title": "가족과 시간 보내기", "completed": true},
    {"title": "쇼핑하기", "completed": false},
  ];

  final List<Map<String, dynamic>> monthlyTasks = [
    {"title": "앱 완성하기", "date": "2024-01-10", "completed": false},
    {"title": "여행 준비하기", "date": "2024-01-15", "completed": false},
    {"title": "책 3권 읽기", "date": "2024-01-20", "completed": true},
    {"title": "건강 검진 받기", "date": "2024-01-25", "completed": true},
  ];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: EdgeInsets.only(
            top: statusBarHeight,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '할 일 관리',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildTaskSection("오늘 할 일", todayTasks, Colors.blue, false),
                    const SizedBox(height: 16),
                    _buildTaskSection("내일 할 일", tomorrowTasks, Colors.orange, false),
                    const SizedBox(height: 16),
                    _buildTaskSection("이번 달 할 일", monthlyTasks, Colors.green, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<Map<String, dynamic>> tasks, Color color, bool isMonthly) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 30,
                  color: color,
                ),
                const SizedBox(width: 12),
                Text(
                  "$title (${tasks.length})",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            ...tasks.map((task) => _buildTaskItem(task)),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  _navigateToPage(context, title, tasks, isMonthly);
                },
                child: Text(
                  "전체 보기",
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return ListTile(
      leading: Checkbox(
        value: task["completed"],
        onChanged: (bool? value) {
          setState(() {
            task["completed"] = value ?? false;
          });
        },
        activeColor: Colors.deepPurple,
      ),
      title: Text(
        task["title"],
        style: TextStyle(
          fontSize: 16,
          color: task["completed"] ? Colors.grey : Colors.black87,
          decoration: task["completed"] ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String title, List<Map<String, dynamic>> tasks, bool isMonthly) async {
    final updatedTasks = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isMonthly
            ? MonthlyPage(
                title: title,
                tasks: tasks,
                onUpdateTasks: (updatedTasks) {
                  setState(() {
                    tasks.addAll(updatedTasks);
                  });
                },
              )
            : DailyPage(
                title: title,
                tasks: tasks,
                onUpdateTasks: (updatedTasks) {
                  setState(() {
                    tasks.addAll(updatedTasks);
                  });
                },
              ),
      ),
    );

    if (updatedTasks != null) {
      setState(() {
        tasks.clear();
        tasks.addAll(updatedTasks);
      });
    }
  }
}