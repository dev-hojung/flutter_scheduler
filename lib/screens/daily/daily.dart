import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  late List<Map<String, dynamic>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = List<Map<String, dynamic>>.from(widget.tasks);
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
            widget.onUpdateTasks(tasks);
            Navigator.pop(context);
          },
        ),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                '할 일이 없습니다.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _buildTaskItem(context, tasks[index], index);
              },
            ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Slidable(
        key: ValueKey(task),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                setState(() {
                  tasks.removeAt(index); // 항목 삭제
                });
              },
              backgroundColor: Colors.red,
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 36.0,
              ),
            ),
          ],
        ),
        child: ListTile(
          dense: true,
          leading: Checkbox(
            value: task["completed"],
            onChanged: (bool? value) {
              setState(() {
                task["completed"] = value ?? false;
              });
            },
            activeColor: widget.color,
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
      ),
    );
  }
}