import 'package:flutter/material.dart';

class DailyPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> tasks;
  final Function(List<Map<String, dynamic>>) onUpdateTasks;
  final Color color;

  const DailyPage({
    super.key,
    required this.title,
    required this.tasks,
    required this.onUpdateTasks,
    required this.color,
  });

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  late List<Map<String, dynamic>> completedTasks;
  late List<Map<String, dynamic>> pendingTasks;

  @override
  void initState() {
    super.initState();
    // 완료된 할 일과 완료되지 않은 할 일을 초기화
    completedTasks = widget.tasks.where((task) => task["completed"] == true).toList();
    pendingTasks = widget.tasks.where((task) => task["completed"] == false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onUpdateTasks([...completedTasks, ...pendingTasks]);
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildTaskList(
              title: "완료한 일",
              tasks: completedTasks,
              color: Colors.green,
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: _buildTaskList(
              title: "해야 할 일",
              tasks: pendingTasks,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList({required String title, required List<Map<String, dynamic>> tasks, required Color color}) {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text(
                        '항목이 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskItem(task, color);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        dense: true,
        leading: Checkbox(
          value: task["completed"],
          onChanged: (bool? value) {
            setState(() {
              task["completed"] = value ?? false;

              if (task["completed"]) {
                pendingTasks.remove(task);
                completedTasks.add(task);
              } else {
                completedTasks.remove(task);
                pendingTasks.add(task);
              }
            });
          },
          activeColor: color,
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
}