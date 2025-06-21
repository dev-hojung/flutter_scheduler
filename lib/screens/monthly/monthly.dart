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
  DateTime? _selectedDay = DateTime.now();

  // 특정 날짜에 일정이 있는지 확인하는 메서드
  List<Map<String, dynamic>> _getTasksForDay(DateTime day) {
    return taskController.monthlyTasks.where((task) {
      final taskDate = DateTime.parse(task["date"]);
      return isSameDay(taskDate, day);
    }).toList();
  }

  void _showAddTaskDialog(DateTime selectedDate) {
    // 오늘 이전 날짜는 일정 등록 불가
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final selectedOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (selectedOnly.isBefore(todayOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("과거 날짜에는 일정을 등록할 수 없습니다."),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController titleController = TextEditingController();
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
                          child: const Icon(
                            Icons.event_note,
                            color: Colors.deepPurple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "일정 추가",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                "${selectedDate.month}월 ${selectedDate.day}일",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

                    // 일정 입력 필드
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "일정 내용",
                          hintText: "어떤 일정이 있으신가요?",
                          prefixIcon:
                              Icon(Icons.edit, color: Colors.deepPurple),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          labelStyle: TextStyle(color: Colors.deepPurple),
                        ),
                        autofocus: true,
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
                          color: selectedTime != null
                              ? Colors.deepPurple
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: selectedTime != null
                                ? Colors.deepPurple
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "시간",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedTime != null
                                      ? selectedTime!.format(context)
                                      : "하루 종일 (선택사항)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: selectedTime != null
                                        ? Colors.deepPurple
                                        : Colors.grey[600],
                                    fontWeight: selectedTime != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  selectedTime = time;
                                });
                              }
                            },
                            child: Text(
                              selectedTime != null ? "변경" : "선택",
                              style: const TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                          if (selectedTime != null)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedTime = null;
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: 20,
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
                              if (titleController.text.trim().isNotEmpty) {
                                final taskData = {
                                  "title": titleController.text.trim(),
                                  "date":
                                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                                  "completed": false,
                                };

                                if (selectedTime != null) {
                                  taskData["time"] =
                                      selectedTime!.format(context);
                                }

                                taskController.addTask("monthly", taskData);
                                this.setState(() {});
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text("일정이 추가되었습니다!"),
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
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.warning,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text("일정 내용을 입력해주세요."),
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
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
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

  void _showEditTaskDialog(Map<String, dynamic> task) {
    final TextEditingController titleController =
        TextEditingController(text: task["title"]);
    final DateTime taskDate = DateTime.parse(task["date"]);

    // 기존 시간 정보가 있으면 파싱, 없으면 null
    TimeOfDay? selectedTime;
    if (task["time"] != null && task["time"].toString().isNotEmpty) {
      final timeParts = task["time"].toString().split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

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
                          child: const Icon(
                            Icons.edit_calendar,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "일정 수정",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                "${taskDate.month}월 ${taskDate.day}일",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

                    // 일정 입력 필드
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "일정 내용",
                          hintText: "수정할 내용을 입력하세요",
                          prefixIcon: Icon(Icons.edit, color: Colors.orange),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          labelStyle: TextStyle(color: Colors.orange),
                        ),
                        autofocus: true,
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
                          color: selectedTime != null
                              ? Colors.orange
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: selectedTime != null
                                ? Colors.orange
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "시간",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedTime != null
                                      ? selectedTime!.format(context)
                                      : "하루 종일 (선택사항)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: selectedTime != null
                                        ? Colors.orange
                                        : Colors.grey[600],
                                    fontWeight: selectedTime != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  selectedTime = time;
                                });
                              }
                            },
                            child: const Text(
                              "변경",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                          if (selectedTime != null)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedTime = null;
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: 20,
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              // 삭제 확인 다이얼로그
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("일정 삭제"),
                                  content: const Text("정말로 이 일정을 삭제하시겠습니까?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("취소"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final taskIndex = taskController
                                            .monthlyTasks
                                            .indexOf(task);
                                        taskController.deleteTask(
                                            "monthly", taskIndex);
                                        this.setState(() {});
                                        Navigator.pop(context); // 확인 다이얼로그 닫기
                                        Navigator.pop(context); // 수정 다이얼로그 닫기
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.white),
                                                SizedBox(width: 8),
                                                Text("일정이 삭제되었습니다."),
                                              ],
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                            backgroundColor: Colors.red[400],
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("삭제",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  "삭제",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (titleController.text.trim().isNotEmpty) {
                                final taskIndex =
                                    taskController.monthlyTasks.indexOf(task);
                                final updatedTask =
                                    Map<String, dynamic>.from(task);
                                updatedTask["title"] =
                                    titleController.text.trim();

                                if (selectedTime != null) {
                                  updatedTask["time"] =
                                      selectedTime!.format(context);
                                } else {
                                  updatedTask.remove("time");
                                }

                                taskController.updateTask(
                                    "monthly", taskIndex, updatedTask);
                                this.setState(() {});
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text("일정이 수정되었습니다!"),
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
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.warning,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text("일정 내용을 입력해주세요."),
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
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
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
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  "수정하기",
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
            locale: 'ko_KR',
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            enabledDayPredicate: (day) {
              final today = DateTime.now();
              final todayOnly = DateTime(today.year, today.month, today.day);
              final dayOnly = DateTime(day.year, day.month, day.day);
              return !dayOnly.isBefore(todayOnly);
            },
            eventLoader: (day) => _getTasksForDay(day),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: '월',
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                final today = DateTime.now();
                final todayOnly = DateTime(today.year, today.month, today.day);
                final dayOnly = DateTime(day.year, day.month, day.day);
                final isPastDate = dayOnly.isBefore(todayOnly);

                return GestureDetector(
                  onDoubleTap: isPastDate
                      ? null
                      : () {
                          _showAddTaskDialog(day);
                        },
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(),
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        color:
                            isPastDate ? Colors.grey.shade400 : Colors.black87,
                      ),
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
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
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
          // 월간 달성률 표시
          Obx(() {
            final currentMonth = _focusedDay.month;
            final currentYear = _focusedDay.year;
            final monthlyTasks = taskController.monthlyTasks.where((task) {
              final taskDate = DateTime.parse(task["date"]);
              return taskDate.year == currentYear &&
                  taskDate.month == currentMonth;
            }).toList();

            if (monthlyTasks.isNotEmpty) {
              final completedMonthlyTasks =
                  monthlyTasks.where((task) => task["completed"]).length;
              final totalMonthlyTasks = monthlyTasks.length;
              final monthlyAchievementRate =
                  (completedMonthlyTasks / totalMonthlyTasks * 100).round();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$currentYear년 $currentMonth월 전체 달성률",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$completedMonthlyTasks / $totalMonthlyTasks 완료",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: monthlyAchievementRate == 100
                            ? Colors.green
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$monthlyAchievementRate%",
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
            }
            return const SizedBox.shrink();
          }),
          // 일별 달성률 표시
          Obx(() {
            final filteredTasks = taskController.monthlyTasks.where((task) {
              final taskDate = DateTime.parse(task["date"]);
              return isSameDay(taskDate, _selectedDay);
            }).toList();

            if (filteredTasks.isNotEmpty) {
              final completedTasks =
                  filteredTasks.where((task) => task["completed"]).length;
              final totalTasks = filteredTasks.length;
              final achievementRate =
                  (completedTasks / totalTasks * 100).round();
              final selectedDate = _selectedDay!;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedDate.month}월 ${selectedDate.day}일 달성률",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: achievementRate == 100
                            ? Colors.green
                            : Colors.deepPurple,
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
            }
            return const SizedBox.shrink();
          }),
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
                          "${task["title"]} ${task["time"] != null && task["time"].toString().isNotEmpty ? '(${task["time"]})' : '(하루종일)'}",
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
