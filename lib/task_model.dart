// AI-ASSISTED: โมเดลข้อมูลงานสร้างโดย AI ทั้งหมด
// อธิบาย: เก็บข้อมูลพื้นฐานของงานแต่ละรายการ
class Task {
  // รหัสงาน
  final String id;
  // ชื่องาน
  final String title;
  // วัน/เวลาที่กำหนดส่ง
  final DateTime dueDate;
  // หมวดหมู่งาน
  final String category;
  // สถานะงานเสร็จหรือยัง
  final bool isCompleted;

  const Task({
    // สร้าง Task ใหม่พร้อมข้อมูลครบ
    required this.id,
    required this.title,
    required this.dueDate,
    required this.category,
    required this.isCompleted,
  });

  Task copyWith({
    // สร้างสำเนาพร้อมปรับค่าบางส่วน
    String? id,
    String? title,
    DateTime? dueDate,
    String? category,
    bool? isCompleted,
  }) {
    // คืนค่า Task ใหม่
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
