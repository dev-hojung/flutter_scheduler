import 'package:get/get.dart';

class TaskController extends GetxController {
  // 모든 할 일을 하나의 리스트로 관리 (날짜별로 필터링)
  var allTasks = <Map<String, dynamic>>[].obs;

  // 샘플 데이터 초기화
  @override
  void onInit() {
    super.onInit();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final todayString =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final tomorrowString =
        "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";

    allTasks.addAll([
      // 오늘 할 일
      {
        "title": "Flutter 공부하기",
        "completed": false,
        "date": todayString,
        "time": "09:00"
      },
      {
        "title": "운동하기",
        "completed": false,
        "date": todayString,
        "time": "18:00"
      },
      {
        "title": "책 읽기",
        "completed": true,
        "date": todayString,
        "time": "21:00"
      },

      // 내일 할 일
      {
        "title": "프로젝트 계획 세우기",
        "completed": false,
        "date": tomorrowString,
        "time": "10:00"
      },
      {
        "title": "가족과 시간 보내기",
        "completed": true,
        "date": tomorrowString,
        "time": "15:00"
      },
      {
        "title": "쇼핑하기",
        "completed": false,
        "date": tomorrowString,
        "time": "14:00"
      },

      // 월간 할 일 (기존 유지)
      {"title": "앱 완성하기", "date": "2024-12-25", "completed": false},
      {"title": "여행 준비하기", "date": "2024-12-30", "completed": false},
      {"title": "책 3권 읽기", "date": "2025-01-05", "completed": true},
      {"title": "건강 검진 받기", "date": "2025-01-10", "completed": true},
    ]);
  }

  // 오늘 할 일 getter
  RxList<Map<String, dynamic>> get todayTasks {
    final today = DateTime.now();
    final todayString =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return allTasks.where((task) => task["date"] == todayString).toList().obs;
  }

  // 내일 할 일 getter
  RxList<Map<String, dynamic>> get tomorrowTasks {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowString =
        "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";

    return allTasks
        .where((task) => task["date"] == tomorrowString)
        .toList()
        .obs;
  }

  // 월간 할 일 getter (기존과 동일하지만 allTasks에서 필터링)
  RxList<Map<String, dynamic>> get monthlyTasks {
    return allTasks
        .where((task) =>
            task["date"] != null && task["date"].toString().isNotEmpty)
        .toList()
        .obs;
  }

  // 작업 추가 (날짜 기반)
  void addTask(String section, Map<String, dynamic> task) {
    if (section == "today") {
      final today = DateTime.now();
      task["date"] =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    } else if (section == "tomorrow") {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      task["date"] =
          "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
    }
    // monthly는 이미 date가 설정되어 있음

    allTasks.add(task);
  }

  // 작업 삭제
  void deleteTask(String section, int index) {
    if (section == "today") {
      final todayTasksList = todayTasks;
      if (index < todayTasksList.length) {
        allTasks.remove(todayTasksList[index]);
      }
    } else if (section == "tomorrow") {
      final tomorrowTasksList = tomorrowTasks;
      if (index < tomorrowTasksList.length) {
        allTasks.remove(tomorrowTasksList[index]);
      }
    } else if (section == "monthly") {
      final monthlyTasksList = monthlyTasks;
      if (index < monthlyTasksList.length) {
        allTasks.remove(monthlyTasksList[index]);
      }
    }
  }

  // 작업 상태 업데이트
  void updateTaskCompletion(String section, int index, bool completed) {
    if (section == "today") {
      final todayTasksList = todayTasks;
      if (index < todayTasksList.length) {
        final taskToUpdate = todayTasksList[index];
        final allTaskIndex = allTasks.indexOf(taskToUpdate);
        if (allTaskIndex != -1) {
          allTasks[allTaskIndex]['completed'] = completed;
          allTasks.refresh();
        }
      }
    } else if (section == "tomorrow") {
      final tomorrowTasksList = tomorrowTasks;
      if (index < tomorrowTasksList.length) {
        final taskToUpdate = tomorrowTasksList[index];
        final allTaskIndex = allTasks.indexOf(taskToUpdate);
        if (allTaskIndex != -1) {
          allTasks[allTaskIndex]['completed'] = completed;
          allTasks.refresh();
        }
      }
    } else if (section == "monthly") {
      final monthlyTasksList = monthlyTasks;
      if (index < monthlyTasksList.length) {
        final taskToUpdate = monthlyTasksList[index];
        final allTaskIndex = allTasks.indexOf(taskToUpdate);
        if (allTaskIndex != -1) {
          allTasks[allTaskIndex]['completed'] = completed;
          allTasks.refresh();
        }
      }
    }
  }

  // 작업 수정
  void updateTask(String section, int index, Map<String, dynamic> updatedTask) {
    if (section == "today") {
      final todayTasksList = todayTasks;
      if (index < todayTasksList.length) {
        final taskToUpdate = todayTasksList[index];
        final allTaskIndex = allTasks.indexOf(taskToUpdate);
        if (allTaskIndex != -1) {
          allTasks[allTaskIndex] = updatedTask;
          allTasks.refresh();
        }
      }
    } else if (section == "tomorrow") {
      final tomorrowTasksList = tomorrowTasks;
      if (index < tomorrowTasksList.length) {
        final taskToUpdate = tomorrowTasksList[index];
        final allTaskIndex = allTasks.indexOf(taskToUpdate);
        if (allTaskIndex != -1) {
          allTasks[allTaskIndex] = updatedTask;
          allTasks.refresh();
        }
      }
    } else if (section == "monthly") {
      final monthlyTasksList = monthlyTasks;
      if (index < monthlyTasksList.length) {
        final taskToUpdate = monthlyTasksList[index];
        final allTaskIndex = allTasks.indexOf(taskToUpdate);
        if (allTaskIndex != -1) {
          allTasks[allTaskIndex] = updatedTask;
          allTasks.refresh();
        }
      }
    }
  }
}
