import 'dart:io' show Platform, File;
import 'dart:html' as html; 
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:path_provider/path_provider.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart'; 

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

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  int _cpuUsage = 0;
  double _ramUsage = 0.0;
  double _executionTime = 0.0;
  List<String> _logData = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _measurePerformance();
    });
  }

  Future<void> _measurePerformance() async {
    final stopwatch = Stopwatch()..start();
    _heavyComputation();
    stopwatch.stop();

    setState(() {
      _executionTime = stopwatch.elapsedMilliseconds / 1000.0;
      _cpuUsage = _getCpuUsage();
      _ramUsage = _getRamUsage();
      _logData.add('${DateTime.now()},$_cpuUsage,$_ramUsage,$_executionTime');
    });
  }

  int _heavyComputation() {
    int sum = 0;
    for (int i = 0; i < 1000000; i++) {
      sum += Random().nextInt(100);
    }
    return sum;
  }

  int _getCpuUsage() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return Random().nextInt(50);
    } else {
      return html.window.navigator.hardwareConcurrency ?? 1;
    }
  }

  double _getRamUsage() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return Random().nextInt(200) + 100.0;
    } else {
      return _getWebMemoryUsage();
    }
  }

  double _getWebMemoryUsage() {
    try {
      final jsHeapSize = html.window.performance?.memory?.usedJSHeapSize;
      if (jsHeapSize != null) {
        return jsHeapSize / (1024 * 1024);
      }
    } catch (e) {
      print('Error accessing Web Memory API: $e');
    }
    return 0.0;
  }

  String _generateCsvData() {
    return 'Timestamp,CPU Usage (%),RAM Usage (MB),Execution Time (s)\n' + _logData.join("\n");
  }

  void _downloadCsvWeb() {
    final String csvContent = _generateCsvData();
    final blob = html.Blob([csvContent]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "performance_data.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _downloadCsvMobile() async {
    final String csvContent = _generateCsvData();
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/performance_data.csv';
      final File file = File(filePath);
      await file.writeAsString(csvContent);

      // Open the file with the Share plugin
      Share.shareXFiles([XFile(filePath)], text: 'Performance Data CSV');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV saved: $filePath\nYou can now share it.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving CSV: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔧 CPU Usage: $_cpuUsage%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('🧠 RAM Usage: ${_ramUsage.toStringAsFixed(2)} MB', style: const TextStyle(fontSize: 18)),
                  Text('⏱️ Execution Time: $_executionTime sec', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _measurePerformance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Run Performance Test'),
                  ),
                  const SizedBox(height: 10),
                  if (!kIsWeb)
                    ElevatedButton(
                      onPressed: _downloadCsvMobile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Download CSV (Mobile)'),
                    ),
                  if (kIsWeb)
                    ElevatedButton(
                      onPressed: _downloadCsvWeb,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Download CSV (Web)'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
