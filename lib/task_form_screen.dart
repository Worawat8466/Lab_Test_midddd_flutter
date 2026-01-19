// AI-ASSISTED: ฟอร์มเพิ่ม/แก้ไขงานสร้างโดย AI ทั้งหมด
// อธิบาย: ฟอร์มรับข้อมูลงานพร้อมการตรวจสอบและเลือกวันเวลา
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'press_scale.dart';
import 'task_model.dart';
import 'todo_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen>
    with SingleTickerProviderStateMixin {
  // กุญแจสำหรับตรวจสอบฟอร์ม
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // ตัวควบคุมข้อความ
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  // ค่าที่เลือกจากฟอร์ม
  String? _selectedCategory;
  DateTime? _selectedDueDate;

  // แอนิเมชันปุ่มบันทึก
  late final AnimationController _buttonController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    // เตรียมค่าเริ่มต้นเมื่อแก้ไขงาน
    super.initState();
    final task = widget.task;
    if (task != null) {
      _titleController.text = task.title;
      _selectedDueDate = task.dueDate;
      _dueDateController.text = _formatDateTime(task.dueDate);
      _selectedCategory = task.category;
    }

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1,
    )..value = 1;

    _scaleAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    // บันทึกหมวดหมู่เดิมที่ไม่อยู่ในรายการ
    super.didChangeDependencies();
    if (_selectedCategory == null) {
      return;
    }
    final provider = context.read<TodoProvider>();
    if (!provider.categories.contains(_selectedCategory)) {
      provider.addCategory(_selectedCategory!);
    }
  }

  @override
  void dispose() {
    // เคลียร์ controller ทั้งหมด
    _titleController.dispose();
    _dueDateController.dispose();
    _newCategoryController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _animatePress() async {
    // แอนิเมชันกดย่อ-เด้งของปุ่ม
    await _buttonController.reverse();
    await _buttonController.forward();
  }

  String _formatDateTime(DateTime dateTime) {
    // แปลง DateTime เป็นข้อความอ่านง่าย
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  Future<void> _pickDueDate() async {
    // เลือกวันและเวลา
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    final initialTime = _selectedDueDate != null
        ? TimeOfDay.fromDateTime(_selectedDueDate!)
        : TimeOfDay.fromDateTime(now);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime == null) {
      return;
    }

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // อัปเดตค่าในฟอร์ม
    setState(() {
      _selectedDueDate = combined;
      _dueDateController.text = _formatDateTime(combined);
    });
  }

  void _saveForm() {
    // ตรวจสอบความถูกต้องของฟอร์มก่อนบันทึก
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final isEditing = widget.task != null;
    final dueDate = _selectedDueDate ?? DateTime.now();
    final task = Task(
      // สร้างงานใหม่หรือปรับปรุงงานเดิม
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      dueDate: dueDate,
      category: _selectedCategory ?? 'อื่นๆ',
      isCompleted: widget.task?.isCompleted ?? false,
    );

    final provider = Provider.of<TodoProvider>(context, listen: false);
    if (isEditing) {
      provider.updateTask(task);
    } else {
      provider.addTask(task);
    }

    // ปิดหน้าเมื่อบันทึกเสร็จ
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลจาก Provider
    final isEditing = widget.task != null;
    final provider = context.watch<TodoProvider>();
    final categories = provider.categories;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'แก้ไขงาน' : 'เพิ่มงานใหม่')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ช่องกรอกชื่องาน
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่องาน',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่องาน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // ช่องเลือกวันและเวลา
                TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'วันที่และเวลา',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.event),
                  ),
                  onTap: _pickDueDate,
                  validator: (value) {
                    if (_selectedDueDate == null) {
                      return 'กรุณาเลือกวันที่และเวลา';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // เลือกหมวดหมู่
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'หมวดหมู่',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาเลือกหมวดหมู่';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // เพิ่มหมวดหมู่ใหม่
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'เพิ่มหมวดหมู่ใหม่',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PressScale(
                      child: IconButton(
                        tooltip: 'เพิ่มหมวดหมู่',
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          // เพิ่มหมวดหมู่และเลือกทันที
                          final text = _newCategoryController.text.trim();
                          if (text.isEmpty) {
                            return;
                          }
                          provider.addCategory(text);
                          setState(() {
                            _selectedCategory = text;
                          });
                          _newCategoryController.clear();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // แสดงรายการหมวดหมู่และลบได้
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: categories
                        .map(
                          (category) => Chip(
                            label: Text(category),
                            deleteIcon: category == 'อื่นๆ'
                                ? null
                                : const Icon(Icons.close),
                            onDeleted: category == 'อื่นๆ'
                                ? null
                                : () {
                                    // ลบหมวดหมู่และอัปเดตค่าที่เลือก
                                    provider.deleteCategory(category);
                                    if (_selectedCategory == category) {
                                      setState(() {
                                        _selectedCategory = null;
                                      });
                                    }
                                  },
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Spacer(),
                // ปุ่มบันทึกพร้อมแอนิเมชันกด
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _animatePress();
                        _saveForm();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('บันทึก'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
