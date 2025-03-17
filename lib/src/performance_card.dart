import 'package:flutter/material.dart';

class PerformanceCard extends StatelessWidget {
  final int cpuUsage;
  final double ramUsage;
  final double executionTime;
  final VoidCallback onRunTest;
  final VoidCallback onDownloadCsv;

  const PerformanceCard({
    super.key,
    required this.cpuUsage,
    required this.ramUsage,
    required this.executionTime,
    required this.onRunTest,
    required this.onDownloadCsv,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔧 CPU Usage: $cpuUsage%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('🧠 RAM Usage: ${ramUsage.toStringAsFixed(2)} MB', style: const TextStyle(fontSize: 18)),
          Text('⏱️ Execution Time: $executionTime sec', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRunTest, child: const Text('Run Performance Test')),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onDownloadCsv, child: const Text('Download CSV')),
        ],
      ),
    );
  }
}
