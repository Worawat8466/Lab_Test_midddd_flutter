// AI-ASSISTED: โค้ดไฟล์หลักสร้างโดย AI ทั้งหมด
// อธิบาย: กำหนดจุดเริ่มต้นของแอปและเชื่อม Provider กับ MaterialApp
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'onboarding_screen.dart';
import 'todo_provider.dart';

void main() {
  // เริ่มรันแอป โดยครอบด้วย MultiProvider เพื่อใช้ state ทั้งแอป
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TodoProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ฟังค่าธีมจาก Provider แล้วส่งเข้า MaterialApp
    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // ชื่อแอป
          title: 'My To-Do List',
          // ธีมสว่าง/มืด
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // หน้าเริ่มต้น
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
