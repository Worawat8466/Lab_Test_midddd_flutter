// AI-ASSISTED: หน้าต้อนรับและการเลื่อนสร้างโดย AI ทั้งหมด
// อธิบาย: แสดงข้อมูลแนะนำแอป 3 หน้าและนำทางเข้าสู่หน้าหลัก
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'press_scale.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ควบคุมการเลื่อนหน้าแบบ PageView
  final PageController _pageController = PageController();
  // ตำแหน่งหน้าปัจจุบันสำหรับจุด indicator
  int _currentPage = 0;

  // ข้อมูลแต่ละหน้าของ onboarding
  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.list_alt,
      title: 'จัดการงานง่ายๆ',
      description: 'สร้างและติดตามรายการงานของคุณได้ทุกวัน',
    ),
    _OnboardingPageData(
      icon: Icons.notifications_active,
      title: 'เตือนก่อนถึงกำหนด',
      description: 'ดูจำนวนวันที่เหลือและวางแผนล่วงหน้า',
    ),
    _OnboardingPageData(
      icon: Icons.dark_mode,
      title: 'สลับธีมได้ทันที',
      description: 'ใช้งานสบายตาในโหมดกลางคืน',
    ),
  ];

  @override
  void dispose() {
    // ปล่อยทรัพยากรของ PageController
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                // อนุญาตให้ลากด้วยเมาส์และสัมผัส
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: PageView.builder(
                  // ใช้ PageView เพื่อเลื่อนซ้าย-ขวา
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    // อัปเดตตำแหน่งเพื่อแสดงจุด indicator
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    // สร้าง UI ของแต่ละหน้า
                    final data = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            data.icon,
                            size: 96,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            data.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (index == _pages.length - 1) ...[
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: PressScale(
                                child: ElevatedButton(
                                  // ไปหน้า HomeScreen เมื่อกดเริ่มต้น
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text('เริ่มต้นใช้งาน'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              // จุดบอกตำแหน่งหน้าปัจจุบัน
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
