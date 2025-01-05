import 'package:flutter/material.dart';
import 'controllers/task_controller.dart';
import 'screens/home/home.dart'; // HomePage 파일 import
import 'package:get/get.dart';

void main() {
  Get.put(TaskController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '할 일 관리',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
    );
  }
}