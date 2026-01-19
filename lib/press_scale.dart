// AI-ASSISTED: วิดเจ็ตกดแล้วซูมสร้างโดย AI ทั้งหมด
// อธิบาย: ห่อปุ่มเพื่อให้ย่อ-เด้งเมื่อกด
import 'package:flutter/material.dart';

class PressScale extends StatefulWidget {
  // วิดเจ็ตลูกที่ต้องการเอฟเฟกต์
  final Widget child;
  // สเกลตอนกด
  final double pressedScale;
  // ระยะเวลาของแอนิเมชัน
  final Duration duration;

  const PressScale({
    super.key,
    // ตั้งค่าพื้นฐานของเอฟเฟกต์การกด
    required this.child,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  // เก็บสถานะว่ากำลังกดอยู่หรือไม่
  bool _pressed = false;

  void _setPressed(bool value) {
    // อัปเดตสถานะการกด
    if (_pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ฟังเหตุการณ์ pointer เพื่อทำแอนิเมชัน
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        // ย่อเมื่อกดและเด้งคืนเมื่อปล่อย
        scale: _pressed ? widget.pressedScale : 1,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
