import 'package:flutter/material.dart';
import 'src/performance_screen.dart';

void main() {
  runApp(const PerformanceTestApp());
}

class PerformanceTestApp extends StatelessWidget {
  const PerformanceTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PerformanceScreen(),
    );
  }
}
