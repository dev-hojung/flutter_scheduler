import 'package:flutter/material.dart';
import '../daily/daily.dart';
import '../monthly/monthly.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 할 일 데이터
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
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          padding: const EdgeInsets.only(
            top: kToolbarHeight, // AppBar 높이만큼 여백 추가
            left: 16,
            right: 16,
            bottom: 16, // 하단 여백 추가
          ),
          children: [
            _buildTaskSection(
              title: "오늘 할 일",
              tasks: todayTasks,
              color: Colors.blue,
              isMonthly: false,
            ),
            const SizedBox(height: 12), // 카드 간 간격
            _buildTaskSection(
              title: "내일 할 일",
              tasks: tomorrowTasks,
              color: Colors.orange,
              isMonthly: false,
            ),
            const SizedBox(height: 12), // 카드 간 간격
            _buildTaskSection(
              title: "이번 달 할 일",
              tasks: monthlyTasks,
              color: Colors.green,
              isMonthly: true,
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 카드
  Widget _buildTaskSection({
    required String title,
    required List<Map<String, dynamic>> tasks,
    required Color color,
    required bool isMonthly,
  }) {
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
            _buildSectionHeader(title: title, color: color),
            const SizedBox(height: 8), // 헤더와 첫 Task 간 간격
            ...tasks.map((task) => _buildTaskItem(task, color)),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () => _navigateToPage(
                  context: context,
                  title: title,
                  tasks: tasks,
                  isMonthly: isMonthly,
                ),
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

  // 섹션 헤더
  Widget _buildSectionHeader({required String title, required Color color}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 30,
          color: color,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // 할 일 항목
  Widget _buildTaskItem(Map<String, dynamic> task, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Task 간 간격
      child: ListTile(
        dense: true, // 간결한 디자인
        leading: Checkbox(
          value: task["completed"],
          onChanged: (bool? value) {
            setState(() {
              task["completed"] = value ?? false;
            });
          },
          activeColor: color, // 카드별 색상 적용
        ),
        title: Text(
          task["title"],
          style: TextStyle(
            fontSize: 16,
            color: task["completed"] ? Colors.grey : Colors.black87,
            decoration: task["completed"] ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }

  // 페이지 이동
  void _navigateToPage({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> tasks,
    required bool isMonthly,
  }) async {
    final updatedTasks = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isMonthly
            ? MonthlyPage(
                title: title,
                tasks: List.from(tasks),
                onUpdateTasks: (updatedTasks) {
                  setState(() {
                    tasks.clear();
                    tasks.addAll(updatedTasks);
                  });
                },
              )
            : DailyPage(
                title: title,
                tasks: List.from(tasks),
                onUpdateTasks: (updatedTasks) {
                  setState(() {
                    tasks.clear();
                    tasks.addAll(updatedTasks);
                  });
                },
                color: title == "오늘 할 일" // 색상을 HomePage와 동일하게 설정
                    ? Colors.blue
                    : Colors.orange,
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