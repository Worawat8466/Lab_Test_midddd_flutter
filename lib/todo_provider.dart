// AI-ASSISTED: ตัวจัดการสถานะและหมวดหมู่สร้างโดย AI ทั้งหมด
// อธิบาย: จัดเก็บรายการงาน, หมวดหมู่ และธีม พร้อมแจ้งเตือนผู้ฟังเมื่อเปลี่ยนแปลง
import 'package:flutter/foundation.dart';

import 'task_model.dart';

class TodoProvider extends ChangeNotifier {
  // รายการหมวดหมู่ที่ใช้งานได้
  final List<String> _categories = ['เรียน', 'งานบ้าน', 'อื่นๆ'];
  // รายการงานตัวอย่างเริ่มต้น
  final List<Task> _tasks = [
    Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'อ่านหนังสือสอบ',
      dueDate: DateTime.now().add(const Duration(days: 3, hours: 2)),
      category: 'เรียน',
      isCompleted: false,
    ),
    Task(
      id: DateTime.now()
          .add(const Duration(milliseconds: 1))
          .millisecondsSinceEpoch
          .toString(),
      title: 'ล้างจาน',
      dueDate: DateTime.now().add(const Duration(hours: 6)),
      category: 'งานบ้าน',
      isCompleted: false,
    ),
    Task(
      id: DateTime.now()
          .add(const Duration(milliseconds: 2))
          .millisecondsSinceEpoch
          .toString(),
      title: 'ออกกำลังกาย',
      dueDate: DateTime.now().add(const Duration(days: 1, hours: 4)),
      category: 'อื่นๆ',
      isCompleted: true,
    ),
  ];

  // สถานะธีมปัจจุบัน
  bool _isDarkMode = false;

  // Getter: อ่านรายการงานแบบป้องกันแก้ไข
  List<Task> get tasks => List.unmodifiable(_tasks);
  // Getter: อ่านรายการหมวดหมู่แบบป้องกันแก้ไข
  List<String> get categories => List.unmodifiable(_categories);
  // Getter: อ่านสถานะธีม
  bool get isDarkMode => _isDarkMode;

  // เพิ่มงานใหม่
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  // แก้ไขงานเดิมด้วย id
  void updateTask(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      return;
    }
    _tasks[index] = task;
    notifyListeners();
  }

  // ลบงานตาม id
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  // สลับธีมสว่าง/มืด
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // สลับลำดับงานตามการลากเรียง
  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _tasks.length) {
      return;
    }
    if (newIndex < 0 || newIndex >= _tasks.length) {
      return;
    }
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, item);
    notifyListeners();
  }

  // เพิ่มหมวดหมู่ใหม่ (ถ้าไม่ซ้ำและไม่ว่าง)
  void addCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) {
      return;
    }
    if (_categories.contains(trimmed)) {
      return;
    }
    _categories.add(trimmed);
    notifyListeners();
  }

  // ลบหมวดหมู่ และย้ายงานที่ใช้หมวดหมู่นั้นไป "อื่นๆ"
  void deleteCategory(String category) {
    if (category == 'อื่นๆ') {
      return;
    }
    final removed = _categories.remove(category);
    if (!removed) {
      return;
    }
    for (var i = 0; i < _tasks.length; i += 1) {
      final task = _tasks[i];
      if (task.category == category) {
        _tasks[i] = task.copyWith(category: 'อื่นๆ');
      }
    }
    notifyListeners();
  }
}
