import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../daily/daily.dart';
import '../monthly/monthly.dart';

class HomePage extends StatelessWidget {
  final TaskController taskController = Get.find();

  HomePage({super.key});

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
              tasks: taskController.todayTasks,
              color: Colors.blue,
              isMonthly: false,
              isToday: true,
            ),
            const SizedBox(height: 12), // 카드 간 간격
            _buildTaskSection(
              title: "내일 할 일",
              tasks: taskController.tomorrowTasks,
              color: Colors.orange,
              isMonthly: false,
            ),
            const SizedBox(height: 12), // 카드 간 간격
            _buildTaskSection(
              title: "이번 달 할 일",
              tasks: taskController.monthlyTasks,
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
    required RxList<Map<String, dynamic>> tasks,
    required Color color,
    required bool isMonthly,
    bool isToday = false
  }) {
    return GestureDetector(
      onTap: () => _navigateToPage(
        title: title,
        isMonthly: isMonthly,
        isToday: isToday,
        color: color
      ),
      child: Card(
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
              Obx(
                () => tasks.isEmpty
                    ? Center(
                        child: Text(
                          "목록이 없습니다.",
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        ),
                      )
                    : Column(
                        children:
                            tasks.map((task) => _buildTaskItem(task, color)).toList(),
                      ),
              ),
            ],
          ),
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
          onChanged: null, // 체크 기능 비활성화
          checkColor: Colors.white, // 체크 내부 색상
          fillColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              // 체크된 상태일 경우 카드 색상
              if (task["completed"]) {
                return color;
              }
              return null;
            },
          ),
        ),
        title: Text(
          task["title"],
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            decoration: task["completed"] ? TextDecoration.lineThrough : null,
          ),
        ),
        // 시간 표시
        subtitle: task.containsKey("time") && task["time"] != null
            ? Text(
                "${task["time"]}",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              )
            : null,
      ),
    );
  }

  // 페이지 이동
  void _navigateToPage({
    required String title,
    required bool isMonthly,
    Color? color,
    bool isToday = false
  }) {
    Get.to(() => isMonthly
        ? MonthlyPage(title: title)
        : DailyPage(title: title, color: color!, isToday: isToday));
  }
}