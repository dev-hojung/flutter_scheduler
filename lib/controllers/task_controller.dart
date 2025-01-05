import 'package:get/get.dart';

class TaskController extends GetxController {
  // 오늘, 내일, 이번 달 할 일을 각각 리스트로 관리
  var todayTasks = <Map<String, dynamic>>[
    {"title": "Flutter 공부하기", "completed": false},
    {"title": "운동하기", "completed": false},
    {"title": "책 읽기", "completed": true},
  ].obs;

  var tomorrowTasks = <Map<String, dynamic>>[
    {"title": "프로젝트 계획 세우기", "completed": false},
    {"title": "가족과 시간 보내기", "completed": true},
    {"title": "쇼핑하기", "completed": false},
  ].obs;

  var monthlyTasks = <Map<String, dynamic>>[
    {"title": "앱 완성하기", "date": "2024-01-10", "completed": false},
    {"title": "여행 준비하기", "date": "2024-01-15", "completed": false},
    {"title": "책 3권 읽기", "date": "2024-01-20", "completed": true},
    {"title": "건강 검진 받기", "date": "2024-01-25", "completed": true},
  ].obs;

  // 작업 추가
  void addTask(String section, Map<String, dynamic> task) {
    if (section == "today") {
      todayTasks.add(task);
    } else if (section == "tomorrow") {
      tomorrowTasks.add(task);
    } else if (section == "monthly") {
      monthlyTasks.add(task);
    }
  }

  // 작업 삭제
  void deleteTask(String section, int index) {
    if (section == "today") {
      todayTasks.removeAt(index);
    } else if (section == "tomorrow") {
      tomorrowTasks.removeAt(index);
    } else if (section == "monthly") {
      monthlyTasks.removeAt(index);
    }
  }

  // 작업 상태 업데이트
  void updateTaskCompletion(String section, int index, bool completed) {
    if (section == "today") {
      todayTasks[index]['completed'] = completed;
      todayTasks.refresh();
    } else if (section == "tomorrow") {
      tomorrowTasks[index]['completed'] = completed;
      tomorrowTasks.refresh();
    } else if (section == "monthly") {
      monthlyTasks[index]['completed'] = completed;
      monthlyTasks.refresh();
    }
  }
}