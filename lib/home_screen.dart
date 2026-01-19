// AI-ASSISTED: หน้าหลักและรายการงานสร้างโดย AI ทั้งหมด
// อธิบาย: แสดงรายการงาน, ค้นหา, ลากเรียง, ปัดลบ/แก้ไข และสลับธีม
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'press_scale.dart';
import 'task_form_screen.dart';
import 'task_model.dart';
import 'todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ตัวควบคุมช่องค้นหา
  final TextEditingController _searchController = TextEditingController();
  // ข้อความค้นหาปัจจุบัน
  String _searchQuery = '';

  // แอนิเมชันสำหรับ FAB
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;
  // ตัวจับเวลาเพื่อรีเฟรชเวลาคงเหลือ
  Timer? _ticker;

  @override
  void initState() {
    // ตั้งค่า listener และแอนิเมชันเริ่มต้น
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1,
    )..value = 1;

    _fabScale = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    // อัปเดตเวลาคงเหลือทุก 30 วินาที
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // เคลียร์ทรัพยากรเมื่อปิดหน้า
    _searchController.dispose();
    _fabController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _animateFab() async {
    // แอนิเมชันกด FAB
    await _fabController.reverse();
    await _fabController.forward();
  }

  List<Task> _filterTasks(List<Task> tasks) {
    // กรองรายการตามคำค้นหา
    if (_searchQuery.isEmpty) {
      return tasks;
    }
    final query = _searchQuery.toLowerCase();
    return tasks
        .where(
          (task) =>
              task.title.toLowerCase().contains(query) ||
              task.category.toLowerCase().contains(query),
        )
        .toList();
  }

  String _formatRemaining(DateTime dueDate) {
    // แสดงเวลาคงเหลือแบบอ่านง่าย
    final now = DateTime.now();
    final diff = dueDate.difference(now);
    if (diff.isNegative) {
      return 'เลยกำหนดแล้ว';
    }
    final totalMinutes = diff.inMinutes;
    final days = totalMinutes ~/ (60 * 24);
    final hours = (totalMinutes % (60 * 24)) ~/ 60;
    final minutes = totalMinutes % 60;

    if (days > 0) {
      return 'เหลือ $days วัน $hours ชม.';
    }
    if (hours > 0) {
      return 'เหลือ $hours ชม. $minutes นาที';
    }
    return 'เหลือ $minutes นาที';
  }

  @override
  Widget build(BuildContext context) {
    // สร้าง UI จากข้อมูลใน Provider
    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        final filteredTasks = _filterTasks(provider.tasks);
        return Scaffold(
          appBar: AppBar(
            title: const Text('My To-Do List'),
            actions: [
              // ปุ่มสลับธีม
              PressScale(
                child: IconButton(
                  onPressed: provider.toggleTheme,
                  icon: Icon(
                    provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  // ช่องค้นหา
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหางานหรือหมวดหมู่',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  // รายการที่ลากเรียงได้
                  itemCount: filteredTasks.length,
                  onReorder: (oldIndex, newIndex) {
                    // แปลงตำแหน่งใน filtered list ไปยัง list จริง
                    if (filteredTasks.isEmpty) {
                      return;
                    }
                    final adjustedNewIndex = newIndex > oldIndex
                        ? newIndex - 1
                        : newIndex;
                    if (adjustedNewIndex < 0 ||
                        adjustedNewIndex >= filteredTasks.length) {
                      return;
                    }
                    final oldTask = filteredTasks[oldIndex];
                    final newTask = filteredTasks[adjustedNewIndex];
                    final oldIndexAll = provider.tasks.indexWhere(
                      (task) => task.id == oldTask.id,
                    );
                    final newIndexAll = provider.tasks.indexWhere(
                      (task) => task.id == newTask.id,
                    );
                    if (oldIndexAll == -1 || newIndexAll == -1) {
                      return;
                    }
                    provider.reorderTasks(oldIndexAll, newIndexAll);
                  },
                  itemBuilder: (context, index) {
                    // สร้างแต่ละรายการงาน
                    final task = filteredTasks[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      // ปัดขวาเพื่อแก้ไข
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      // ปัดซ้ายเพื่อลบ
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        // ตรวจทิศทางการปัด
                        if (direction == DismissDirection.startToEnd) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskFormScreen(task: task),
                            ),
                          );
                          return false;
                        }
                        if (direction == DismissDirection.endToStart) {
                          provider.deleteTask(task.id);
                          return true;
                        }
                        return false;
                      },
                      child: ListTile(
                        // แสดงรายละเอียดงาน
                        title: Text(task.title),
                        subtitle: Text(
                          '${task.category} • ${_formatRemaining(task.dueDate)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ปุ่มแก้ไข
                            PressScale(
                              child: IconButton(
                                tooltip: 'แก้ไข',
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TaskFormScreen(task: task),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // ปุ่มเช็คเสร็จ/ยังไม่เสร็จ
                            PressScale(
                              child: IconButton(
                                tooltip: task.isCompleted
                                    ? 'ยกเลิกเสร็จ'
                                    : 'ทำเสร็จ',
                                icon: Icon(
                                  task.isCompleted
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: task.isCompleted
                                      ? Colors.green
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  provider.updateTask(
                                    task.copyWith(
                                      isCompleted: !task.isCompleted,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: ScaleTransition(
            scale: _fabScale,
            // ปุ่มเพิ่มงานใหม่
            child: PressScale(
              child: FloatingActionButton(
                onPressed: () async {
                  await _animateFab();
                  if (!mounted) {
                    return;
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskFormScreen()),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );
      },
    );
  }
}
